import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authDataSourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasource(supabaseClient: ref.watch(supabaseClientProvider));
});

class AuthDatasource {
  final SupabaseClient supabaseClient;

  AuthDatasource({required this.supabaseClient});

  Session? get currentUserSession => supabaseClient.auth.currentSession;

  // Future<Either<Failure, UserModel>> signInWithGoogle() async {
  //   try {
  //     final googleSignIn = await GoogleSignIn.initialize(
  //       clientId:
  //           '835833282413-m6k1k57i44a0b3f31e95v73pr957j07t.apps.googleusercontent.com',
  //     );
  //     final googleUser = await googleSignIn.signIn();

  //     if (googleUser == null) {
  //       return left(Failure("Google sign-in cancelled"));
  //     }

  //     final googleAuth = await googleUser.authentication;
  //     final idToken = googleAuth.idToken;
  //     final accessToken = googleAuth.accessToken;

  //     if (idToken == null) {
  //       return left(Failure("Failed to get Google ID token"));
  //     }

  //     final response = await supabaseClient.auth.signInWithIdToken(
  //       provider: OAuthProvider.google,
  //       idToken: idToken,
  //       accessToken: accessToken,
  //     );

  //     if (response.user == null) {
  //       return left(Failure("Google sign-in failed — no user returned"));
  //     }

  //     Log.info("Google sign-in success: ${response.user!.email}");
  //     return right(UserModel.fromMap(response.user!.toJson()));
  //   } on AuthException catch (e) {
  //     Log.error("Google sign-in AuthException: ${e.message}");
  //     return left(Failure(e.message));
  //   } catch (e) {
  //     Log.error("Google sign-in error: $e");
  //     return left(Failure(e.toString()));
  //   }
  // }
  /// Supabase OAuth Sign-In with Google.
  /// Authenticates directly via Supabase OAuth and redirects back to the app,
  /// bypassing Android Google Play Services Credential Manager / SHA-1 requirements.
  Future<Either<Failure, bool>> signInWithGoogle() async {
    try {
      Log.info("Starting Supabase Google OAuth sign-in...");
      final success = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.larnity://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return right(success);
    } on AuthException catch (e) {
      Log.error("Google sign-in AuthException: ${e.message}");
      return left(Failure(e.message));
    } catch (e) {
      Log.error("Google sign-in error: $e");
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        return left(Failure("User is null"));
      }
      return right(UserModel.fromMap(response.user!.toJson()));
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> signUpWithEmailPassword({
    required UserModel user,
    required String password,
  }) async {
    Log.info("${user.firstName} || ${user.lastName}");
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: user.email,
        data: {"firstname": user.firstName, "lastname": user.lastName},
      );
      if (response.user == null) {
        return left(Failure("User is null"));
      }
      return right(UserModel.fromMap(response.user!.toJson()));
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // In your AuthDataSource class
  Future<Either<Failure, bool>> sendEmailConfirmation({
    required String email,
  }) async {
    Log.info("Email: $email");
    try {
      final response = await supabaseClient.auth.resend(
        type: OtpType.email,
        email: email,
      );

      Log.info("Send email response: ${response.toString()}");

      return const Right(true);
    } on AuthException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Send email failure: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final session = currentUserSession;
      if (session == null) return left(Failure("No active session"));

      // Re-authenticate with current password first
      await supabaseClient.auth.signInWithPassword(
        email: session.user.email!,
        password: currentPassword,
      );

      // Now update to new password
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return const Right(true);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel?>> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);
        if (userData.isEmpty) {
          // If profile does not exist yet (e.g. brand new user via OAuth), create it from session user metadata
          final userModel = UserModel.fromMap(
            currentUserSession!.user.toJson(),
          );
          final inserted = await supabaseClient
              .from('profiles')
              .upsert(userModel.toMap(), onConflict: 'id')
              .select();
          final resolvedUser = inserted.isNotEmpty
              ? UserModel.fromMap(inserted.first).copyWith(
                  email: currentUserSession!.user.email,
                )
              : userModel;
          return right(resolvedUser);
        }

        return right(
          UserModel.fromMap(
            userData.first,
          ).copyWith(email: currentUserSession!.user.email),
        );
      } else {
        return left(Failure("No user found"));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

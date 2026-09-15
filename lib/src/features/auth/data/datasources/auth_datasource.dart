import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:larnity/src/core/env/env.dart';
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
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: AppEnv.googleClientId,
        serverClientId: AppEnv.googleServerId,
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: const <String>['email', 'profile']);

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        return left(Failure("Failed to get Google ID token"));
      }

      final headers = await googleUser.authorizationClient.authorizationHeaders(
        const <String>['email', 'profile'],
      );

      final accessToken = headers?['Authorization']?.replaceAll('Bearer ', '');

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      debugPrint('Google respone ====>${response.user!.toJson()}');
      if (response.user == null) {
        return left(Failure("Google sign-in failed — no user returned"));
      }

      Log.info("Google sign-in success: ${response.user!.email}");
      return right(UserModel.fromMap(response.user!.toJson()));
    } on GoogleSignInException catch (e) {
      // Catch specific plugin exceptions (e.g. user cancellations)
      Log.error("Google sign-in plugin exception: ${e.description}");
      return left(
        Failure(e.description ?? "Google sign-in cancelled or failed"),
      );
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
          return left(Failure("Profile not found"));
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

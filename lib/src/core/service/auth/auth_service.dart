// services/supabase_auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabaseClient;

  SupabaseAuthService(this._supabaseClient);

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with google
  Future<bool> signInWithGoogle() async {
    return await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'your-app-scheme://login-callback',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}

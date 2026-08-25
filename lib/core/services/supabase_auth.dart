import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/auth/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth {
  final _auth = SupabaseService.auth;

  AuthModel? _userFromSupabase(User? user) {
    if (user == null) return null;
    return AuthModel(
      email: user.email ?? '',
      id: user.id,
    );
  }

  AuthModel? get currentUser => _userFromSupabase(_auth.currentUser);

  Stream<AuthModel?> get authStateStream {
    return _auth.onAuthStateChange.map((event) {
      return _userFromSupabase(event.session?.user);
    });
  }

  Future<AuthModel?> signIn(String email, String password) async {
    try {
      final reponse = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _userFromSupabase(reponse.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthModel?> signUp(
    String email,
    String password,
    String fullName
  ) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user != null && (user.identities?.isEmpty ?? false)) {
        throw Exception('Email already registered. Please sign in.');
      }

      return _userFromSupabase(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgetPassword(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

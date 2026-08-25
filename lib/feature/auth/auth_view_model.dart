import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/supabase_auth.dart';
import 'package:social_media_app/feature/auth/auth_model.dart';
import 'package:social_media_app/feature/auth/auth_state.dart';

final authServiceProvider = Provider<SupabaseAuth>((ref) => SupabaseAuth());

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.read(authServiceProvider));
});

class AuthViewModel extends StateNotifier<AuthState> {
  final SupabaseAuth _auth;

  StreamSubscription<AuthModel?>? _authSubscription;

  AuthViewModel(this._auth) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }

    _authSubscription = _auth.authStateStream.listen(
      (user) {
        state = state.copyWith(
          status: user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: user,
          error: null,
        );
      },
      onError: (e) {
        state = state.copyWith(status: AuthStatus.error, error: e.toString());
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _auth.signIn(email, password);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullname) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _auth.signUp(email, password, fullname);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> forgetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _auth.forgetPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _auth.signOut();
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

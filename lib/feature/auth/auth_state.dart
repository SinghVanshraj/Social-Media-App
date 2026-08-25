import 'package:social_media_app/feature/auth/auth_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error}

class AuthState {
  final AuthStatus status;
  final AuthModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({AuthStatus? status, AuthModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user,
      error: error,
    );
  }
}

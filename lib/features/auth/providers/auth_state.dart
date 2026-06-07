/// Authentication state for the auth provider.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isLoading => this is AuthStateLoading;
  String? get errorMessage {
    return switch (this) {
      AuthStateError(:final message) => message,
      _ => null,
    };
  }
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final String userId;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;

  const AuthStateAuthenticated({
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
  });
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  final String? code;

  const AuthStateError({required this.message, this.code});
}

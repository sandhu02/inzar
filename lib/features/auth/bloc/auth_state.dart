import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_profile.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
  verificationRequired,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  final String? unverifiedEmail;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.unverifiedEmail,
  });

  const AuthState.authenticated({
    this.status = AuthStatus.authenticated,
    this.user = const UserProfile(
      id: 'usr_001',
      name: 'User',
      email: 'user@example.com',
      signInMethod: 'Google',
      isPasswordSet: false,
      reportCount: 0,
      isAnonymousByDefault: true,
    ),
    this.errorMessage,
    this.unverifiedEmail,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? Function()? user,
    String? Function()? errorMessage,
    String? Function()? unverifiedEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user != null ? user() : this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      unverifiedEmail: unverifiedEmail != null ? unverifiedEmail() : this.unverifiedEmail,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, unverifiedEmail];
}

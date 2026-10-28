import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.authenticated,
    this.user = const UserProfile(
      id: 'usr_001',
      name: 'Ayesha Khan',
      email: 'ayesha@example.com',
      signInMethod: 'Google',
      isPasswordSet: false,
      reportCount: 12,
      isAnonymousByDefault: true,
    ),
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? Function()? user,
    String? Function()? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user != null ? user() : this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}


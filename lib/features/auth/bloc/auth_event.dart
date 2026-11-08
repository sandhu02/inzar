import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInSubmitted extends AuthEvent {
  final String email;
  final String password;

  const SignInSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class ResendVerificationRequested extends AuthEvent {
  final String email;

  const ResendVerificationRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {
  final String? idToken;

  const GoogleSignInRequested({this.idToken});

  @override
  List<Object?> get props => [idToken];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

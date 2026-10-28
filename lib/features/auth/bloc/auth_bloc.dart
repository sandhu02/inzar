import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/entities/user_profile.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  void _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) {
    // Current initial state is authenticated with sample user "Ayesha Khan"
    if (state.user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignInSubmitted(SignInSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: event.email.split('@').first,
      email: event.email,
      signInMethod: 'Email',
      isPasswordSet: true,
      reportCount: 0,
      isAnonymousByDefault: true,
    );

    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: () => newUser,
    ));
  }

  Future<void> _onSignUpSubmitted(SignUpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: event.name.isEmpty ? 'New User' : event.name,
      email: event.email,
      signInMethod: 'Email',
      isPasswordSet: true,
      reportCount: 0,
      isAnonymousByDefault: true,
    );

    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: () => newUser,
    ));
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));

    const googleUser = UserProfile(
      id: 'usr_google_001',
      name: 'Ayesha Khan',
      email: 'ayesha@example.com',
      signInMethod: 'Google',
      isPasswordSet: false,
      reportCount: 12,
      isAnonymousByDefault: true,
    );

    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: () => googleUser,
    ));
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: () => null,
    ));
  }

  void _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: () => null,
    ));
  }
}


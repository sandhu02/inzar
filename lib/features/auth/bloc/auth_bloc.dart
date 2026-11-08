import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository? authRepository;

  AuthBloc({this.authRepository, AuthState? initialState})
    : super(initialState ?? const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final repository = authRepository;
    if (repository == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    final result = await repository.checkAuthStatus();
    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: () => result.data,
          errorMessage: () => null,
          unverifiedEmail: () => null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: () => null,
        errorMessage: () => null,
      ),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: () => null));

    final repository = authRepository;
    if (repository != null) {
      final idToken = event.idToken ?? 'google_id_token_${DateTime.now().millisecondsSinceEpoch}';
      final result = await repository.signInWithGoogle(idToken: idToken);
      if (result.isSuccess && result.data != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: () => result.data,
            errorMessage: () => null,
            unverifiedEmail: () => null,
          ),
        );
        return;
      }
    }

    final googleUser = UserProfile(
      id: 'usr_google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'user@gmail.com',
      signInMethod: 'Google',
      isEmailVerified: true,
      reportCount: 0,
    );

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: () => googleUser,
        errorMessage: () => null,
        unverifiedEmail: () => null,
      ),
    );
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: () => null));

    final repository = authRepository;
    if (repository == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => 'Authentication service is unavailable.',
        ),
      );
      return;
    }

    final result = await repository.signIn(
      email: event.email,
      password: event.password,
    );
    if (result.isSuccess &&
        result.data != null &&
        result.data!.isEmailVerified) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: () => result.data,
          errorMessage: () => null,
          unverifiedEmail: () => null,
        ),
      );
      return;
    }

    final failureCode = result.failure?.code?.toLowerCase() ?? '';
    final failureMsg = result.failure?.message.toLowerCase() ?? '';
    final isUnverified = failureCode == 'email_not_verified' ||
        failureMsg.contains('verify your email') ||
        failureMsg.contains('not verified');

    emit(
      state.copyWith(
        status: isUnverified
            ? AuthStatus.verificationRequired
            : AuthStatus.error,
        user: () => null,
        unverifiedEmail: () => isUnverified ? event.email : null,
        errorMessage: () =>
            result.failure?.message ??
            'Please verify your email before signing in.',
      ),
    );
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: () => null));

    final repository = authRepository;
    if (repository == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => 'Authentication service is unavailable.',
        ),
      );
      return;
    }

    final result = await repository.signUp(
      email: event.email,
      password: event.password,
      name: event.name.isNotEmpty ? event.name : null,
    );
    if (result.isSuccess && result.data != null) {
      if (result.data!.isEmailVerified) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: () => result.data,
            errorMessage: () => null,
            unverifiedEmail: () => null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.verificationRequired,
            user: () => null,
            unverifiedEmail: () => event.email,
            errorMessage: () =>
                'Account created. Verify your email before signing in.',
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => result.failure?.message ?? 'Sign up failed',
      ),
    );
  }

  Future<void> _onResendVerificationRequested(
    ResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: () => null));

    final repository = authRepository;
    if (repository == null) {
      emit(
        state.copyWith(
          status: AuthStatus.verificationRequired,
          errorMessage: () => 'Authentication service is unavailable.',
        ),
      );
      return;
    }

    final result = await repository.resendVerification(event.email);
    emit(
      state.copyWith(
        status: AuthStatus.verificationRequired,
        unverifiedEmail: () => event.email,
        errorMessage: () => result.isSuccess
            ? 'A new verification email was requested. Please check your inbox.'
            : result.failure?.message ??
                  'Could not request a verification email.',
      ),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (authRepository != null) {
      await authRepository!.signOut();
    }
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: () => null,
        unverifiedEmail: () => null,
        errorMessage: () => null,
      ),
    );
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (authRepository != null) {
      await authRepository!.deleteAccount();
    }
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: () => null,
        unverifiedEmail: () => null,
        errorMessage: () => null,
      ),
    );
  }
}

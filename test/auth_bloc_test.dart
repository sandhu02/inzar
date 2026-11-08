import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/error/app_failure.dart';
import 'package:inzar/core/error/result.dart';
import 'package:inzar/domain/entities/user_profile.dart';
import 'package:inzar/domain/repositories/auth_repository.dart';
import 'package:inzar/features/auth/bloc/auth_bloc.dart';
import 'package:inzar/features/auth/bloc/auth_event.dart';
import 'package:inzar/features/auth/bloc/auth_state.dart';

void main() {
  group('AuthBloc Tests', () {
    test('starts unauthenticated', () async {
      final bloc = AuthBloc();
      expect(bloc.state.status, AuthStatus.unauthenticated);
      expect(bloc.state.user, isNull);
      await bloc.close();
    });

    test('does not authenticate when no backend is configured', () async {
      final bloc = AuthBloc();
      final stateFuture = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.error,
      );

      bloc.add(
        const SignInSubmitted(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      final state = await stateFuture;
      expect(state.status, AuthStatus.error);
      expect(state.user, isNull);
      await bloc.close();
    });

    test('does not authenticate an unverified email', () async {
      final repository = FakeAuthRepository(
        signInResult: const Result.failure(
          ServerFailure(
            'Please verify your email before signing in.',
            'email_not_verified',
          ),
        ),
      );
      final bloc = AuthBloc(authRepository: repository);
      final stateFuture = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.verificationRequired,
      );

      bloc.add(
        const SignInSubmitted(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      final state = await stateFuture;
      expect(state.status, AuthStatus.verificationRequired);
      expect(state.unverifiedEmail, 'test@example.com');
      expect(state.user, isNull);
      await bloc.close();
    });

    test('resends verification email using entered email address', () async {
      final repository = FakeAuthRepository(
        resendResult: const Result.success(null),
      );
      final bloc = AuthBloc(authRepository: repository);
      final stateFuture = bloc.stream.firstWhere(
        (state) =>
            state.status == AuthStatus.verificationRequired &&
            state.errorMessage?.contains('verification email was requested') ==
                true,
      );

      bloc.add(const ResendVerificationRequested(email: 'test@example.com'));

      final state = await stateFuture;
      expect(repository.resendVerificationEmails, ['test@example.com']);
      expect(state.status, AuthStatus.verificationRequired);
      expect(state.unverifiedEmail, 'test@example.com');
      await bloc.close();
    });

    test('requires email verification after unverified signup', () async {
      final repository = FakeAuthRepository(
        signUpResult: Result.success(_user(isEmailVerified: false)),
      );
      final bloc = AuthBloc(authRepository: repository);
      final stateFuture = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.verificationRequired,
      );

      bloc.add(
        const SignUpSubmitted(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      final state = await stateFuture;
      expect(state.status, AuthStatus.verificationRequired);
      expect(state.unverifiedEmail, 'test@example.com');
      expect(state.user, isNull);
      expect(state.errorMessage, contains('Verify your email'));
      await bloc.close();
    });

    test(
      'authenticates only a verified user returned by the backend',
      () async {
        final repository = FakeAuthRepository(
          signInResult: Result.success(_user(isEmailVerified: true)),
        );
        final bloc = AuthBloc(authRepository: repository);
        final stateFuture = bloc.stream.firstWhere(
          (state) => state.status == AuthStatus.authenticated,
        );

        bloc.add(
          const SignInSubmitted(
            email: 'test@example.com',
            password: 'password123',
          ),
        );

        final state = await stateFuture;
        expect(state.user?.isEmailVerified, isTrue);
        await bloc.close();
      },
    );
  });
}

UserProfile _user({required bool isEmailVerified}) => UserProfile(
  id: 'user-1',
  name: 'Test User',
  email: 'test@example.com',
  isEmailVerified: isEmailVerified,
  signInMethod: 'Email',
  isPasswordSet: true,
  reportCount: 0,
);

class FakeAuthRepository implements IAuthRepository {
  final Result<UserProfile> signInResult;
  final Result<UserProfile> signUpResult;
  final Result<void> resendResult;
  final List<String> resendVerificationEmails = [];

  FakeAuthRepository({
    Result<UserProfile>? signInResult,
    Result<UserProfile>? signUpResult,
    Result<void>? resendResult,
  }) : signInResult =
           signInResult ??
           const Result.failure(GenericFailure('Invalid credentials')),
       signUpResult =
           signUpResult ??
           const Result.failure(GenericFailure('Signup failed')),
       resendResult = resendResult ?? const Result.success(null);

  @override
  Future<Result<UserProfile>> checkAuthStatus() async => signInResult;

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async => signInResult;

  @override
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    String? name,
  }) async => signUpResult;

  @override
  Future<Result<UserProfile>> signInWithGoogle({required String idToken}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> signOut() => throw UnimplementedError();

  @override
  Future<Result<void>> deleteAccount() => throw UnimplementedError();

  @override
  Future<Result<void>> verifyEmail(String token) => throw UnimplementedError();

  @override
  Future<Result<void>> resendVerification(String email) async {
    resendVerificationEmails.add(email);
    return resendResult;
  }

  @override
  Future<Result<void>> forgotPassword(String email) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) => throw UnimplementedError();
}

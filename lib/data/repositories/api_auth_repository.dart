import '../../core/error/app_failure.dart';
import '../../core/error/result.dart';
import '../../core/network/token_storage.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class ApiAuthRepository implements IAuthRepository {
  final AuthRemoteDataSource _dataSource;
  final ITokenStorage _tokenStorage;

  ApiAuthRepository(this._dataSource, this._tokenStorage);

  @override
  Future<Result<UserProfile>> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    if ((token == null || token.isEmpty) && (refreshToken == null || refreshToken.isEmpty)) {
      return const Result.failure(GenericFailure('Not logged in'));
    }

    try {
      final response = await _dataSource.getMe();
      if (response.isSuccess && response.data != null) {
        await _tokenStorage.saveUser(response.data!);
        return Result.success(response.data!);
      }

      if (response.statusCode == 401) {
        await _tokenStorage.clearTokens();
        return Result.failure(
          ServerFailure(response.error?.message ?? 'Session expired'),
        );
      }
    } catch (_) {
      // Network/server transient errors - do not sign user out!
    }

    final cachedUser = await _tokenStorage.getUser();
    if (cachedUser != null) {
      return Result.success(cachedUser);
    }

    final fallbackUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: 'User',
      email: '',
      isEmailVerified: true,
      signInMethod: 'Email',
      reportCount: 0,
    );
    return Result.success(fallbackUser);
  }

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.login(email: email, password: password);
    if (response.isSuccess && response.data != null) {
      await _tokenStorage.saveUser(response.data!);
      return Result.success(response.data!);
    }

    return Result.failure(
      ServerFailure(
        response.error?.message ?? 'Invalid email or password',
        response.error?.code,
      ),
    );
  }

  @override
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _dataSource.signUp(
      email: email,
      password: password,
      displayName: name,
    );

    if (response.isSuccess && response.data != null) {
      await _tokenStorage.saveUser(response.data!);
      return Result.success(response.data!);
    }

    return Result.failure(
      ServerFailure(
        response.error?.message ?? 'Account registration failed',
        response.error?.code,
      ),
    );
  }

  @override
  Future<Result<UserProfile>> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await _dataSource.googleLogin(idToken: idToken);
    if (response.isSuccess && response.data != null) {
      await _tokenStorage.saveUser(response.data!);
      return Result.success(response.data!);
    }

    return Result.failure(
      ServerFailure(
        response.error?.message ?? 'Google Sign-In failed',
        response.error?.code,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.logout();
    } catch (_) {}
    await _tokenStorage.clearTokens();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    final response = await _dataSource.deleteAccount();
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to delete account'),
    );
  }

  @override
  Future<Result<void>> verifyEmail(String token) async {
    final response = await _dataSource.verifyEmail(token);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to verify email'),
    );
  }

  @override
  Future<Result<void>> resendVerification(String email) async {
    final response = await _dataSource.resendVerification(email);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to resend email'),
    );
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    final response = await _dataSource.forgotPassword(email);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to send password reset'),
    );
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _dataSource.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to reset password'),
    );
  }
}

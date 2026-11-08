import '../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract class IAuthRepository {
  Future<Result<UserProfile>> checkAuthStatus();
  Future<Result<UserProfile>> signIn({required String email, required String password});
  Future<Result<UserProfile>> signUp({required String email, required String password, String? name});
  Future<Result<UserProfile>> signInWithGoogle({required String idToken});
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
  Future<Result<void>> verifyEmail(String token);
  Future<Result<void>> resendVerification(String email);
  Future<Result<void>> forgotPassword(String email);
  Future<Result<void>> resetPassword({required String token, required String newPassword});
}


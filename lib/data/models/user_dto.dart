import '../../domain/entities/user_profile.dart';

class UserDto {
  static UserProfile fromJson(
    Map<String, dynamic> json, {
    String signInMethod = 'Email',
  }) {
    final displayName = json['display_name']?.toString();
    final email = json['email']?.toString() ?? '';
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : email.split('@').first;

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? 'User' : name,
      email: email,
      isEmailVerified:
          json['email_verified'] == true ||
          json['email_verified'] == 1 ||
          json['email_verified']?.toString().toLowerCase() == 'true',
      signInMethod: signInMethod,
      isPasswordSet: true,
      reportCount: 0,
      isAnonymousByDefault: true,
    );
  }
}

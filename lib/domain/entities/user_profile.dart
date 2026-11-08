import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final String signInMethod;
  final bool isPasswordSet;
  final int reportCount;
  final bool isAnonymousByDefault;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.isEmailVerified = false,
    this.signInMethod = 'Google',
    this.isPasswordSet = false,
    this.reportCount = 0,
    this.isAnonymousByDefault = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'is_email_verified': isEmailVerified,
    'sign_in_method': signInMethod,
    'is_password_set': isPasswordSet,
    'report_count': reportCount,
    'is_anonymous_by_default': isAnonymousByDefault,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'User',
    email: json['email']?.toString() ?? '',
    isEmailVerified: json['is_email_verified'] == true,
    signInMethod: json['sign_in_method']?.toString() ?? 'Email',
    isPasswordSet: json['is_password_set'] == true,
    reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
    isAnonymousByDefault: json['is_anonymous_by_default'] != false,
  );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? signInMethod,
    bool? isPasswordSet,
    int? reportCount,
    bool? isAnonymousByDefault,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      signInMethod: signInMethod ?? this.signInMethod,
      isPasswordSet: isPasswordSet ?? this.isPasswordSet,
      reportCount: reportCount ?? this.reportCount,
      isAnonymousByDefault: isAnonymousByDefault ?? this.isAnonymousByDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    isEmailVerified,
    signInMethod,
    isPasswordSet,
    reportCount,
    isAnonymousByDefault,
  ];
}

import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String signInMethod;
  final bool isPasswordSet;
  final int reportCount;
  final bool isAnonymousByDefault;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.signInMethod = 'Google',
    this.isPasswordSet = false,
    this.reportCount = 12,
    this.isAnonymousByDefault = true,
  });

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
    String? signInMethod,
    bool? isPasswordSet,
    int? reportCount,
    bool? isAnonymousByDefault,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
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
        signInMethod,
        isPasswordSet,
        reportCount,
        isAnonymousByDefault,
      ];
}


import '../../domain/entities/user_profile.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.role,
    this.reputation,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? role;
  final int? reputation;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      displayName: map['display_name']?.toString() ?? map['displayName']?.toString(),
      avatarUrl: map['avatar_url']?.toString() ?? map['avatarUrl']?.toString(),
      bio: map['bio']?.toString(),
      role: map['role']?.toString(),
      reputation: map['reputation'] is int ? map['reputation'] as int : int.tryParse('${map['reputation']}'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role,
      'reputation': reputation,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      role: role,
      reputation: reputation,
    );
  }

  static UserModel fromEntity(UserProfile p) {
    return UserModel(
      id: p.id,
      email: p.email,
      displayName: p.displayName,
      avatarUrl: p.avatarUrl,
      bio: p.bio,
      role: p.role,
      reputation: p.reputation,
    );
  }
}

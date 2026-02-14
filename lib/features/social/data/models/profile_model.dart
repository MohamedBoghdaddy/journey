import '../../domain/entities/profile.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.reputation,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int? reputation;

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      displayName: map['display_name']?.toString() ?? map['displayName']?.toString(),
      avatarUrl: map['avatar_url']?.toString() ?? map['avatarUrl']?.toString(),
      bio: map['bio']?.toString(),
      reputation: map['reputation'] is int ? map['reputation'] as int : int.tryParse('${map['reputation']}'),
    );
  }

  Profile toEntity() => Profile(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    bio: bio,
    reputation: reputation,
  );
}

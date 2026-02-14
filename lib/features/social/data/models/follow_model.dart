import '../../domain/entities/follow.dart';

class FollowModel {
  const FollowModel({required this.followerId, required this.followingId, this.createdAt});

  final String followerId;
  final String followingId;
  final DateTime? createdAt;

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      followerId: (map['follower_id'] ?? '').toString(),
      followingId: (map['following_id'] ?? '').toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Follow toEntity() => Follow(followerId: followerId, followingId: followingId, createdAt: createdAt);
}

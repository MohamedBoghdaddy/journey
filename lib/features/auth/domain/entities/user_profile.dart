class UserProfile {
  const UserProfile({
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

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? role,
    int? reputation,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      reputation: reputation ?? this.reputation,
    );
  }
}

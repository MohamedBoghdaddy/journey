class Profile {
  const Profile({
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

  String get name => (displayName != null && displayName!.trim().isNotEmpty)
      ? displayName!.trim()
      : email;
}

class Follow {
  const Follow({
    required this.followerId,
    required this.followingId,
    this.createdAt,
  });

  final String followerId;
  final String followingId;
  final DateTime? createdAt;
}

class ReputationScore {
  const ReputationScore({
    required this.userId,
    required this.score,
    this.updatedAt,
  });

  final String userId;
  final int score;
  final DateTime? updatedAt;
}

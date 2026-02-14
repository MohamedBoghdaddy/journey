class Space {
  const Space({
    required this.id,
    required this.name,
    this.description,
    this.city,
    this.createdAt,
    this.ownerId,
    this.isVerified,
  });

  final String id;
  final String name;
  final String? description;
  final String? city;
  final DateTime? createdAt;
  final String? ownerId;
  final bool? isVerified;
}

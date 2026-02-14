class Product {
  const Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    this.currency,
    this.createdAt,
    this.category,
    this.imageUrl,
  });

  final String id;
  final String sellerId;
  final String title;
  final String description;
  final num price;
  final String? currency;
  final DateTime? createdAt;
  final String? category;
  final String? imageUrl;
}

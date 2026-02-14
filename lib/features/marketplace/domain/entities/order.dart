class Order {
  const Order({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    this.status,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final num amount;
  final String? status;
  final DateTime? createdAt;
}

import '../../domain/entities/order.dart';

class OrderModel {
  const OrderModel({
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

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: (map['id'] ?? '').toString(),
      productId: (map['product_id'] ?? '').toString(),
      buyerId: (map['buyer_id'] ?? '').toString(),
      sellerId: (map['seller_id'] ?? '').toString(),
      amount: (map['amount'] is num) ? (map['amount'] as num) : num.tryParse('${map['amount']}') ?? 0,
      status: map['status']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Order toEntity() => Order(
    id: id,
    productId: productId,
    buyerId: buyerId,
    sellerId: sellerId,
    amount: amount,
    status: status,
    createdAt: createdAt,
  );
}

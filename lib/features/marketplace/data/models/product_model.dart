import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: (map['id'] ?? '').toString(),
      sellerId: (map['seller_id'] ?? map['owner_id'] ?? '').toString(),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] is num) ? (map['price'] as num) : num.tryParse('${map['price']}') ?? 0,
      currency: map['currency']?.toString() ?? 'EGP',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      category: map['category']?.toString(),
      imageUrl: map['image_url']?.toString() ?? map['image']?.toString(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'seller_id': sellerId,
    'title': title,
    'description': description,
    'price': price,
    'currency': currency,
    'category': category,
    'image_url': imageUrl,
  };

  Product toEntity() => Product(
    id: id,
    sellerId: sellerId,
    title: title,
    description: description,
    price: price,
    currency: currency,
    createdAt: createdAt,
    category: category,
    imageUrl: imageUrl,
  );
}

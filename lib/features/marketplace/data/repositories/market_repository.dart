import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../datasources/market_remote_ds.dart';
import '../models/product_model.dart';

class MarketRepository {
  MarketRepository({required this.remote});

  final MarketRemoteDs remote;

  Future<List<Product>> listProducts() async {
    final list = await remote.listProducts();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<Product?> getProduct(String id) async {
    final m = await remote.getProduct(id);
    return m?.toEntity();
  }

  Future<Product> createListing({
    required String sellerId,
    required String title,
    required String description,
    required num price,
    String? currency,
    String? category,
    String? imageUrl,
  }) async {
    final model = ProductModel(
      id: '',
      sellerId: sellerId,
      title: title,
      description: description,
      price: price,
      currency: currency ?? 'EGP',
      category: category,
      imageUrl: imageUrl,
    );
    final created = await remote.createProduct(model);
    return created.toEntity();
  }

  Future<Order> createOrder({
    required String productId,
    required String buyerId,
    required String sellerId,
    required num amount,
  }) async {
    final o = await remote.createOrder(
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
      amount: amount,
    );
    return o.toEntity();
  }
}

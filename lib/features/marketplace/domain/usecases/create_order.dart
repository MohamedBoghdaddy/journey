import '../entities/order.dart';
import '../../data/repositories/market_repository.dart';

class CreateOrder {
  CreateOrder(this.repo);

  final MarketRepository repo;

  Future<Order> call({
    required String productId,
    required String buyerId,
    required String sellerId,
    required num amount,
  }) {
    return repo.createOrder(
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
      amount: amount,
    );
  }
}

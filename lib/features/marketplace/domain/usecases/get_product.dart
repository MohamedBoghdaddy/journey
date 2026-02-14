import '../entities/product.dart';
import '../../data/repositories/market_repository.dart';

class GetProduct {
  GetProduct(this.repo);

  final MarketRepository repo;

  Future<Product?> call(String id) => repo.getProduct(id);
}

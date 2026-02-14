import '../entities/product.dart';
import '../../data/repositories/market_repository.dart';

class ListProducts {
  ListProducts(this.repo);

  final MarketRepository repo;

  Future<List<Product>> call() => repo.listProducts();
}

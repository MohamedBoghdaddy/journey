import '../entities/product.dart';
import '../../data/repositories/market_repository.dart';

class CreateListing {
  CreateListing(this.repo);

  final MarketRepository repo;

  Future<Product> call({
    required String sellerId,
    required String title,
    required String description,
    required num price,
    String? currency,
    String? category,
    String? imageUrl,
  }) {
    return repo.createListing(
      sellerId: sellerId,
      title: title,
      description: description,
      price: price,
      currency: currency,
      category: category,
      imageUrl: imageUrl,
    );
  }
}

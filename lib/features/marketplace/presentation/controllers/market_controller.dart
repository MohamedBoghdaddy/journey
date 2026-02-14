import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/list_products.dart';

class MarketController extends ChangeNotifier {
  MarketController({required this.listProducts});

  final ListProducts listProducts;

  bool isLoading = false;
  String? error;
  List<Product> products = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      products = await listProducts();
    } catch (e) {
      Logger.e('Load products failed', error: e);
      error = 'Failed to load marketplace';
    }
    isLoading = false;
    notifyListeners();
  }
}

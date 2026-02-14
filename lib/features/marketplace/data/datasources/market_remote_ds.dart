import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class MarketRemoteDs {
  MarketRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<List<ProductModel>> listProducts({int limit = 50}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.products)
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listProducts failed: $e');
      return [];
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final row = await sb.from(DbTables.products).select('*').eq('id', productId).maybeSingle();
      if (row == null) return null;
      return ProductModel.fromMap(row);
    } catch (e) {
      Logger.w('getProduct failed: $e');
      return null;
    }
  }

  Future<ProductModel> createProduct(ProductModel model) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      final row = await sb.from(DbTables.products).insert(model.toInsertMap()).select('*').single();
      return ProductModel.fromMap(row);
    } catch (e) {
      throw NetworkException('Create listing failed', cause: e);
    }
  }

  Future<OrderModel> createOrder({
    required String productId,
    required String buyerId,
    required String sellerId,
    required num amount,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      final row = await sb.from(DbTables.orders).insert({
        'product_id': productId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'amount': amount,
        'status': 'pending',
      }).select('*').single();
      return OrderModel.fromMap(row);
    } catch (e) {
      throw NetworkException('Create order failed', cause: e);
    }
  }
}

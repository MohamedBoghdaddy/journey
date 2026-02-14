import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../../chat/domain/usecases/get_or_create_product_chat.dart';
import '../../domain/usecases/get_product.dart';
import '../widgets/price_tag.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isLoading = true;
  String? _error;
  dynamic _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final deps = DependenciesScope.of(context);
    try {
      final p = await GetProduct(deps.marketRepository)(widget.productId);
      setState(() => _product = p);
    } catch (_) {
      setState(() => _error = 'Failed to load product');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _messageSeller() async {
    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    final p = _product;
    if (me == null || p == null) return;
    if (p.sellerId == me.id) return;

    final convoId = await GetOrCreateProductChat(deps.chatRepository)(
      p.id,
      p.sellerId,
      meId: me.id,
    );

    if (!mounted) return;
    Navigator.of(context).pushNamed(Routes.appChatConversation(convoId));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingView(message: 'Loading product...'));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(title: _error!, onRetry: _load),
      );
    }
    final p = _product;
    if (p == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.imageUrl != null && p.imageUrl.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(p.imageUrl, height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: const Center(child: Icon(Icons.image_not_supported_outlined)),
            ),
          const SizedBox(height: 14),
          Text(p.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          PriceTag(amount: p.price, currency: p.currency),
          const SizedBox(height: 14),
          Text(p.description),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _messageSeller,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Message seller'),
          ),
        ],
      ),
    );
  }
}

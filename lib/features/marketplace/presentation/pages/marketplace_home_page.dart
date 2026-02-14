import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/list_products.dart';
import '../controllers/market_controller.dart';
import '../widgets/product_card.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  late final MarketController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = MarketController(listProducts: ListProducts(deps.marketRepository));
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.products.isEmpty) {
      return const LoadingView(message: 'Loading marketplace...');
    }
    if (_controller.error != null && _controller.products.isEmpty) {
      return ErrorView(title: _controller.error!, onRetry: _controller.load);
    }
    if (_controller.products.isEmpty) {
      return EmptyState(
        title: 'No listings yet',
        subtitle: 'Create the first listing in the marketplace.',
        icon: Icons.storefront_outlined,
        action: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(Routes.appCreateListing),
          icon: const Icon(Icons.add),
          label: const Text('Create listing'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = _controller.products[i];
          return ProductCard(
            product: p,
            onOpen: () => Navigator.of(context).pushNamed(Routes.appProductDetails(p.id)),
          );
        },
      ),
    );
  }
}

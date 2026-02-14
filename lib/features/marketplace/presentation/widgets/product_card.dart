import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'price_tag.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onOpen});

  final Product product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: product.imageUrl == null || product.imageUrl!.isEmpty
                    ? const Icon(Icons.storefront_outlined)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    PriceTag(amount: product.price, currency: product.currency),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

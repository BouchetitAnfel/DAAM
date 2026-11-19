import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/product.dart';

/// Carte produit moderne, utilisée dans le catalogue client et
/// la liste d'inventaire du pharmacien.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Widget? trailingActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.medication_rounded, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} DA',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen, fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        _StockBadge(quantity: product.quantity),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailingActions,
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int quantity;
  const _StockBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final inStock = quantity > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: inStock ? AppColors.lightGreen : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        inStock ? 'Stock: $quantity' : 'Rupture',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: inStock ? AppColors.primaryGreen : AppColors.error,
        ),
      ),
    );
  }
}

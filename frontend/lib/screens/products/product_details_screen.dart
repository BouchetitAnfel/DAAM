import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';

/// Page de détail d'un médicament, avec description complète, disponibilité
/// et ajout au panier. Les données viennent de GET /api/products/:id
/// (ici on réutilise directement l'objet déjà chargé dans la liste).
class ProductDetailsScreen extends ConsumerWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider).any((line) => line.product.id == product.id);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(20)),
              child: const Center(
                child: Icon(Icons.medication_rounded, color: AppColors.primaryGreen, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${product.price.toStringAsFixed(2)} DA',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.inStock ? AppColors.lightGreen : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    product.inStock ? '${product.quantity} en stock' : 'Rupture de stock',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: product.inStock ? AppColors.primaryGreen : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              product.description.isEmpty ? 'Aucune description disponible.' : product.description,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const Spacer(),
            AppButton(
              label: inCart ? 'Déjà dans le panier' : 'Add to Cart',
              icon: Icons.shopping_cart_outlined,
              onPressed: product.inStock && !inCart
                  ? () {
                      ref.read(cartProvider.notifier).addProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajouté au panier.'), backgroundColor: AppColors.primaryGreen),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

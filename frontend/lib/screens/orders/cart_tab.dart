import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_button.dart';

/// Onglet "Panier" : récapitulatif des articles ajoutés et validation de la
/// commande via POST /api/orders (routes/order.js).
class CartTab extends ConsumerStatefulWidget {
  const CartTab({super.key});

  @override
  ConsumerState<CartTab> createState() => _CartTabState();
}

class _CartTabState extends ConsumerState<CartTab> {
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    final lines = ref.read(cartProvider);
    if (lines.isEmpty) return;

    setState(() => _isPlacingOrder = true);
    try {
      final items = [
        for (final line in lines) {'product_id': line.product.id, 'quantity': line.quantity},
      ];
      await ref.read(orderServiceProvider).placeOrder(items);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande validée avec succès !'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      final message = e is ApiException ? e.message : 'Échec de la commande.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartLines = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).totalPrice;

    if (cartLines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56, color: AppColors.muted),
            SizedBox(height: 12),
            Text('Ton panier est vide.', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: cartLines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final line = cartLines[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.product.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            const SizedBox(height: 4),
                            Text('${line.product.price.toStringAsFixed(2)} DA / unité', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen),
                        onPressed: () => ref.read(cartProvider.notifier).updateQuantity(line.product.id, line.quantity - 1),
                      ),
                      Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                        onPressed: line.quantity < line.product.quantity
                            ? () => ref.read(cartProvider.notifier).updateQuantity(line.product.id, line.quantity + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Text('${total.toStringAsFixed(2)} DA', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryGreen, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 14),
              AppButton(label: 'Valider la commande', isLoading: _isPlacingOrder, onPressed: _placeOrder),
            ],
          ),
        ),
      ],
    );
  }
}

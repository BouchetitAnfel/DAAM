import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/product_card.dart';
import '../products/add_product_screen.dart';
import '../products/edit_product_screen.dart';

/// Dashboard pharmacien : accueil, statistiques du stock, recherche et
/// gestion complète de l'inventaire (GET/POST/PUT/DELETE /api/products).
class PharmacistDashboardScreen extends ConsumerStatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  ConsumerState<PharmacistDashboardScreen> createState() => _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends ConsumerState<PharmacistDashboardScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productListProvider.notifier).loadProducts(search: value.trim());
    });
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('"${product.name}" sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final error = await ref.read(productListProvider.notifier).deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Produit supprimé.'),
          backgroundColor: error == null ? AppColors.primaryGreen : AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final productsState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon officine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Product', style: TextStyle(color: AppColors.white)),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () => ref.read(productListProvider.notifier).loadProducts(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              'Bonjour, ${user?.name ?? ''} 👩‍⚕️',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text('Voici l\'état de ton stock aujourd\'hui.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            productsState.when(
              data: (products) => _StatsRow(products: products),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Rechercher un médicament...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Médicaments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 12),
            productsState.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: Text('Aucun produit trouvé.', style: TextStyle(color: AppColors.muted))),
                  );
                }
                return Column(
                  children: products
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProductCard(
                            product: product,
                            trailingActions: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGreen),
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () => _confirmDelete(product),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Padding(padding: EdgeInsets.only(top: 40), child: LoadingView()),
              error: (error, st) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.read(productListProvider.notifier).loadProducts(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Product> products;
  const _StatsRow({required this.products});

  @override
  Widget build(BuildContext context) {
    final totalQuantity = products.fold<int>(0, (sum, p) => sum + p.quantity);

    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Produits', value: '${products.length}', icon: Icons.medication_liquid_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Quantité en stock', value: '$totalQuantity', icon: Icons.inventory_2_rounded)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

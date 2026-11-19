import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/product_card.dart';
import '../products/product_details_screen.dart';

/// Onglet "Catalogue" du Client Dashboard : recherche + liste des médicaments
/// disponibles (GET /api/products?search=).
class CatalogueTab extends ConsumerStatefulWidget {
  const CatalogueTab({super.key});

  @override
  ConsumerState<CatalogueTab> createState() => _CatalogueTabState();
}

class _CatalogueTabState extends ConsumerState<CatalogueTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productListProvider.notifier).loadProducts(search: value.trim());
    });
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

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => ref.read(productListProvider.notifier).loadProducts(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Bonjour, ${user?.name ?? ''} 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text('Trouve tes médicaments en quelques secondes.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Rechercher un médicament...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Catalogue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
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
    );
  }
}

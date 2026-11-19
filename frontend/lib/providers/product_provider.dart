import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../models/product.dart';
import 'core_providers.dart';

/// Gère la liste des produits (catalogue / inventaire) et les opérations
/// CRUD, partagées entre le dashboard pharmacien et le catalogue client.
class ProductListController extends StateNotifier<AsyncValue<List<Product>>> {
  final Ref ref;
  String _search = '';

  ProductListController(this.ref) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts({String? search}) async {
    _search = search ?? _search;
    state = const AsyncValue.loading();
    try {
      final products = await ref.read(productServiceProvider).fetchProducts(search: _search);
      state = AsyncValue.data(products);
    } catch (e) {
      final message = e is ApiException ? e.message : 'Impossible de charger les produits.';
      state = AsyncValue.error(message, StackTrace.current);
    }
  }

  Future<String?> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
  }) async {
    try {
      final created = await ref.read(productServiceProvider).createProduct(
            name: name,
            description: description,
            price: price,
            quantity: quantity,
          );
      state.whenData((list) => state = AsyncValue.data([...list, created]));
      return null;
    } catch (e) {
      return e is ApiException ? e.message : 'Échec de l\'ajout du produit.';
    }
  }

  Future<String?> editProduct(Product product) async {
    try {
      await ref.read(productServiceProvider).updateProduct(product);
      state.whenData((list) {
        state = AsyncValue.data([
          for (final p in list) if (p.id == product.id) product else p,
        ]);
      });
      return null;
    } catch (e) {
      return e is ApiException ? e.message : 'Échec de la modification du produit.';
    }
  }

  Future<String?> deleteProduct(int id) async {
    try {
      await ref.read(productServiceProvider).deleteProduct(id);
      state.whenData((list) => state = AsyncValue.data(list.where((p) => p.id != id).toList()));
      return null;
    } catch (e) {
      return e is ApiException ? e.message : 'Échec de la suppression du produit.';
    }
  }
}

final productListProvider = StateNotifierProvider<ProductListController, AsyncValue<List<Product>>>((ref) {
  return ProductListController(ref);
});

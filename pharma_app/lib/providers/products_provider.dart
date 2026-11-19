import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  String? get _token => ref.read(authProvider)?.token;

  @override
  Future<List<Product>> build() => _fetch();

  Future<List<Product>> _fetch() async {
    final data =
        await ApiClient.instance.request('GET', '/api/products', token: _token);
    return (data as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  // The following throw ApiException -> UI shows the message.
  Future<void> add(Product p) async {
    await ApiClient.instance
        .request('POST', '/api/products', body: p.toJson(), token: _token);
    state = AsyncData(await _fetch());
  }

  Future<void> edit(int id, Product p) async {
    await ApiClient.instance.request('PUT', '/api/products/$id',
        body: p.toJson(), token: _token);
    state = AsyncData(await _fetch());
  }

  Future<void> remove(int id) async {
    await ApiClient.instance
        .request('DELETE', '/api/products/$id', token: _token);
    state = AsyncData(await _fetch());
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

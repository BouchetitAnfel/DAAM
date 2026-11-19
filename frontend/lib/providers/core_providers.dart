import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';

/// Providers "bas niveau" : stockage de session, client Dio et services API.
/// Centralisés ici pour que tous les autres providers partagent la même instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  return buildDioClient(ref.watch(tokenStorageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(dioProvider));
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(dioProvider));
});

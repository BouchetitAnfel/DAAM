import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exception.dart';
import '../models/order.dart';

/// Appelle les véritables endpoints de routes/order.js.
class OrderService {
  final Dio _dio;
  OrderService(this._dio);

  /// [items] attendu par le backend : [{ product_id, quantity }, ...]
  Future<Order> placeOrder(List<Map<String, int>> items) async {
    try {
      final response = await _dio.post(ApiConstants.orders, data: {'items': items});
      final data = response.data as Map<String, dynamic>;
      // POST /api/orders ne renvoie pas les items détaillés, uniquement order_id/total_price.
      return Order(
        id: data['order_id'] as int,
        totalPrice: double.tryParse(data['total_price'].toString()) ?? 0,
        status: 'confirmed',
        orderDate: DateTime.now(),
        items: const [],
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Order>> fetchOrderHistory() async {
    try {
      final response = await _dio.get(ApiConstants.orders);
      final list = response.data as List;
      return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

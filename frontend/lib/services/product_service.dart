import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exception.dart';
import '../models/product.dart';

/// Appelle les véritables endpoints CRUD de routes/products.js.
class ProductService {
  final Dio _dio;
  ProductService(this._dio);

  Future<List<Product>> fetchProducts({String search = ''}) async {
    try {
      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: search.isNotEmpty ? {'search': search} : null,
      );
      final list = response.data as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> fetchProduct(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.products}/$id');
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.products, data: {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
      });
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _dio.put('${ApiConstants.products}/${product.id}', data: product.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('${ApiConstants.products}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../services/token_storage.dart';

/// Construit l'instance Dio partagée par tous les services.
/// Un intercepteur attache automatiquement le header `Authorization: Bearer <token>`
/// dès qu'une session est enregistrée (voir middleware/auth.js côté backend).
Dio buildDioClient(TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

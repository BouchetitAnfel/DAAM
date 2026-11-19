import 'package:dio/dio.dart';

/// Transforme une erreur Dio en message lisible, en lisant le champ
/// `error` renvoyé par le backend Express (ex: { "error": "..." }).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return ApiException(data['error'] as String, statusCode: e.response?.statusCode);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('La connexion au serveur a expiré. Vérifie ta connexion réseau.');
      case DioExceptionType.connectionError:
        return ApiException('Impossible de contacter le serveur. Vérifie que le backend est démarré.');
      default:
        return ApiException(e.message ?? 'Une erreur inattendue est survenue.', statusCode: e.response?.statusCode);
    }
  }

  @override
  String toString() => message;
}

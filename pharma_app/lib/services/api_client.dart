import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

/// HTTP client that accepts the server's SELF-SIGNED certificate,
/// but ONLY for our own backend host (never for other sites).
/// This is the fix for: HandshakeException: CERTIFICATE_VERIFY_FAILED.
http.Client _buildClient() {
  final inner = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            kUseHttps && host == kHost && port == kPort;
  return IOClient(inner);
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _client = _buildClient();

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$kBaseUrl$path');
    try {
      late http.Response res;
      final encoded = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          res = await _client.get(uri, headers: _headers(token));
          break;
        case 'POST':
          res = await _client.post(uri, headers: _headers(token), body: encoded);
          break;
        case 'PUT':
          res = await _client.put(uri, headers: _headers(token), body: encoded);
          break;
        case 'DELETE':
          res = await _client.delete(uri, headers: _headers(token));
          break;
        default:
          throw ApiException('Unsupported method $method');
      }

      dynamic data;
      if (res.body.isNotEmpty) {
        try {
          data = jsonDecode(res.body);
        } catch (_) {
          data = null;
        }
      }

      if (res.statusCode >= 200 && res.statusCode < 300) return data;

      String msg = 'Error ${res.statusCode}';
      if (data is Map) {
        msg = (data['message'] ?? data['error'] ?? msg).toString();
      }
      if (res.statusCode == 401) msg = data is Map && data['message'] != null ? msg : 'Invalid credentials or session expired';
      throw ApiException(msg, res.statusCode);
    } on ApiException {
      rethrow;
    } on HandshakeException {
      throw ApiException(
          'SSL error: certificate rejected. Check the host/port in config.dart and that the server uses HTTPS.');
    } on SocketException {
      throw ApiException(
          'Cannot reach server at $kBaseUrl. Is it running (npm start)? Right host in config.dart?');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on FormatException {
      throw ApiException('Unexpected server response.');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException('Server timeout.');
      }
      throw ApiException('Unexpected error: $e');
    }
  }
}

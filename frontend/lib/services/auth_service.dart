import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exception.dart';
import '../models/user.dart';

/// Résultat d'une connexion réussie : utilisateur + token JWT.
class AuthResult {
  final AppUser user;
  final String token;
  AuthResult({required this.user, required this.token});
}

/// Appelle les véritables endpoints du backend : POST /api/auth/login
/// et POST /api/auth/register (routes/auth.js).
class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      return AuthResult(
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// L'inscription ne renvoie pas de token (voir routes/auth.js) :
  /// l'utilisateur doit ensuite se connecter via /auth/login.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      final data = response.data as Map<String, dynamic>;
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

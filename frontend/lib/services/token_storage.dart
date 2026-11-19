import 'package:shared_preferences/shared_preferences.dart';

/// Persiste le token JWT et les informations basiques de l'utilisateur
/// connecté, pour que la session survive au redémarrage de l'app.
class TokenStorage {
  static const _tokenKey = 'daam_auth_token';
  static const _userIdKey = 'daam_user_id';
  static const _userNameKey = 'daam_user_name';
  static const _userEmailKey = 'daam_user_email';
  static const _userRoleKey = 'daam_user_role';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    final role = prefs.getString(_userRoleKey);

    if (token == null || userId == null || name == null || email == null || role == null) {
      return null;
    }
    return {
      'token': token,
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }
}

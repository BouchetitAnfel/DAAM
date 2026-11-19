import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../services/api_client.dart';

/// Holds the authenticated user (id, name, role, token). null = logged out.
class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  Future<void> login(String email, String password) async {
    final data = await ApiClient.instance.request('POST', '/api/auth/login',
        body: {'email': email, 'password': password});
    state = AuthUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> register(
      String name, String email, String password, String role) async {
    final data = await ApiClient.instance.request('POST', '/api/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        });
    state = AuthUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance
          .request('POST', '/api/auth/logout', token: state?.token);
    } catch (_) {
      // even if the call fails, clear the local session
    }
    state = null;
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

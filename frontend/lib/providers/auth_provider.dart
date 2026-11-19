import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../models/user.dart';
import '../services/token_storage.dart';
import 'core_providers.dart';

/// État d'authentification exposé à toute l'application.
class AuthState {
  final AppUser? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isInitializing; // true pendant la restauration de session au démarrage

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isInitializing = true,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    AppUser? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isInitializing,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearUser ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState()) {
    _restoreSession();
  }

  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<void> _restoreSession() async {
    final saved = await _storage.getSavedSession();
    if (saved != null) {
      state = state.copyWith(
        user: AppUser(
          id: saved['id'] as int,
          name: saved['name'] as String,
          email: saved['email'] as String,
          role: saved['role'] as String,
        ),
        token: saved['token'] as String,
        isInitializing: false,
      );
    } else {
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(authServiceProvider).login(email: email, password: password);
      await _storage.saveSession(
        token: result.token,
        userId: result.user.id,
        name: result.user.name,
        email: result.user.email,
        role: result.user.role,
      );
      state = state.copyWith(user: result.user, token: result.token, isLoading: false);
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Échec de la connexion. Réessaie.';
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).register(name: name, email: email, password: password, role: role);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Échec de la création du compte. Réessaie.';
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = state.copyWith(clearUser: true, isInitializing: false);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

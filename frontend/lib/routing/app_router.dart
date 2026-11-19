import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/client/client_dashboard_screen.dart';
import '../screens/pharmacist/pharmacist_dashboard_screen.dart';
import '../screens/splash_screen.dart';

/// Router unique de l'app. La redirection applique les règles :
/// - session en cours de restauration -> /splash
/// - non connecté -> /login (sauf /register)
/// - connecté -> dashboard correspondant au rôle (pharmacist/client),
///   avec garde pour empêcher un client d'ouvrir les écrans pharmacien et inversement.
///
/// `ref.watch(authControllerProvider)` ci-dessous fait recréer le GoRouter à
/// chaque changement d'état d'authentification : c'est volontaire, on veut
/// repartir d'une pile de navigation propre après un login/logout.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      if (authState.isInitializing) {
        return onSplash ? null : '/splash';
      }

      if (!authState.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      // Authentifié : ne doit plus voir splash/login/register.
      final homeRoute = authState.user!.isPharmacist ? '/pharmacist' : '/client';
      if (onSplash || loggingIn) return homeRoute;

      final isOnPharmacistArea = state.matchedLocation.startsWith('/pharmacist');
      final isOnClientArea = state.matchedLocation.startsWith('/client');
      if (isOnPharmacistArea && !authState.user!.isPharmacist) return homeRoute;
      if (isOnClientArea && !authState.user!.isClient) return homeRoute;

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/pharmacist', builder: (context, state) => const PharmacistDashboardScreen()),
      GoRoute(path: '/client', builder: (context, state) => const ClientDashboardScreen()),
    ],
  );
});

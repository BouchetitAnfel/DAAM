import 'dart:io' show Platform;

/// Adresse du backend Express/Node.js (port 3000, voir bin/www).
///
/// - Émulateur Android : 10.0.2.2 pointe vers le "localhost" de la machine hôte.
/// - Simulateur iOS / Web / Desktop : localhost fonctionne directement.
/// Pour un appareil physique, remplace par l'IP locale de ta machine (ex: 192.168.1.X).
class ApiConstants {
  ApiConstants._();

  static const int port = 3000;

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port/api';
    }
    return 'http://localhost:$port/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Products
  static const String products = '/products';

  // Orders
  static const String orders = '/orders';

  // Users
  static const String profile = '/users/profile';
  static const String avatar = '/users/avatar';
}

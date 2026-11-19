import 'dart:io' show Platform;

/// ====== CHANGE THIS PART ONLY ======
/// Port of your Express server (bin/www).
const int kPort = 3000;

/// true  -> server runs HTTPS with a self-signed certificate (your SSL setup)
/// false -> server runs plain HTTP
const bool kUseHttps = true;

/// Physical phone? Put your PC's LAN IP here (ipconfig -> IPv4), e.g. '192.168.1.15'.
/// Leave null when using the Android emulator / iOS simulator.
const String? kPhysicalDeviceHost = null;
/// ====================================

String get kHost {
  if (kPhysicalDeviceHost != null) return kPhysicalDeviceHost!;
  // Android emulator: "localhost" is the emulator itself, the PC is 10.0.2.2
  if (Platform.isAndroid) return '10.0.2.2';
  return 'localhost';
}

String get kBaseUrl => '${kUseHttps ? 'https' : 'http'}://$kHost:$kPort';

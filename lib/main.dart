import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'screens/client_home.dart';
import 'screens/login_screen.dart';
import 'screens/pharmacist_dashboard.dart';

void main() => runApp(const ProviderScope(child: PharmaApp()));

class PharmaApp extends StatelessWidget {
  const PharmaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pharma',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const _Root(),
      );
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const LoginScreen();
    return user.isPharmacist
        ? const PharmacistDashboard()
        : const ClientHome();
  }
}

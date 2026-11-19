import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/loading_view.dart';

/// Écran affiché pendant la restauration de la session (lecture du token
/// persisté) au tout premier lancement de l'app.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy_rounded, color: AppColors.primaryGreen, size: 64),
            SizedBox(height: 16),
            Text('DAAM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
            SizedBox(height: 32),
            LoadingView(),
          ],
        ),
      ),
    );
  }
}

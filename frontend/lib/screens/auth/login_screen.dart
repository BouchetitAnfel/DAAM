import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    // La redirection vers le bon dashboard est gérée par GoRouter (voir routing/app_router.dart)
    // dès que authControllerProvider.isAuthenticated devient vrai — rien à faire ici si succès.
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Connexion impossible.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _DaamLogo(),
                const SizedBox(height: 28),
                const Text(
                  'Bon retour 👋',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Connecte-toi pour gérer tes médicaments en toute simplicité.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'L\'email est requis.';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value.trim())) return 'Email invalide.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Mot de passe',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Le mot de passe est requis.';
                    if (value.length < 6) return '6 caractères minimum.';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Se connecter',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pas encore de compte ?", style: TextStyle(color: AppColors.muted)),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Créer un compte'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DaamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.local_pharmacy_rounded, color: AppColors.white, size: 30),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DAAM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
            Text('Pharmacy Management', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }
}

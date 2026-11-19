import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _role = 'client';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _role,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès. Connecte-toi.'), backgroundColor: AppColors.primaryGreen),
      );
      context.pop();
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Inscription impossible.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rejoins DAAM',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crée ton compte en tant que pharmacien ou client.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nom complet',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Le nom est requis.' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirmer le mot de passe',
                  controller: _confirmController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas.';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Je suis :', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleOption(
                        label: 'Client',
                        icon: Icons.shopping_bag_outlined,
                        selected: _role == 'client',
                        onTap: () => setState(() => _role = 'client'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleOption(
                        label: 'Pharmacien',
                        icon: Icons.local_pharmacy_outlined,
                        selected: _role == 'pharmacist',
                        onTap: () => setState(() => _role = 'pharmacist'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Créer le compte',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ?', style: TextStyle(color: AppColors.muted)),
                    TextButton(onPressed: () => context.pop(), child: const Text('Se connecter')),
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

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.border, width: selected ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primaryGreen : AppColors.muted),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primaryGreen : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

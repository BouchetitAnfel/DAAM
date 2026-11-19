import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Champ de formulaire standard de l'app, avec label, icône et validation.
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.hint,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscured : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon, color: AppColors.primaryGreen),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}

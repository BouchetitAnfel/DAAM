import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Formulaire d'ajout de produit — POST /api/products (pharmacien uniquement,
/// voir middleware isPharmacist dans routes/products.js).
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final error = await ref.read(productListProvider.notifier).addProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.replaceAll(',', '.')),
          quantity: int.parse(_quantityController.text),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté avec succès.'), backgroundColor: AppColors.primaryGreen),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nom du médicament',
                controller: _nameController,
                prefixIcon: Icons.medication_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Le nom est requis.' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'La description est requise.' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Prix (DA)',
                controller: _priceController,
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Le prix est requis.';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Prix invalide.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Quantité disponible',
                controller: _quantityController,
                prefixIcon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'La quantité est requise.';
                  if (int.tryParse(v) == null) return 'Quantité invalide.';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              AppButton(label: 'Enregistrer le produit', isLoading: _isSaving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/products_provider.dart';

/// Used for both "Add" (product == null) and "Edit".
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});
  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _desc = TextEditingController(text: widget.product?.description);
  late final _price =
      TextEditingController(text: widget.product?.price.toString());
  late final _qty =
      TextEditingController(text: widget.product?.quantity.toString());
  bool _loading = false;
  String? _error;

  bool get _editing => widget.product != null;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final p = Product(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      price: double.parse(_price.text.trim().replaceAll(',', '.')),
      quantity: int.parse(_qty.text.trim()),
    );
    try {
      final n = ref.read(productsProvider.notifier);
      if (_editing) {
        await n.edit(widget.product!.id!, p);
      } else {
        await n.add(p);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit product' : 'New product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Price (DA)', border: OutlineInputBorder()),
                  validator: (v) {
                    final x = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                    if (x == null || x < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Quantity in stock',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    final x = int.tryParse((v ?? '').trim());
                    if (x == null || x < 0) return 'Enter a valid quantity';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_editing ? 'Save changes' : 'Add product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

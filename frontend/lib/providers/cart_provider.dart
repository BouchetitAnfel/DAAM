import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

/// Une ligne du panier : un produit + la quantité choisie par le client.
class CartLine {
  final Product product;
  final int quantity;
  const CartLine({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartLine copyWith({int? quantity}) => CartLine(product: product, quantity: quantity ?? this.quantity);
}

/// Panier local (côté client), vidé après une commande réussie.
/// Le backend ne connaît pas le panier : il ne reçoit que la liste finale
/// d'items lors de POST /api/orders.
class CartController extends StateNotifier<List<CartLine>> {
  CartController() : super(const []);

  void addProduct(Product product) {
    final index = state.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      state = [...state, CartLine(product: product, quantity: 1)];
    } else {
      final current = state[index];
      final maxQty = product.quantity;
      if (current.quantity >= maxQty) return;
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) current.copyWith(quantity: current.quantity + 1) else state[i],
      ];
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final line in state)
        if (line.product.id == productId) line.copyWith(quantity: quantity) else line,
    ];
  }

  void removeProduct(int productId) {
    state = state.where((line) => line.product.id != productId).toList();
  }

  void clear() => state = const [];

  double get totalPrice => state.fold(0, (sum, line) => sum + line.subtotal);
}

final cartProvider = StateNotifierProvider<CartController, List<CartLine>>((ref) => CartController());

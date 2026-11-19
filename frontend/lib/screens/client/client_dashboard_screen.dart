import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../orders/cart_tab.dart';
import '../orders/order_history_tab.dart';
import 'catalogue_tab.dart';

/// Shell du Client Dashboard : navigation inférieure entre Catalogue,
/// Panier et Historique des commandes.
class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _index = 0;

  static const _tabs = [CatalogueTab(), CartTab(), OrderHistoryTab()];
  static const _titles = ['Catalogue', 'Mon panier', 'Mes commandes'];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_outlined), label: 'Catalogue'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Panier',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Commandes'),
        ],
      ),
    );
  }
}

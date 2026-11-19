import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../providers/core_providers.dart';
import '../../widgets/loading_view.dart';

/// Onglet "Commandes" : historique des commandes du client (GET /api/orders).
class OrderHistoryTab extends ConsumerStatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  ConsumerState<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends ConsumerState<OrderHistoryTab> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(orderServiceProvider).fetchOrderHistory();
  }

  void _reload() {
    setState(() => _future = ref.read(orderServiceProvider).fetchOrderHistory());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(message: snapshot.error.toString(), onRetry: _reload);
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(
            child: Text('Aucune commande pour le moment.', style: TextStyle(color: AppColors.muted)),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Commande #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)),
                            child: Text(order.status, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('${item.quantity} x ${item.name}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Total : ${order.totalPrice.toStringAsFixed(2)} DA',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

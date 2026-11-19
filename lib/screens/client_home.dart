import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Placeholder - client dashboard comes in Exercise 03+.
class ClientHome extends ConsumerWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: const Center(child: Text('Client dashboard (next exercises)')),
    );
  }
}

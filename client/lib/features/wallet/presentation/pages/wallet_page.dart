import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirpay/core/widgets/app_async_view.dart';
import 'package:nirpay/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:nirpay/features/wallet/presentation/widgets/wallet_list_item.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final controller = ref.read(walletControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Wallet')),
      body: AppAsyncView(
        value: walletState,
        onRetry: () => ref.invalidate(walletControllerProvider),
        data: (items) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return WalletListItem(
                item: item,
                onDelete: () => controller.removeItem(item.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addSampleItem,
        label: Text('Add'),
        icon: Icon(Icons.add),
      ),
    );
  }
}

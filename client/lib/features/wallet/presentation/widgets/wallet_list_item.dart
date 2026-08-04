import 'package:flutter/material.dart';
import 'package:nirpay/features/wallet/domain/entities/wallet_item.dart';

class WalletListItem extends StatelessWidget {
  const WalletListItem({super.key, required this.item, required this.onDelete});

  final WalletItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text('Created: ${item.createdAt.toLocal()}'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

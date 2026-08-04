import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_page.dart';

class HistoryPage extends ConsumerStatefulWidget {
  HistoryPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildSearchAndFilter(colors),
              const SizedBox(height: 16),
              _buildFilterChips(colors),
              const SizedBox(height: 16),
              _buildOverviewCard(colors),
              const SizedBox(height: 20),
              Expanded(child: _buildTransactionList(colors)),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppColorsExtension colors) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        onPressed: widget.onBack,
      ),
      title: Text(
        'Riwayat Transaksi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.textSecondary, width: 1.5),
            ),
            child: Icon(
              Icons.question_mark_rounded,
              color: colors.textPrimary,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilter(AppColorsExtension colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                hintText: 'Cari Transaksi',
                hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: colors.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(AppColorsExtension colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Semua', colors),
          const SizedBox(width: 8),
          _buildChip('Masuk', colors),
          const SizedBox(width: 8),
          _buildChip('Keluar', colors),
        ],
      ),
    );
  }

  Widget _buildChip(String label, AppColorsExtension colors) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withValues(alpha: 0.1) : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AppColorsExtension colors) {
    final allTxAsync = ref.watch(allTransactionsProvider);

    return allTxAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (transactions) {
        if (transactions.isEmpty) return const SizedBox.shrink();

        final totalIn = transactions
            .where((t) => t.direction == 'CREDIT')
            .fold<double>(0, (sum, t) => sum + t.amountCent / 100);
        final totalOut = transactions
            .where((t) => t.direction == 'DEBIT')
            .fold<double>(0, (sum, t) => sum + t.amountCent / 100);
        final totalTx = transactions.length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Baris atas: jumlah transaksi
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$totalTx Transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Baris bawah: pemasukan & pengeluaran
              Row(
                children: [
                  Expanded(
                    child: _overviewStat(
                      colors: colors,
                      icon: Icons.arrow_downward_rounded,
                      iconColor: colors.success,
                      label: 'Masuk',
                      value: '+Rp ${_formatAmount(totalIn)}',
                      valueColor: colors.success,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colors.border,
                  ),
                  Expanded(
                    child: _overviewStat(
                      colors: colors,
                      icon: Icons.arrow_upward_rounded,
                      iconColor: colors.error,
                      label: 'Keluar',
                      value: '-Rp ${_formatAmount(totalOut)}',
                      valueColor: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _overviewStat({
    required AppColorsExtension colors,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return NumberFormat('#,###').format(amount.toInt());
    }
    return NumberFormat('#,###.##').format(amount);
  }

  Widget _buildTransactionList(AppColorsExtension colors) {
    final allTxAsync = ref.watch(allTransactionsProvider);

    return allTxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (transactions) {
        // Filter transactions
        var filteredTx = transactions;
        if (_selectedFilter == 'Masuk') {
          filteredTx = transactions.where((t) => t.direction == 'CREDIT').toList();
        } else if (_selectedFilter == 'Keluar') {
          filteredTx = transactions.where((t) => t.direction == 'DEBIT').toList();
        }

        if (filteredTx.isEmpty) {
          return Center(
            child: Text(
              'Belum ada transaksi',
              style: TextStyle(color: colors.textSecondary),
            ),
          );
        }

        // Kelompokkan berdasarkan tanggal
        final groupedTx = <String, List<TransactionEntry>>{};
        for (var tx in filteredTx) {
          final dateKey = '${tx.createdAt.day} ${_getMonth(tx.createdAt.month)} ${tx.createdAt.year}';
          if (!groupedTx.containsKey(dateKey)) {
            groupedTx[dateKey] = [];
          }
          groupedTx[dateKey]!.add(tx);
        }

        final dateKeys = groupedTx.keys.toList();

        return ListView.builder(
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateKey = dateKeys[index];
            final txList = groupedTx[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label Tanggal / Header per hari
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // List Transaksi di hari tersebut
                ...txList.map((tx) {
                  final isCredit = tx.direction == 'CREDIT';
                  final amount = tx.amountCent / 100;
                  final amountStr = '${isCredit ? '+' : '-'}Rp ${_formatAmount(amount)}';

                  final timeStr = '${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}';

                  String title = 'Transaksi';
                  if (tx.txType == 'TOPUP') title = 'Top Up Saldo';
                  if (tx.txType == 'TRANSFER') title = isCredit ? 'Terima Saldo' : 'Kirim Saldo';

                  return _buildTransactionItem(
                    colors: colors,
                    tx: tx,
                    isCredit: isCredit,
                    title: title,
                    time: timeStr,
                    amount: amountStr,
                  );
                }),

                // Jarak antar kelompok hari
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  Widget _buildTransactionItem({
    required AppColorsExtension colors,
    required TransactionEntry tx,
    required bool isCredit,
    required String title,
    required String time,
    required String amount,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(transaction: tx),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit
                  ? colors.success.withValues(alpha: 0.1)
                  : colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? colors.success : colors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isCredit ? colors.success : colors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colors.textSecondary,
          ),
        ],
      ),
      ),
    );
  }
}

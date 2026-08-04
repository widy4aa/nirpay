import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../features/wallet/presentation/providers/wallet_balance_provider.dart';
import '../../../../features/transaction/presentation/providers/transaction_provider.dart';
import '../../../../features/wallet/data/services/wallet_sync_service.dart';
import '../providers/last_sync_provider.dart';

class StatusSyncPage extends ConsumerStatefulWidget {
  const StatusSyncPage({super.key});

  @override
  ConsumerState<StatusSyncPage> createState() => _StatusSyncPageState();
}

class _StatusSyncPageState extends ConsumerState<StatusSyncPage> {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  Future<void> _doSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      await ref.read(walletSyncServiceProvider).syncBalance();
      ref.read(lastSyncProvider.notifier).updateLastSync();
      if (mounted) {
        setState(() => _lastSyncTime = DateTime.now());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sinkronisasi berhasil'),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi: $e'),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnlineAsync = ref.watch(networkConnectivityProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final isOnline = isOnlineAsync.value ?? false;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _doSync,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status jaringan
              _buildNetworkBanner(isOnline),
              const SizedBox(height: 20),

              // Kartu saldo
              balanceAsync.when(
                data: (balance) => _buildBalanceCard(balance, isOnline),
                loading: () => _buildBalanceCard(null, isOnline),
                error: (_, __) => _buildBalanceCard(null, isOnline),
              ),
              const SizedBox(height: 20),

              // Statistik sync
              transactionsAsync.when(
                data: (txs) => _buildSyncStats(txs),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              // Tombol sync manual
              _buildSyncButton(isOnline),
              const SizedBox(height: 24),

              // Riwayat transaksi
              Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              transactionsAsync.when(
                data: (txs) => _buildTransactionList(txs),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Status Sinkronisasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  // ─── Network Banner ───

  Widget _buildNetworkBanner(bool isOnline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isOnline
            ? context.colors.success.withOpacity(0.08)
            : context.colors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOnline
              ? context.colors.success.withOpacity(0.3)
              : context.colors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline ? context.colors.success : context.colors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Online — Terhubung ke server' : 'Offline — Tidak ada koneksi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? context.colors.success : context.colors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Data dapat disinkronkan ke server'
                      : 'Transaksi disimpan lokal, sync otomatis saat online',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            color: isOnline ? context.colors.success : context.colors.error,
            size: 28,
          ),
        ],
      ),
    );
  }

  // ─── Balance Card ───

  Widget _buildBalanceCard(WalletBalanceEntry? balance, bool isOnline) {
    final amount = balance != null ? (balance.amountCent - balance.reservedCent) / 100 : 0.0;
    final reserved = balance != null ? balance.reservedCent / 100 : 0.0;
    final hopCount = balance?.hopCount ?? 0;
    final maxHop = balance?.maxHop ?? 3;

    // Hop status
    final isHopFull = hopCount >= maxHop;
    final isHopWarning = hopCount >= maxHop - 1 && !isHopFull;
    final hopBgColor = isHopFull
        ? context.colors.error.withValues(alpha: 0.85)
        : isHopWarning
            ? const Color(0xFFFF9500).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.2);
    final hopIcon = isHopFull
        ? Icons.warning_rounded
        : isHopWarning
            ? Icons.error_outline_rounded
            : Icons.swap_horiz_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Saat Ini',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hopBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(hopIcon, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      isHopFull ? 'Hop Penuh!' : 'Hop $hopCount/$maxHop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatAmount(amount)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (reserved > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Rp ${_formatAmount(reserved)} dicadangkan',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
          // Hop warning banner
          if (isHopFull) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.sync_problem_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transfer offline penuh. Tekan "Sinkronisasi Sekarang" untuk reset hop.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isHopWarning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sisa 1 transfer offline lagi. Sync untuk reset.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Hop progress bar
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transfer Offline',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '$hopCount / $maxHop',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxHop > 0 ? hopCount / maxHop : 0.0,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHopFull
                          ? context.colors.error
                          : isHopWarning
                              ? const Color(0xFFFF9500)
                              : Colors.white,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _lastSyncTime != null
                      ? 'Terakhir sync: ${_formatDateTime(_lastSyncTime!)}'
                      : isOnline
                          ? 'Siap sinkronisasi'
                          : 'Belum tersinkron — data aman di perangkat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sync Stats ───

  Widget _buildSyncStats(List<TransactionEntry> txs) {
    final synced = txs.where((t) => t.syncStatus == 'SYNCED').length;
    final pending = txs.where((t) => t.syncStatus == 'PENDING').length;
    final failed = txs.where((t) => t.syncStatus == 'FAILED').length;
    final total = txs.length;

    return Row(
      children: [
        Expanded(child: _statChip('Total', total.toString(), context.colors.textPrimary, Icons.receipt_long_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statChip('Tersync', synced.toString(), context.colors.success, Icons.check_circle_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statChip('Pending', pending.toString(), context.colors.warning, Icons.schedule_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statChip('Gagal', failed.toString(), context.colors.error, Icons.error_rounded)),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sync Button ───

  Widget _buildSyncButton(bool isOnline) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isOnline && !_isSyncing ? _doSync : null,
        icon: _isSyncing
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.sync_rounded, size: 20),
        label: Text(
          _isSyncing ? 'Menyinkronkan...' : 'Sinkronisasi Sekarang',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.colors.border,
          disabledForegroundColor: context.colors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ─── Transaction List ───

  Widget _buildTransactionList(List<TransactionEntry> txs) {
    if (txs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 40, color: context.colors.border),
            const SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: txs.map((tx) => _buildTransactionItem(tx)).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionEntry tx) {
    final isCredit = tx.direction == 'CREDIT';
    final amount = tx.amountCent / 100;
    final isSynced = tx.syncStatus == 'SYNCED';
    final isPending = tx.syncStatus == 'PENDING';
    final isFailed = tx.syncStatus == 'FAILED';

    // Icon & warna berdasarkan tipe
    IconData txIcon;
    String txTitle;
    if (tx.txType == 'TOPUP') {
      txIcon = Icons.account_balance_wallet_rounded;
      txTitle = 'Top Up';
    } else if (tx.txType == 'TRANSFER') {
      txIcon = isCredit ? Icons.call_received_rounded : Icons.send_rounded;
      txTitle = isCredit ? 'Terima Saldo' : 'Kirim Saldo';
    } else {
      txIcon = Icons.swap_horiz_rounded;
      txTitle = 'Transaksi';
    }

    // Warna status sync
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    if (isSynced) {
      statusColor = context.colors.success;
      statusLabel = 'Tersinkron';
      statusIcon = Icons.check_circle_rounded;
    } else if (isFailed) {
      statusColor = context.colors.error;
      statusLabel = 'Gagal';
      statusIcon = Icons.error_rounded;
    } else {
      statusColor = context.colors.warning;
      statusLabel = 'Pending';
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Ikon transaksi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredit
                  ? context.colors.success.withOpacity(0.1)
                  : context.colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              txIcon,
              color: isCredit ? context.colors.success : context.colors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Detail transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDateTime(tx.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Kolom kanan: nominal + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}Rp ${_formatAmount(amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isCredit ? context.colors.success : context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return NumberFormat('#,###').format(amount.toInt());
    }
    return NumberFormat('#,###.##').format(amount);
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return DateFormat('d MMM yyyy, HH:mm').format(dt);
  }
}

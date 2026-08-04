import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../core/widgets/pin_verification_sheet.dart';
import '../../../../features/transaction/presentation/providers/transaction_provider.dart';
import '../providers/wallet_balance_provider.dart';
import '../../data/services/wallet_sync_service.dart';
import '../../../sync/presentation/providers/last_sync_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    if (mounted) {
      setState(() {
        _currentTime = '$h:$m:$s';
      });
    }
  }

  String get _lastSyncText {
    final lastSync = ref.read(lastSyncProvider);
    if (lastSync == null) return 'Belum pernah sync';

    final now = DateTime.now();
    final diff = now.difference(lastSync);

    if (diff.inMinutes < 1) return 'Baru saja sync';
    if (diff.inMinutes < 60) return 'Sync ${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return 'Sync ${diff.inHours} jam lalu';
    if (diff.inDays < 7) return 'Sync ${diff.inDays} hari lalu';

    return 'Sync ${lastSync.day}/${lastSync.month}/${lastSync.year}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final user = ref.watch(currentUserProvider);
    final isOnlineAsync = ref.watch(networkConnectivityProvider);

    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'User';
    final userInitial = user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U';
    final isOnline = isOnlineAsync.value ?? false;

    // Log data yang ditampilkan
    FlowLogger.page('HomePage', data: {
      'user': userName,
      'email': user?.email ?? '-',
      'kycStatus': user?.kycStatus ?? '-',
    });
    balanceAsync.whenData((balance) {
      if (balance != null) {
        FlowLogger.data('Saldo', {
          'amount': 'Rp ${((balance.amountCent - balance.reservedCent) / 100).toStringAsFixed(0)}',
          'currency': balance.currency,
        });
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(walletSyncServiceProvider).syncBalance();
            ref.read(lastSyncProvider.notifier).updateLastSync();
          },
          child: CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      _buildHeader(userName, userInitial),
                      const SizedBox(height: 24),
                      balanceAsync.when(
                        data: (balance) => _buildWalletCard(
                          balance?.amountCent ?? 0,
                          balance?.reservedCent ?? 0,
                          balance?.hopCount ?? 0,
                          balance?.maxHop ?? 3,
                          isOnline,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String userInitial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pushNamed(AppRouteNames.deviceStatus),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.border,
                backgroundImage: null,
                child: Text(
                  userInitial,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Halo, ',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: _currentTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: context.colors.textPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: context.colors.error, size: 20),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: context.colors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout'),
        content: Text(
          'Semua data lokal akan dihapus. Anda harus login ulang dengan internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final router = GoRouter.of(context);
              nav.pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (mounted) {
                router.goNamed(AppRouteNames.login);
              }
            },
            child: Text('Logout', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(int amountCent, int reservedCent, int hopCount, int maxHop, bool isOnline) {
    // Basic formatting logic
    final availableAmount = (amountCent - reservedCent) / 100;

    // Hop status logic
    final isHopFull = hopCount >= maxHop;
    final isHopWarning = hopCount >= maxHop - 1 && !isHopFull;
    final hopBgColor = isHopFull
        ? context.colors.error.withValues(alpha: 0.85)
        : isHopWarning
            ? const Color(0xFFFF9500).withValues(alpha: 0.85) // orange
            : Colors.white.withValues(alpha: 0.2);
    final hopIcon = isHopFull
        ? Icons.warning_rounded
        : isHopWarning
            ? Icons.error_outline_rounded
            : Icons.network_check_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
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
                'Saldo Tersedia',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hopBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      hopIcon,
                      color: Colors.white,
                      size: 14,
                    ),
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
            'Rp ${availableAmount.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                      'Transfer offline penuh. Sync untuk reset hop.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Hop progress bar
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$hopCount / $maxHop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Sinkronisasi',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? Color(0xFF4CAF50) : context.colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online (Tersinkron)' : 'Offline (Belum Tersinkron)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Last sync time
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                _lastSyncText,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        // 2 tombol besar: Kirim & Terima
        Row(
          children: [
            Expanded(
              child: _buildPrimaryAction(
                icon: Icons.send_to_mobile_rounded,
                label: 'Kirim',
                color: context.colors.primary,
                onTap: () async {
                  final router = GoRouter.of(context);
                  final ok = await PinVerificationSheet.show(context);
                  if (ok && mounted) router.pushNamed(AppRouteNames.sendMoney);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPrimaryAction(
                icon: Icons.call_received_rounded,
                label: 'Terima',
                color: context.colors.success,
                onTap: () async {
                  final router = GoRouter.of(context);
                  final ok = await PinVerificationSheet.show(context);
                  if (ok && mounted) router.pushNamed(AppRouteNames.receiveMoney);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 4 tombol kecil
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Top Up',
                color: context.colors.warning,
                onTap: () async {
                  final router = GoRouter.of(context);
                  final ok = await PinVerificationSheet.show(context);
                  if (ok && mounted) router.pushNamed(AppRouteNames.topUp);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.money_off_rounded,
                label: 'Withdraw',
                color: context.colors.error,
                onTap: () async {
                  final router = GoRouter.of(context);
                  final ok = await PinVerificationSheet.show(context);
                  if (ok && mounted) router.pushNamed(AppRouteNames.withdraw);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.sync_rounded,
                label: 'Sync',
                color: context.colors.primary,
                onTap: () async {
                  final router = GoRouter.of(context);
                  final ok = await PinVerificationSheet.show(context);
                  if (ok && mounted) router.pushNamed(AppRouteNames.statusSync);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.nfc_rounded,
                label: 'Tap to Pay',
                color: context.colors.textSecondary,
                isDisabled: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur Tap to Pay akan tersedia di update berikutnya. Gunakan menu Kirim untuk transfer NFC.'),
                      backgroundColor: context.colors.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTxAsync = ref.watch(recentTransactionsProvider);

    return recentTxAsync.when(
      loading: () => SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $error')),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = transactions[index];
                final isCredit = tx.direction == 'CREDIT';

                // Format amount
                final amount = tx.amountCent / 100;
                final amountStr = '${isCredit ? '+' : '-'}Rp ${amount.toStringAsFixed(0)}';

                // Format date (contoh: 29 Jul 2026, 14:30)
                final dateStr = '${tx.createdAt.day} ${_getMonth(tx.createdAt.month)} ${tx.createdAt.year}, ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}';

                // Judul berdasarkan tipe transaksi
                String title = 'Transaksi';
                if (tx.txType == 'TOPUP') title = 'Top Up Saldo';
                if (tx.txType == 'TRANSFER') title = isCredit ? 'Terima Saldo' : 'Kirim Saldo';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? context.colors.success.withValues(alpha: 0.1)
                              : context.colors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? context.colors.success : context.colors.error,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        amountStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isCredit ? context.colors.success : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: transactions.length,
            ),
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/wallet_balance_provider.dart';
import '../../data/services/wallet_sync_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletSyncServiceProvider).syncBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(walletSyncServiceProvider).syncBalance();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      balanceAsync.when(
                        data: (balance) => _buildWalletCard(
                          balance?.amountCent ?? 0,
                          balance?.reservedCent ?? 0,
                          balance?.hopCount ?? 0,
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E24),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pushNamed(AppRouteNames.deviceStatus),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE2E6EE),
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7D8C9E),
                  ),
                ),
                Text(
                  'Budi Santoso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E24),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF1E1E24)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E1E24)),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(int amountCent, int reservedCent, int hopCount) {
    // Basic formatting logic
    final availableAmount = (amountCent - reservedCent) / 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF009CFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009CFF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Tersedia',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.network_check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hop $hopCount/3',
                      style: const TextStyle(
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Online (Tersinkron)',
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
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.send_to_mobile_rounded,
          label: 'Kirim',
          color: const Color(0xFF009CFF),
          onTap: () => context.pushNamed(AppRouteNames.sendMoney),
        ),
        _buildActionItem(
          icon: Icons.call_received_rounded,
          label: 'Terima',
          color: const Color(0xFF26644A),
          onTap: () => context.pushNamed(AppRouteNames.receiveMoney),
        ),
        _buildActionItem(
          icon: Icons.nfc_rounded,
          label: 'Tap to Pay',
          color: const Color(0xFFFF9500),
          onTap: () => context.pushNamed(AppRouteNames.nfcTransfer),
        ),
        _buildActionItem(
          icon: Icons.history_rounded,
          label: 'Riwayat',
          color: const Color(0xFF6B7280),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    // Placeholder list
    final transactions = [
      {'title': 'Kirim ke Budi', 'amount': '-Rp 50.000', 'date': 'Hari ini, 14:30', 'isCredit': false},
      {'title': 'Terima dari Andi', 'amount': '+Rp 100.000', 'date': 'Kemarin, 09:15', 'isCredit': true},
      {'title': 'Top up via Bank', 'amount': '+Rp 500.000', 'date': '10 Jul 2026', 'isCredit': true},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = transactions[index];
            final isCredit = tx['isCredit'] as bool;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E6EE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCredit 
                          ? const Color(0xFF26644A).withValues(alpha: 0.1) 
                          : const Color(0xFFD63C42).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: isCredit ? const Color(0xFF26644A) : const Color(0xFFD63C42),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx['date'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7D8C9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    tx['amount'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isCredit ? const Color(0xFF26644A) : const Color(0xFF1E1E24),
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
  }
}

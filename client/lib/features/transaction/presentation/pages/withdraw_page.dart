import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' as drift;
import 'package:nirpay/core/database/app_database.dart';
import 'package:nirpay/core/database/database_service.dart';
import 'package:nirpay/core/theme/app_colors.dart';
import 'package:nirpay/core/widgets/pin_verification_sheet.dart';
import 'package:nirpay/features/auth/presentation/providers/auth_providers.dart';
import 'package:nirpay/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:nirpay/features/wallet/data/services/wallet_sync_service.dart';
import 'package:nirpay/features/wallet/presentation/providers/wallet_balance_provider.dart';
import 'package:nirpay/features/transaction/presentation/pages/send_money_page.dart';

enum WithdrawMethod { online, offline }

class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  WithdrawMethod? _selectedMethod;
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountFocus = FocusNode();
  bool _isSubmitting = false;

  String? _selectedPaymentMethod;
  final _quickAmounts = [50000, 100000, 200000, 500000, 1000000];

  final _bankMethods = [
    {'code': 'BCA', 'name': 'BCA', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF0033A0)},
    {'code': 'MANDIRI', 'name': 'Mandiri', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF003D79)},
    {'code': 'BRI', 'name': 'BRI', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF003D79)},
    {'code': 'BNI', 'name': 'BNI', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF003D79)},
  ];

  final _ewalletMethods = [
    {'code': 'GOPAY', 'name': 'GoPay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF00AAEF)},
    {'code': 'OVO', 'name': 'OVO', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF4C3494)},
    {'code': 'DANA', 'name': 'DANA', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF108EE9)},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  int _getParsedAmount() {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  Future<void> _submitWithdraw() async {
    final amount = _getParsedAmount();
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimal withdraw Rp 10.000'), backgroundColor: context.colors.warning),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih metode pencairan'), backgroundColor: context.colors.warning),
      );
      return;
    }

    if (_accountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nomor rekening / akun'), backgroundColor: context.colors.warning),
      );
      return;
    }

    // PIN verification
    final pinOk = await PinVerificationSheet.show(context);
    if (!mounted || pinOk != true) return;

    setState(() => _isSubmitting = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final currentUser = ref.read(currentUserProvider);
      final remoteDatasource = ref.read(walletRemoteDatasourceProvider);

      // Kirim request ke backend
      final result = await remoteDatasource.withdraw(
        amountCent: amount * 100,
        method: _selectedPaymentMethod!,
        accountNumber: _accountController.text.trim(),
      );
      final txId = result['txId'] as String;

      // Simpan transaksi ke local DB (PENDING, saldo sudah di-reserve server)
      await db.insertTransaction(
        TransactionsCompanion(
          id: drift.Value(txId),
          txId: drift.Value(txId),
          direction: const drift.Value('DEBIT'),
          txType: const drift.Value('WITHDRAW'),
          amountCent: drift.Value(amount * 100),
          syncStatus: const drift.Value('PENDING'),
          counterpartyName: drift.Value(_selectedPaymentMethod),
        ),
      );

      // Update local balance (reserve)
      if (currentUser != null) {
        final balance = await db.getWalletBalance(currentUser.id);
        if (balance != null) {
          await (db.update(db.walletBalances)..where((w) => w.userId.equals(currentUser.id))).write(
            WalletBalancesCompanion(
              reservedCent: drift.Value(balance.reservedCent + (amount * 100)),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        }
      }

      ref.invalidate(walletBalanceProvider);

      if (mounted) {
        _showSuccessSheet(amount, txId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal withdraw: $e'), backgroundColor: context.colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessSheet(int amount, String txId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule_rounded, color: context.colors.warning, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdraw Berhasil Dikirim!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              formatRupiah(amount),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: context.colors.warning),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: context.colors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Permintaan withdraw Anda sedang diproses. Saldo sudah di-reserve. Jika ditolak, saldo akan dikembalikan.',
                      style: TextStyle(fontSize: 13, color: context.colors.warning, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TX: $txId',
              style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final balanceAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tarik Saldo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo saat ini
            _buildBalanceCard(colors, balanceAsync),
            const SizedBox(height: 24),

            // Pilih metode withdraw
            _buildSectionHeader('PILIH METODE', Icons.payment_rounded, colors),
            const SizedBox(height: 12),
            _buildMethodCard(
              method: WithdrawMethod.online,
              icon: Icons.language_rounded,
              title: 'Online',
              subtitle: 'Request ke server',
              description: 'Kirim permintaan withdraw ke server. Proses pencairan setelah disetujui.',
              color: colors.primary,
            ),
            const SizedBox(height: 14),
            _buildMethodCard(
              method: WithdrawMethod.offline,
              icon: Icons.nfc_rounded,
              title: 'Offline',
              subtitle: 'Segera Hadir',
              description: 'Withdraw langsung antar device tanpa internet.',
              color: colors.textSecondary,
              isDisabled: true,
            ),
            const SizedBox(height: 24),

            if (_selectedMethod == WithdrawMethod.online) ...[
              // Pilih bank/e-wallet
              _buildSectionHeader('METODE PENCAIRAN', Icons.account_balance_rounded, colors),
              const SizedBox(height: 12),
              Text('Bank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _bankMethods.map((m) => _buildPaymentChip(m, colors)).toList(),
              ),
              const SizedBox(height: 16),
              Text('E-Wallet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _ewalletMethods.map((m) => _buildPaymentChip(m, colors)).toList(),
              ),
              const SizedBox(height: 24),

              // Nomor rekening
              _buildSectionHeader('NOMOR REKENING / AKUN', Icons.confirmation_number_rounded, colors),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nomor rekening / akun',
                    hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nominal
              _buildSectionHeader('NOMINAL WITHDRAW', Icons.attach_money_rounded, colors),
              const SizedBox(height: 12),
              _buildAmountInput(colors),
              const SizedBox(height: 16),
              _buildQuickAmounts(colors),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.warning.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: colors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saldo akan di-reserve saat request. Jika withdraw ditolak, saldo dikembalikan otomatis.',
                        style: TextStyle(fontSize: 13, color: colors.warning, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    disabledBackgroundColor: colors.border,
                  ),
                  child: _isSubmitting
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Tarik ${formatRupiah(_getParsedAmount())}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AppColorsExtension colors, AsyncValue<WalletBalanceEntry?> balanceAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          balanceAsync.when(
            data: (balance) {
              final amount = ((balance?.amountCent ?? 0) - (balance?.reservedCent ?? 0)) / 100;
              return Text(
                'Rp ${amount.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
              );
            },
            loading: () => Text('Memuat...', style: TextStyle(color: Colors.white70, fontSize: 16)),
            error: (_, __) => Text('Rp 0', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, AppColorsExtension colors) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: colors.primary)),
      ],
    );
  }

  Widget _buildMethodCard({
    required WithdrawMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fitur Withdraw $title akan tersedia di update berikutnya.'),
                  backgroundColor: context.colors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          : () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? context.colors.background : context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDisabled ? context.colors.textSecondary : context.colors.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDisabled ? context.colors.warning.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isDisabled ? 'Segera Hadir' : subtitle,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDisabled ? context.colors.warning : color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(fontSize: 12, color: context.colors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            Icon(isDisabled ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded, color: context.colors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentChip(Map<String, dynamic> method, AppColorsExtension colors) {
    final isSelected = _selectedPaymentMethod == method['code'];
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method['code']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? method['color'] : colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? method['color'] : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(method['icon'], size: 18, color: isSelected ? Colors.white : method['color']),
            const SizedBox(width: 8),
            Text(
              method['name'],
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(AppColorsExtension colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text('Rp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _RupiahInputFormatter()],
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.3)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(AppColorsExtension colors) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: _quickAmounts.map((amount) {
        final isSelected = _getParsedAmount() == amount;
        return GestureDetector(
          onTap: () {
            _amountController.text = amount.toString();
            _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
            _amountFocus.requestFocus();
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? colors.error : colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? colors.error : colors.border),
            ),
            child: Text(formatRupiah(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : colors.textPrimary)),
          ),
        );
      }).toList(),
    );
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));

    final buffer = StringBuffer();
    final length = digitsOnly.length;
    for (var i = 0; i < length; i++) {
      buffer.write(digitsOnly[i]);
      final remaining = length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }

    final formatted = buffer.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

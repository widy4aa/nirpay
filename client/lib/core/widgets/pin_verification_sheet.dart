import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import 'pin_input_widget.dart';

class PinVerificationSheet extends ConsumerStatefulWidget {
  PinVerificationSheet({super.key});

  /// Helper untuk memanggil bottom sheet ini dan mengembalikan `true` jika PIN benar
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinVerificationSheet(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PinVerificationSheet> createState() => _PinVerificationSheetState();
}

class _PinVerificationSheetState extends ConsumerState<PinVerificationSheet> {
  final _pinNotifier = ValueNotifier<String>('');
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _pinNotifier.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) async {
    if (_isLoading) return;

    if (_pinNotifier.value.length < 6) {
      _pinNotifier.value += number;
      setState(() => _errorMsg = null); // Hapus pesan error kalau lagi ngetik

      if (_pinNotifier.value.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeleteTap() {
    if (_isLoading) return;

    if (_pinNotifier.value.isNotEmpty) {
      _pinNotifier.value = _pinNotifier.value.substring(0, _pinNotifier.value.length - 1);
      setState(() => _errorMsg = null);
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final isCorrect = await ref.read(authControllerProvider.notifier).checkPinLocal(_pinNotifier.value);

    if (!mounted) return;

    if (isCorrect) {
      // PIN Benar! Tutup bottom sheet dan return true
      context.pop(true);
    } else {
      // PIN Salah!
      _pinNotifier.value = '';
      setState(() {
        _isLoading = false;
        _errorMsg = 'PIN salah. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Verifikasi PIN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Masukkan PIN untuk melanjutkan',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 32),
          if (_isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_errorMsg != null)
            Text(
              _errorMsg!,
              style: TextStyle(
                color: context.colors.error,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox(height: 24), // Placeholder spasi supaya tinggi sama
          const SizedBox(height: 32),
          PinInputWidget(
            pinNotifier: _pinNotifier,
            onNumberTap: _onNumberTap,
            onDeleteTap: _onDeleteTap,
          ),
        ],
      ),
    );
  }
}

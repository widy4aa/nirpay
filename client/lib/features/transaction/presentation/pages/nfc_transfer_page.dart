import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:nirpay/features/wallet/presentation/providers/dummy_wallet_balance_provider.dart';

class NfcTransferPage extends ConsumerStatefulWidget {
  const NfcTransferPage({super.key});

  @override
  ConsumerState<NfcTransferPage> createState() => _NfcTransferPageState();
}

class _NfcTransferPageState extends ConsumerState<NfcTransferPage> {
  static const _hceChannel = MethodChannel('nirpay.com/hce');
  static const _ackTimeout = Duration(seconds: 5);

  Timer? _pollTimer;
  DateTime? _dataSentAt;
  bool _isPolling = false;
  bool _hasDebitedBalance = false;
  String? _transactionId;
  String _status = 'READY_TO_SEND';
  String _feedback = 'tempelkan ke HP penerima';

  @override
  void initState() {
    super.initState();
    _prepareNfcPayload();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _prepareNfcPayload() async {
    _pollTimer?.cancel();
    _dataSentAt = null;
    _transactionId ??= DateTime.now().microsecondsSinceEpoch.toString();

    final payload = jsonEncode({
      'transactionId': _transactionId,
      'amount': dummyTransferAmount,
      'currency': 'IDR',
      'receiverWallet': 'wallet penerima',
      'status': 'DATA_SENT',
      'createdAt': DateTime.now().toIso8601String(),
    });

    try {
      await _hceChannel.invokeMethod('setNfcData', {
        'data': payload,
        'transactionId': _transactionId,
      });

      if (!mounted) return;
      setState(() {
        _status = 'READY_TO_SEND';
        _feedback = 'tempelkan ke HP penerima';
      });

      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 400),
        (_) => unawaited(_pollAckStatus()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'ERROR';
        _feedback = 'gagal mengaktifkan HCE';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyiapkan NFC HCE: $e')));
    }
  }

  Future<void> _pollAckStatus() async {
    if (_isPolling || _transactionId == null) return;
    _isPolling = true;

    try {
      final rawStatus = await _hceChannel.invokeMapMethod<String, Object?>(
        'getNfcTransferStatus',
      );
      final activeTransactionId = rawStatus?['transactionId']?.toString();
      final status = rawStatus?['status']?.toString() ?? 'IDLE';

      if (activeTransactionId != _transactionId || !mounted) return;

      if (status == 'DATA_SENT') {
        _dataSentAt ??= DateTime.now();

        if (DateTime.now().difference(_dataSentAt!) >= _ackTimeout) {
          await _hceChannel.invokeMethod('markNoAck');
          _pollTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _status = 'NO_ACK';
            _feedback = 'NO_ACK: tap ulang ke HP penerima';
          });
          return;
        }

        if (_status != 'DATA_SENT') {
          setState(() {
            _status = 'DATA_SENT';
            _feedback = 'data terbaca, menunggu ACK penerima';
          });
        }
      } else if (status == 'PENDING_SYNC') {
        _pollTimer?.cancel();
        if (!_hasDebitedBalance) {
          ref
              .read(dummyWalletBalanceProvider.notifier)
              .send(dummyTransferAmount);
          _hasDebitedBalance = true;
        }
        setState(() {
          _status = 'PENDING_SYNC';
          _feedback = 'Transaksi berhasil diterima penerima';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diterima penerima'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
      } else if (status == 'NO_ACK') {
        _pollTimer?.cancel();
        setState(() {
          _status = 'NO_ACK';
          _feedback = 'NO_ACK: tap ulang ke HP penerima';
        });
      }
    } finally {
      _isPolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF4F7FB), // Sangat soft grey/blue atas
            Colors.white,
            Color(0xFFC7F4ED), // Soft mint bottom left
          ],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildReceiverInfo(),
              const Spacer(flex: 1),
              _buildRippleAnimation(),
              const Spacer(flex: 1),
              _buildAmountInfo(),
              const SizedBox(height: 48),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        'Kirim Uang',
        style: TextStyle(
          color: Color(0xFF1E1E24),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 1.5),
            ),
            child: Icon(
              Icons.question_mark_rounded,
              color: Colors.black87,
              size: 16,
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildReceiverInfo() {
    return Column(
      children: [
        Text(
          'mengirim ke',
          style: TextStyle(fontSize: 16, color: Color(0xFF4A4A54)),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 24,
              color: Color(0xFF1E1E24),
            ),
            SizedBox(width: 8),
            Text(
              'wallet penerima',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E1E24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRippleAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E2E36), width: 1.5),
          ),
        ),
        // Middle circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E2E36), width: 1.5),
          ),
        ),
        // Center icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.nfc_rounded, color: Colors.white, size: 32),
          ),
        ),
        // Decorative dots / particles
        Positioned(
          top: 40,
          left: 0,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -30,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo() {
    return Column(
      children: [
        Text(
          formatRupiah(dummyTransferAmount),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E1D22),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _feedback,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF4A4A54)),
        ),
        const SizedBox(height: 12),
        _buildStatusPill(),
      ],
    );
  }

  Widget _buildStatusPill() {
    final color = switch (_status) {
      'PENDING_SYNC' => const Color(0xFF1F8062),
      'NO_ACK' => const Color(0xFFFF9500),
      'DATA_SENT' => const Color(0xFF1FA2D6),
      'ERROR' => const Color(0xFFD14B5A),
      _ => const Color(0xFF4A4A54),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final isNoAck = _status == 'NO_ACK';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isNoAck ? _prepareNfcPayload : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA5EADF), // Soft mint color
            foregroundColor: const Color(0xFF1E1E24), // Black/dark grey text
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF81CEC2), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isNoAck ? Icons.nfc_rounded : Icons.bluetooth_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isNoAck ? 'Tap ulang via NFC' : 'Coba via Bluetooth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isNoAck ? Icons.refresh_rounded : Icons.arrow_outward_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

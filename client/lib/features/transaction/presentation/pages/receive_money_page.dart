import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nirpay/core/database/app_database.dart';
import 'package:nirpay/core/database/database_service.dart';
import 'package:nirpay/core/router/app_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nirpay/core/theme/app_colors.dart';
import 'package:nirpay/core/widgets/pin_verification_sheet.dart';
import 'package:nirpay/features/auth/presentation/providers/auth_providers.dart';
import 'package:nirpay/features/wallet/presentation/providers/wallet_balance_provider.dart';

enum ReceiveMethod { nfc, bluetooth }

enum NfcReceiveState {
  idle,
  scanning,
  receiving,
  success,
  failed,
}

class ReceiveMoneyPage extends ConsumerStatefulWidget {
  const ReceiveMoneyPage({super.key});

  @override
  ConsumerState<ReceiveMoneyPage> createState() => _ReceiveMoneyPageState();
}

class _ReceiveMoneyPageState extends ConsumerState<ReceiveMoneyPage>
    with TickerProviderStateMixin {
  // NFC APDU commands
  static const _selectApdu = [
    0x00, 0xA4, 0x04, 0x00, 0x07,
    0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
  ];
  static const _readDataApdu = [0x00, 0xCA, 0x00, 0x00, 0x00];
  static const _sendAckApdu = [0x00, 0xDA, 0x00, 0x00, 0x00];

  // BLE Platform Channel
  static const _bleChannel = MethodChannel('nirpay.com/ble');

  ReceiveMethod? _selectedMethod;
  NfcReceiveState _nfcState = NfcReceiveState.idle;
  String _feedback = '';
  int _receivedAmount = 0;

  // Bluetooth state
  String _btStatus = 'idle';
  String _btDeviceName = 'NirPay-Receiver';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen BLE channel callbacks
    _bleChannel.setMethodCallHandler((call) async {
      debugPrint('📡 [BLE-RECV] Channel callback: ${call.method} args=${call.arguments}');

      if (call.method == 'onDataReceived') {
        final data = call.arguments as String;
        debugPrint('📡 [BLE-RECV] onDataReceived: $data');
        _handleBleData(data);
      } else if (call.method == 'onStateChanged') {
        final state = call.arguments as String;
        debugPrint('📡 [BLE-RECV] onStateChanged: $state');

        // Extract device name if present
        if (state.startsWith('deviceName:')) {
          _btDeviceName = state.replaceFirst('deviceName:', '');
          debugPrint('📡 [BLE-RECV] Device name: $_btDeviceName');
          if (mounted) setState(() {});
        } else {
          if (mounted) setState(() => _btStatus = state);
        }

        debugPrint('📡 [BLE-RECV] Status updated: $_btStatus');
      }
    });
  }

  @override
  void dispose() {
    _bleChannel.setMethodCallHandler(null);
    _pulseController.dispose();
    NfcManager.instance.stopSession();
    _stopBleReceiver();
    super.dispose();
  }

  // ─── BLE Receiver ───
  Future<void> _startBleReceiver() async {
    debugPrint('📡 [BLE-RECV] ===== STARTING BLE RECEIVER =====');
    debugPrint('📡 [BLE-RECV] Timestamp: ${DateTime.now()}');

    // 1. Cek Bluetooth supported
    debugPrint('📡 [BLE-RECV] Checking BLE support...');
    final isSupported = await FlutterBluePlus.isSupported;
    debugPrint('📡 [BLE-RECV] BLE supported: $isSupported');

    if (!isSupported) {
      debugPrint('📡 [BLE-RECV] BLE not supported!');
      setState(() {
        _btStatus = 'error:BLE tidak didukung di device ini';
        _nfcState = NfcReceiveState.failed;
        _feedback = 'Bluetooth LE tidak didukung di device ini';
      });
      return;
    }

    // 2. Cek Bluetooth adapter state
    debugPrint('📡 [BLE-RECV] Checking adapter state...');
    final adapterState = await FlutterBluePlus.adapterState.first;
    debugPrint('📡 [BLE-RECV] Adapter state: $adapterState');

    if (adapterState != BluetoothAdapterState.on) {
      debugPrint('📡 [BLE-RECV] Bluetooth is OFF!');

      // Coba nyalakan
      try {
        debugPrint('📡 [BLE-RECV] Trying to turn on Bluetooth...');
        await FlutterBluePlus.turnOn();
        debugPrint('📡 [BLE-RECV] turnOn() called, waiting...');

        // Tunggu sampai nyala max 5 detik
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final state = await FlutterBluePlus.adapterState.first;
          debugPrint('📡 [BLE-RECV] Adapter state check: $state');
          if (state == BluetoothAdapterState.on) {
            debugPrint('📡 [BLE-RECV] Bluetooth turned ON!');
            break;
          }
        }
      } catch (e) {
        debugPrint('📡 [BLE-RECV] turnOn error: $e');
      }

      // Cek lagi
      final finalState = await FlutterBluePlus.adapterState.first;
      debugPrint('📡 [BLE-RECV] Final adapter state: $finalState');

      if (finalState != BluetoothAdapterState.on) {
        debugPrint('📡 [BLE-RECV] Bluetooth still OFF after attempt');
        setState(() {
          _btStatus = 'error:Bluetooth mati, nyalakan dulu';
          _nfcState = NfcReceiveState.failed;
          _feedback = 'Bluetooth mati. Nyalakan Bluetooth di Pengaturan.';
        });
        return;
      }
    }

    debugPrint('📡 [BLE-RECV] Bluetooth is ON, starting BLE peripheral...');

    setState(() {
      _nfcState = NfcReceiveState.scanning;
      _feedback = 'Mengaktifkan BLE receiver...';
      _btStatus = 'starting';
    });

    // 3. Start BLE peripheral via platform channel (with timeout)
    try {
      debugPrint('📡 [BLE-RECV] Invoking startReceiver on platform...');

      final result = await _bleChannel
          .invokeMethod('startReceiver')
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint('📡 [BLE-RECV] ⏰ startReceiver TIMEOUT after 8s');
              return false;
            },
          );

      debugPrint('📡 [BLE-RECV] startReceiver result: $result');

      if (result == true) {
        debugPrint('📡 [BLE-RECV] ✅ BLE peripheral started successfully');
        debugPrint('📡 [BLE-RECV] Device name: $_btDeviceName');
        setState(() {
          _btStatus = 'advertising';
          _feedback = 'Menunggu pengirim terhubung...';
        });
      } else {
        debugPrint('📡 [BLE-RECV] ❌ startReceiver returned false/null');
        setState(() {
          _btStatus = 'error:Gagal mengaktifkan BLE receiver';
          _nfcState = NfcReceiveState.failed;
          _feedback = 'Gagal mengaktifkan Bluetooth receiver. Coba lagi.';
        });
      }
    } on PlatformException catch (e) {
      debugPrint('📡 [BLE-RECV] ❌ PlatformException: ${e.code} - ${e.message}');
      debugPrint('📡 [BLE-RECV] Details: ${e.details}');
      setState(() {
        _nfcState = NfcReceiveState.failed;
        _feedback = 'Gagal: ${e.message}';
        _btStatus = 'error:${e.message}';
      });
    } catch (e) {
      debugPrint('📡 [BLE-RECV] ❌ Unexpected error: $e');
      setState(() {
        _nfcState = NfcReceiveState.failed;
        _feedback = 'Error: $e';
        _btStatus = 'error:$e';
      });
    }

    debugPrint('📡 [BLE-RECV] Final status: $_btStatus');
  }

  Future<void> _stopBleReceiver() async {
    debugPrint('📡 [BLE-RECV] Stopping BLE receiver...');
    try {
      await _bleChannel.invokeMethod('stopReceiver');
      debugPrint('📡 [BLE-RECV] BLE receiver stopped');
    } catch (e) {
      debugPrint('📡 [BLE-RECV] Stop error: $e');
    }
    if (mounted) setState(() => _btStatus = 'idle');
  }

  void _handleBleData(String rawData) async {
    debugPrint('📡 [BLE-RECV] ===== DATA RECEIVED =====');
    debugPrint('📡 [BLE-RECV] Raw: $rawData');

    try {
      final payload = jsonDecode(rawData);
      final amount = payload['amount'] ?? 0;
      final txId = payload['transactionId'] ?? '';
      final currency = payload['currency'] ?? 'IDR';
      final status = payload['status'] ?? '';
      final hopCount = payload['hopCount'] ?? 0;
      final maxHop = payload['maxHop'] ?? 3;
      final senderName = payload['senderName'] as String? ?? 'Unknown';

      debugPrint('📡 [BLE-RECV] Parsed payload:');
      debugPrint('  txId     : $txId');
      debugPrint('  amount   : $amount');
      debugPrint('  currency : $currency');
      debugPrint('  status   : $status');
      debugPrint('  hop      : $hopCount/$maxHop');

      // Validasi hop: tolak jika pengirim sudah mencapai batas
      if (hopCount >= maxHop) {
        debugPrint('📡 [BLE-RECV] HOP_EXCEEDED: $hopCount >= $maxHop');
        setState(() {
          _nfcState = NfcReceiveState.failed;
          _feedback = 'Pengirim perlu konfirmasi ke bank dulu (hop limit tercapai)';
        });
        return;
      }

      setState(() {
        _nfcState = NfcReceiveState.receiving;
        _feedback = 'Data diterima, mengirim ACK...';
      });

      // Send ACK to sender
      debugPrint('📡 [BLE-RECV] Sending ACK...');
      await _bleChannel.invokeMethod('sendAck', {'transactionId': txId});
      debugPrint('📡 [BLE-RECV] ACK sent successfully');

      // Save transaction & update balance
      debugPrint('📡 [BLE-RECV] Saving transaction & updating balance...');
      await _onReceiveSuccess(amount, txId, hopCount, senderName);
      debugPrint('📡 [BLE-RECV] ===== RECEIVE COMPLETE =====');

    } catch (e, stackTrace) {
      debugPrint('📡 [BLE-RECV] ERROR: $e');
      debugPrint('📡 [BLE-RECV] Stack: $stackTrace');
      setState(() {
        _nfcState = NfcReceiveState.failed;
        _feedback = 'Gagal memproses data: $e';
      });
    }
  }

  // ─── NFC Receive Flow ───
  Future<void> _startNfcReceive() async {
    // PIN verification first
    final pinOk = await PinVerificationSheet.show(context);
    if (!mounted || pinOk != true) return;

    setState(() {
      _nfcState = NfcReceiveState.scanning;
      _feedback = 'Menunggu pengirim menempelkan device...';
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (tag) async {
          if (_nfcState == NfcReceiveState.success) return;

          try {
            debugPrint('📡 [RECEIVE] NFC tag discovered!');

            setState(() {
              _nfcState = NfcReceiveState.receiving;
              _feedback = 'Membaca data dari pengirim...';
            });

            final isoDep = IsoDepAndroid.from(tag);
            if (isoDep == null) {
              debugPrint('📡 [RECEIVE] ERROR: Bukan HCE NirPay');
              _onNfcError('Perangkat pengirim bukan HCE NirPay.');
              return;
            }

            // Step 1: Select AID
            debugPrint('📡 [RECEIVE] Step 1: Select AID...');
            final selectResp = await isoDep.transceive(
              Uint8List.fromList(_selectApdu),
            );
            if (!_isApduSuccess(selectResp)) {
              debugPrint('📡 [RECEIVE] ERROR: Select AID gagal');
              _onNfcError('Gagal memilih AID NirPay.');
              return;
            }
            debugPrint('📡 [RECEIVE] AID selected OK');

            setState(() => _feedback = 'Terhubung, membaca data transaksi...');

            // Step 2: Read transaction data
            debugPrint('📡 [RECEIVE] Step 2: Read data...');
            final readResp = await isoDep.transceive(
              Uint8List.fromList(_readDataApdu),
            );
            if (!_isApduSuccess(readResp)) {
              debugPrint('📡 [RECEIVE] ERROR: Read data gagal');
              _onNfcError('Gagal membaca data transaksi.');
              return;
            }

            final payloadBytes = readResp.sublist(0, readResp.length - 2);
            final rawPayload = utf8.decode(payloadBytes);
            debugPrint('📡 [RECEIVE] Raw payload: $rawPayload');

            final payload = _parsePayload(rawPayload);
            debugPrint('📡 [RECEIVE] Parsed: amount=${payload.amount}, txId=${payload.txId}, hop=${payload.hopCount}/${payload.maxHop}');

            // Validasi hop: tolak jika pengirim sudah mencapai batas
            if (payload.hopCount >= payload.maxHop) {
              debugPrint('📡 [RECEIVE] HOP_EXCEEDED: ${payload.hopCount} >= ${payload.maxHop}');
              _onNfcError('Pengirim perlu konfirmasi ke bank dulu (hop limit tercapai)');
              return;
            }

            setState(() => _feedback = 'Data diterima, mengirim konfirmasi...');

            // Step 3: Send ACK back to sender
            debugPrint('📡 [RECEIVE] Step 3: Sending ACK...');
            final ackResp = await isoDep.transceive(
              Uint8List.fromList(_sendAckApdu),
            );
            if (!_isApduSuccess(ackResp)) {
              debugPrint('📡 [RECEIVE] ERROR: ACK gagal');
              _onNfcError('Data terbaca tapi konfirmasi gagal dikirim.');
              return;
            }
            debugPrint('📡 [RECEIVE] ACK sent OK');

            // Step 4: Save transaction & update balance
            debugPrint('📡 [RECEIVE] Step 4: Simpan transaksi & update saldo...');
            await _onReceiveSuccess(payload.amount, payload.txId, payload.hopCount, payload.senderName);
          } catch (e) {
            _onNfcError('Gagal memproses NFC: $e');
          }
        },
      );
    } catch (e) {
      _onNfcError('Gagal memulai NFC reader: $e');
    }
  }

  bool _isApduSuccess(Uint8List response) {
    return response.length >= 2 &&
        response[response.length - 2] == 0x90 &&
        response[response.length - 1] == 0x00;
  }

  ({int amount, String txId, int hopCount, int maxHop, String senderName}) _parsePayload(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        final amount = json['amount'];
        final txId = json['transactionId']?.toString() ?? '';
        final hopCount = json['hopCount'] ?? 0;
        final maxHop = json['maxHop'] ?? 3;
        final senderName = json['senderName'] as String? ?? 'Unknown';
        return (
          amount: amount is int ? amount : (amount as num).toInt(),
          txId: txId,
          hopCount: hopCount is int ? hopCount : (hopCount as num).toInt(),
          maxHop: maxHop is int ? maxHop : (maxHop as num).toInt(),
          senderName: senderName,
        );
      }
    } catch (_) {}
    return (amount: 0, txId: '', hopCount: 0, maxHop: 3, senderName: 'Unknown');
  }

  Future<void> _onReceiveSuccess(int amount, String txId, [int hopCount = 0, String counterpartyName = 'Unknown']) async {
    final db = ref.read(appDatabaseProvider);
    final currentUser = ref.read(currentUserProvider);
    final id = txId.isNotEmpty ? txId : DateTime.now().microsecondsSinceEpoch.toString();

    debugPrint('💰 [RECEIVE] Transfer diterima! amount=$amount, txId=$id, hop=$hopCount, from=$counterpartyName');
    debugPrint('💰 [RECEIVE] userId=${currentUser?.id}');

    // 1. Simpan transaksi ke local DB (dengan hopCount + counterparty)
    await db.insertTransaction(
      TransactionsCompanion(
        id: drift.Value(id),
        txId: drift.Value(id),
        direction: const drift.Value('CREDIT'),
        txType: const drift.Value('TRANSFER'),
        amountCent: drift.Value(amount * 100),
        hopCount: drift.Value(hopCount),
        syncStatus: const drift.Value('PENDING'),
        counterpartyName: drift.Value(counterpartyName != 'Unknown' ? counterpartyName : null),
      ),
    );
    debugPrint('💰 [RECEIVE] Transaksi tersimpan di DB (hop=$hopCount)');

    // 2. Tambah saldo di wallet_balance
    if (currentUser != null) {
      final balance = await db.getWalletBalance(currentUser.id);
      debugPrint('💰 [RECEIVE] Saldo sebelum: ${balance?.amountCent ?? 0}');

      if (balance != null) {
        final newAmount = balance.amountCent + (amount * 100);
        await (db.update(db.walletBalances)..where((w) => w.userId.equals(currentUser.id))).write(
          WalletBalancesCompanion(
            amountCent: drift.Value(newAmount),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        debugPrint('💰 [RECEIVE] Saldo sesudah: $newAmount');
      } else {
        // Wallet belum ada, buat baru (terima uang pertama kali)
        debugPrint('💰 [RECEIVE] Wallet tidak ditemukan, membuat baru...');
        await db.upsertWalletBalance(
          WalletBalancesCompanion.insert(
            id: 'wallet-${currentUser.id}',
            userId: currentUser.id,
            amountCent: drift.Value(amount * 100),
            reservedCent: const drift.Value(0),
            hopCount: const drift.Value(0),
            maxHop: const drift.Value(3),
            currency: const drift.Value('IDR'),
          ),
        );
        debugPrint('💰 [RECEIVE] Wallet baru dibuat, saldo: ${amount * 100}');
      }
    }

    // 3. Refresh provider supaya UI update
    ref.invalidate(walletBalanceProvider);

    // Stop NFC session hanya jika dipanggil dari NFC path
    if (_selectedMethod == ReceiveMethod.nfc) {
      await NfcManager.instance.stopSession();
    }

    if (!mounted) return;
    setState(() {
      _nfcState = NfcReceiveState.success;
      _receivedAmount = amount;
      _feedback = 'Transfer berhasil diterima!';
    });
  }

  void _onNfcError(String message) {
    NfcManager.instance.stopSession();
    if (!mounted) return;
    setState(() {
      _nfcState = NfcReceiveState.failed;
      _feedback = message;
    });
  }

  void _resetNfcForRetry() {
    NfcManager.instance.stopSession();
    setState(() {
      _nfcState = NfcReceiveState.idle;
      _receivedAmount = 0;
    });
  }

  // ─── UI ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () {
            if (_nfcState != NfcReceiveState.idle) {
              NfcManager.instance.stopSession();
              setState(() => _nfcState = NfcReceiveState.idle);
            }
            if (_selectedMethod != null) {
              setState(() {
                _selectedMethod = null;
                _nfcState = NfcReceiveState.idle;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _selectedMethod == null ? 'Terima Uang' : _methodTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _selectedMethod == null
          ? _buildMethodSelection()
          : _selectedMethod == ReceiveMethod.nfc && _nfcState != NfcReceiveState.idle
              ? _buildNfcReceiveView()
              : _buildBluetoothReceiveView(),
    );
  }

  String get _methodTitle {
    switch (_selectedMethod!) {
      case ReceiveMethod.nfc:
        return 'Terima via NFC';
      case ReceiveMethod.bluetooth:
        return 'Terima via Bluetooth';
    }
  }

  // ─── Step 1: Pilih Metode ───
  Widget _buildMethodSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceInfo(),
          const SizedBox(height: 32),
          Text(
            'Pilih Metode Menerima',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih bagaimana Anda ingin menerima uang',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 20),
          // NFC
          _buildMethodCard(
            method: ReceiveMethod.nfc,
            icon: Icons.nfc_rounded,
            title: 'NFC',
            subtitle: 'Tap antar device',
            description: 'Tempelkan device Anda ke device pengirim. Cepat dan mudah.',
            color: context.colors.primary,
            steps: [
              'Tekan "Mulai Terima" dan masukkan PIN',
              'Tempelkan device ke pengirim',
              'Dana masuk otomatis setelah terhubung',
            ],
          ),
          const SizedBox(height: 14),
          // Bluetooth (Disabled)
          _buildMethodCard(
            method: ReceiveMethod.bluetooth,
            icon: Icons.bluetooth_rounded,
            title: 'Bluetooth',
            subtitle: 'Segera Hadir',
            description: 'Fitur ini sedang dalam pengembangan. Gunakan NFC untuk menerima.',
            color: context.colors.textSecondary,
            steps: [
              'Fitur akan tersedia di update berikutnya',
              'Gunakan NFC untuk transfer saat ini',
            ],
            isDisabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required ReceiveMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required List<String> steps,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fitur $title akan tersedia di update berikutnya. Gunakan NFC untuk menerima.'),
                  backgroundColor: context.colors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          : () async {
              debugPrint('📡 [BLE-RECV] Method selected: $method');
              setState(() => _selectedMethod = method);
              if (method == ReceiveMethod.nfc) {
                debugPrint('📡 [BLE-RECV] Starting NFC receive...');
                Future.delayed(const Duration(milliseconds: 300), _startNfcReceive);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          children: [
            Row(
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
                          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
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
                Icon(
                  isDisabled ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded,
                  color: context.colors.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Steps
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: entry.key < steps.length - 1 ? 8 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: 12, color: context.colors.textPrimary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── NFC Receive View ───
  Widget _buildNfcReceiveView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Animation
          _buildNfcAnimation(),
          const Spacer(flex: 1),
          // Amount (show after success)
          if (_nfcState == NfcReceiveState.success) ...[
            Text(
              formatRupiah(_receivedAmount),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: context.colors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dana masuk ke wallet Anda',
              style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
            ),
          ] else ...[
            Text(
              'Menunggu Transfer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Feedback
          Text(
            _feedback,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _nfcState == NfcReceiveState.failed
                  ? context.colors.error
                  : context.colors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Status pill
          _buildStatusPill(),
          const SizedBox(height: 12),
          // Hint
          if (_nfcState == NfcReceiveState.scanning || _nfcState == NfcReceiveState.receiving)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Jangan menjauhkan device sampai transfer selesai',
                      style: TextStyle(fontSize: 12, color: context.colors.primary),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          // Action buttons
          if (_nfcState == NfcReceiveState.failed)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      NfcManager.instance.stopSession();
                      setState(() => _selectedMethod = null);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: context.colors.border),
                    ),
                    child: Text('Kembali', style: TextStyle(color: context.colors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _resetNfcForRetry();
                      _startNfcReceive();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          if (_nfcState == NfcReceiveState.success)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.goNamed(AppRouteNames.wallet);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          if (_nfcState == NfcReceiveState.scanning || _nfcState == NfcReceiveState.receiving)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  NfcManager.instance.stopSession();
                  setState(() {
                    _nfcState = NfcReceiveState.idle;
                    _selectedMethod = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: context.colors.error.withValues(alpha: 0.3)),
                ),
                child: Text('Batalkan', style: TextStyle(color: context.colors.error)),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNfcAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = (_nfcState == NfcReceiveState.scanning || _nfcState == NfcReceiveState.receiving)
            ? _pulseAnimation.value
            : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _nfcState == NfcReceiveState.success
                    ? context.colors.success.withValues(alpha: 0.3)
                    : _nfcState == NfcReceiveState.failed
                        ? context.colors.error.withValues(alpha: 0.3)
                        : context.colors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _nfcState == NfcReceiveState.success
                    ? context.colors.success.withValues(alpha: 0.5)
                    : _nfcState == NfcReceiveState.failed
                        ? context.colors.error.withValues(alpha: 0.5)
                        : context.colors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
          // Center icon
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _nfcState == NfcReceiveState.success
                  ? context.colors.success
                  : _nfcState == NfcReceiveState.failed
                      ? context.colors.error
                      : context.colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_nfcState == NfcReceiveState.success
                          ? context.colors.success
                          : _nfcState == NfcReceiveState.failed
                              ? context.colors.error
                              : context.colors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _nfcState == NfcReceiveState.success
                  ? Icons.check_rounded
                  : _nfcState == NfcReceiveState.failed
                      ? Icons.close_rounded
                      : Icons.nfc_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    final (color, label) = switch (_nfcState) {
      NfcReceiveState.scanning => (context.colors.primary, 'Memindai...'),
      NfcReceiveState.receiving => (context.colors.warning, 'Menerima Data...'),
      NfcReceiveState.success => (context.colors.success, 'Berhasil Diterima'),
      NfcReceiveState.failed => (context.colors.error, 'Gagal'),
      NfcReceiveState.idle => (context.colors.textSecondary, 'Siap'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_nfcState == NfcReceiveState.scanning || _nfcState == NfcReceiveState.receiving)
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: color)),
          if (_nfcState == NfcReceiveState.scanning || _nfcState == NfcReceiveState.receiving)
            const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─── Bluetooth Receive View (BLE Peripheral Mode) ───
  Widget _buildBluetoothReceiveView() {
    final isAdvertising = _btStatus == 'advertising' || _btStatus.startsWith('connected');
    final isConnected = _btStatus.startsWith('connected');
    final isError = _btStatus.startsWith('error');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bluetooth_rounded, color: context.colors.success, size: 20),
                const SizedBox(width: 10),
                Text('Metode: Bluetooth', style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.success, fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _stopBleReceiver();
                    setState(() {
                      _selectedMethod = null;
                      _nfcState = NfcReceiveState.idle;
                    });
                  },
                  child: Text('Ubah', style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.success, fontSize: 13, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // BLE Peripheral status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                // BT animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isError
                              ? context.colors.error.withValues(alpha: 0.3)
                              : context.colors.success.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isError
                              ? context.colors.error.withValues(alpha: 0.5)
                              : context.colors.success.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: isError ? context.colors.error : context.colors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isError ? Icons.error_outline_rounded : Icons.bluetooth_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    if (isAdvertising && !isConnected)
                      SizedBox(
                        width: 170, height: 170,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.success,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  isConnected
                      ? 'Terhubung!'
                      : isAdvertising
                          ? 'Menunggu Pengirim...'
                          : isError
                              ? 'Gagal'
                          : 'Mengaktifkan Bluetooth...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isError ? context.colors.error : context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    isConnected
                        ? 'Device pengirim terhubung, menunggu data...'
                        : isAdvertising
                            ? 'HP Anda terlihat sebagai "NirPay-Receiver". Minta pengirim scan & pilih device ini.'
                            : isError
                                ? _btStatus.replaceFirst('error:', '')
                            : 'Mengaktifkan BLE peripheral...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: context.colors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Device name info
          if (isAdvertising)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 18, color: context.colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device Name:', style: TextStyle(fontSize: 11, color: context.colors.textSecondary)),
                        Text(
                          'NirPay-Receiver',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: context.colors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Transfer P2P via Bluetooth langsung tanpa internet. Dana masuk otomatis setelah pengirim berhasil mengirim.',
                    style: TextStyle(fontSize: 12, color: context.colors.success, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (isError && _btStatus.contains('mati'))
            // Tombol nyalakan Bluetooth
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  debugPrint('📡 [BLE-RECV] User wants to turn on Bluetooth');
                  try {
                    await FlutterBluePlus.turnOn();
                    await Future.delayed(const Duration(seconds: 1));
                    _startBleReceiver();
                  } catch (e) {
                    debugPrint('📡 [BLE-RECV] turnOn error: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Nyalakan Bluetooth manual dari Pengaturan')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.bluetooth_rounded, size: 20),
                label: const Text('Nyalakan Bluetooth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          else
            // Tombol normal (retry / sudah aktif)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAdvertising ? null : _startBleReceiver,
                icon: Icon(isAdvertising ? Icons.check_circle_rounded : Icons.bluetooth_rounded, size: 20),
                label: Text(isAdvertising ? 'Sudah Aktif' : 'Aktifkan Bluetooth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdvertising ? context.colors.success.withValues(alpha: 0.5) : context.colors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.colors.success.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo() {
    final balanceAsync = ref.watch(walletBalanceProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: context.colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo Saat Ini', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                const SizedBox(height: 4),
                balanceAsync.when(
                  data: (balance) {
                    final amount = ((balance?.amountCent ?? 0) - (balance?.reservedCent ?? 0)) / 100;
                    return Text('Rp ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary));
                  },
                  loading: () => Text('Memuat...', style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
                  error: (_, __) => Text('Rp 0', style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Format Rupiah ───
String formatRupiah(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return 'Rp ${buffer.toString()}';
}

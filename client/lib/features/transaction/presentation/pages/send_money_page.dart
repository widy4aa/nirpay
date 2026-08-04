import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/database/app_database.dart';
import 'package:nirpay/core/database/database_service.dart';
import 'package:nirpay/core/router/app_router.dart';
import 'package:nirpay/core/theme/app_colors.dart';
import 'package:nirpay/core/widgets/pin_verification_sheet.dart';
import 'package:nirpay/features/auth/presentation/providers/auth_providers.dart';
import 'package:nirpay/features/wallet/presentation/providers/wallet_balance_provider.dart';

enum TransferMethod { nfc, bluetooth, online }

// NFC transfer states
enum NfcState { idle, preparing, waitingForTap, sending, success, failed }

class SendMoneyPage extends ConsumerStatefulWidget {
  const SendMoneyPage({super.key});

  @override
  ConsumerState<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends ConsumerState<SendMoneyPage>
    with TickerProviderStateMixin {
  static const _hceChannel = MethodChannel('nirpay.com/hce');
  static const _ackTimeout = Duration(seconds: 15);

  TransferMethod? _selectedMethod;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountFocus = FocusNode();

  // Online method state
  String _recipientName = '';
  String _recipientPhone = '';
  bool _isRecipientValid = false;

  // Bluetooth method state
  bool _isScanning = false;
  BluetoothDevice? _selectedBtDevice;
  List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // BLE Service & Characteristic UUIDs (must match receiver)
  static final Guid _serviceUuid = Guid("12345678-1234-1234-1234-123456789abc");
  static final Guid _txCharUuid = Guid("12345678-1234-1234-1234-123456789ab1");
  static final Guid _rxCharUuid = Guid("12345678-1234-1234-1234-123456789ab2");
  static final Guid _ackCharUuid = Guid("12345678-1234-1234-1234-123456789ab3");

  // NFC state
  NfcState _nfcState = NfcState.idle;
  String _nfcFeedback = '';
  String? _transactionId;
  Timer? _pollTimer;
  DateTime? _dataSentAt;
  bool _isPolling = false;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _quickAmounts = [50000, 100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _pulseController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  int _getParsedAmount() {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  bool _canProceed() {
    final amount = _getParsedAmount();
    if (amount < 10000) return false;

    switch (_selectedMethod) {
      case TransferMethod.nfc:
        return _nfcState == NfcState.idle;
      case TransferMethod.bluetooth:
        return _selectedBtDevice != null;
      case TransferMethod.online:
        return _isRecipientValid;
      default:
        return false;
    }
  }

  // ─── Online: Lookup penerima ───
  void _lookupRecipient() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) return;
    setState(() {
      _recipientPhone = phone;
      _recipientName = 'Pengguna NirPay';
      _isRecipientValid = true;
    });
    _amountFocus.requestFocus();
  }

  // ─── Bluetooth: Real BLE Scan ───
  Future<void> _startScan() async {
    // Stop any previous scan first
    await _stopScan();
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isScanning = true;
      _selectedBtDevice = null;
      _scanResults = [];
    });

    debugPrint('🔵 [BT] Starting BLE scan...');

    // 1. Request all required permissions first
    debugPrint('🔵 [BT] Requesting permissions...');
    final permissions = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    debugPrint('🔵 [BT] Permission results:');
    permissions.forEach((perm, status) {
      debugPrint('   $perm: $status');
    });

    // Check if critical permissions are granted
    final scanGranted = permissions[Permission.bluetoothScan]?.isGranted ?? false;
    final locationGranted = permissions[Permission.locationWhenInUse]?.isGranted ?? false;

    if (!scanGranted || !locationGranted) {
      debugPrint('🔵 [BT] Permissions not granted!');
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Berikan izin Bluetooth & Lokasi untuk scan device'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // 2. Check if Bluetooth is available
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint('🔵 [BT] Bluetooth not supported');
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth tidak tersedia di device ini')),
        );
      }
      return;
    }

    // 3. Turn on Bluetooth
    try {
      debugPrint('🔵 [BT] Turning on Bluetooth...');
      await FlutterBluePlus.turnOn();
      debugPrint('🔵 [BT] Bluetooth ON');
    } catch (e) {
      debugPrint('🔵 [BT] Error turning on BT: $e');
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nyalakan Bluetooth: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // 4. Wait for adapter to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    // 5. Listen to scan results — FILTER hanya NirPay devices
    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      if (!mounted) return;

      // Filter: hanya tampilkan device dengan nama "NirPay" atau service UUID match
      final nirpayDevices = results.where((r) {
        final name = r.advertisementData.advName;
        final platformName = r.device.platformName;
        final serviceUuids = r.advertisementData.serviceUuids;

        // Match berdasarkan nama
        final nameMatch = name.toLowerCase().contains('nirpay') ||
            platformName.toLowerCase().contains('nirpay');

        // Match berdasarkan service UUID
        final serviceMatch = serviceUuids.any((uuid) =>
            uuid.toString().toLowerCase().contains(_serviceUuid.toString().toLowerCase().substring(0, 8)));

        return nameMatch || serviceMatch;
      }).toList();

      setState(() => _scanResults = nirpayDevices);

      for (var r in nirpayDevices) {
        final name = r.advertisementData.advName.isNotEmpty
            ? r.advertisementData.advName
            : r.device.platformName;
        debugPrint('🔵 [BT] NirPay device: $name (${r.device.remoteId}) RSSI=${r.rssi}');
      }
    });

    // 6. Scan ALL devices (filter di apply di listener)
    try {
      debugPrint('🔵 [BT] Scanning for NirPay devices (15s)...');
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
      debugPrint('🔵 [BT] Scan completed');
    } catch (e) {
      debugPrint('🔵 [BT] Scan error: $e');
      await Future.delayed(const Duration(seconds: 1));
      try {
        debugPrint('🔵 [BT] Retrying scan...');
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 10),
          androidUsesFineLocation: true,
        );
      } catch (e2) {
        debugPrint('🔵 [BT] Retry scan error: $e2');
      }
    }

    if (mounted) setState(() => _isScanning = false);
    debugPrint('🔵 [BT] Scan done. Found ${_scanResults.length} devices');
  }

  Future<void> _stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _scanSubscription?.cancel();
    if (mounted) setState(() => _isScanning = false);
  }

  // ─── NFC Transfer Flow ───
  Future<void> _startNfcTransfer() async {
    final amount = _getParsedAmount();
    if (amount < 10000) return;

    // Step 0: Hop validation
    final db = ref.read(appDatabaseProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final balance = await db.getWalletBalance(currentUser.id);
      if (balance != null && balance.hopCount >= balance.maxHop) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Batas transfer offline tercapai (${balance.hopCount}/${balance.maxHop}). '
                'Silakan sync terlebih dahulu.',
              ),
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // Step 1: PIN verification first
    final pinOk = await PinVerificationSheet.show(context);
    if (!mounted || pinOk != true) return;

    // Step 2: Prepare NFC
    setState(() {
      _nfcState = NfcState.preparing;
      _nfcFeedback = 'Menyiapkan NFC...';
    });

    _transactionId = DateTime.now().microsecondsSinceEpoch.toString();

    // Ambil hop data dari wallet
    final hopBalance = currentUser != null
        ? await db.getWalletBalance(currentUser.id)
        : null;
    final currentHop = hopBalance?.hopCount ?? 0;
    final maxHop = hopBalance?.maxHop ?? 3;

    final senderName = ref.read(currentUserProvider)?.fullName ?? 'Unknown';

    final payload = jsonEncode({
      'transactionId': _transactionId,
      'amount': amount,
      'currency': 'IDR',
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
      'hopCount': currentHop + 1,
      'maxHop': maxHop,
      'senderName': senderName,
      'senderId': currentUser?.id ?? '',
    });

    try {
      await _hceChannel.invokeMethod('setNfcData', {
        'data': payload,
        'transactionId': _transactionId,
      });

      if (!mounted) return;
      setState(() {
        _nfcState = NfcState.waitingForTap;
        _nfcFeedback = 'Tempelkan device ke penerima';
      });

      // Step 3: Poll for ACK
      _dataSentAt = null;
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 400),
        (_) => unawaited(_pollNfcStatus(amount)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _nfcState = NfcState.failed;
        _nfcFeedback = 'Gagal mengaktifkan NFC';
      });
    }
  }

  Future<void> _pollNfcStatus(int amount) async {
    if (_isPolling || _transactionId == null) return;
    _isPolling = true;

    try {
      final raw = await _hceChannel.invokeMapMethod<String, Object?>(
        'getNfcTransferStatus',
      );
      final activeTxId = raw?['transactionId']?.toString();
      final status = raw?['status']?.toString() ?? 'IDLE';

      if (activeTxId != _transactionId || !mounted) return;

      debugPrint('📡 [SEND] NFC Status: $status (txId=$activeTxId)');

      switch (status) {
        case 'DATA_SENT':
          _dataSentAt ??= DateTime.now();
          if (DateTime.now().difference(_dataSentAt!) >= _ackTimeout) {
            _pollTimer?.cancel();
            await _hceChannel.invokeMethod('markNoAck');
            if (!mounted) return;
            setState(() {
              _nfcState = NfcState.failed;
              _nfcFeedback = 'Penerima tidak merespons. Coba lagi.';
            });
            return;
          }
          if (_nfcState != NfcState.sending) {
            setState(() {
              _nfcState = NfcState.sending;
              _nfcFeedback = 'Data terbaca, menunggu konfirmasi...';
            });
          }
          break;

        case 'PENDING_SYNC':
          _pollTimer?.cancel();
          // Only now we save the transaction & deduct balance
          await _onTransferSuccess(amount);
          break;

        case 'NO_ACK':
          _pollTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _nfcState = NfcState.failed;
            _nfcFeedback = 'Transfer ditolak oleh penerima.';
          });
          break;
      }
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _onTransferSuccess(int amount) async {
    final db = ref.read(appDatabaseProvider);
    final currentUser = ref.read(currentUserProvider);

    debugPrint('💰 [SEND] Transfer berhasil! amount=$amount, txId=$_transactionId');
    debugPrint('💰 [SEND] userId=${currentUser?.id}');

    // Ambil hop count saat ini untuk disimpan di transaksi
    final balanceBefore = currentUser != null
        ? await db.getWalletBalance(currentUser.id)
        : null;
    final txHopCount = (balanceBefore?.hopCount ?? 0) + 1;

    // 1. Simpan transaksi ke local DB (dengan hopCount + counterparty)
    final counterpartyName = _selectedBtDevice?.platformName
        ?? (_selectedMethod == TransferMethod.nfc ? 'NFC Device' : _recipientName);

    await db.insertTransaction(
      TransactionsCompanion(
        id: drift.Value(_transactionId!),
        txId: drift.Value(_transactionId!),
        direction: const drift.Value('DEBIT'),
        txType: const drift.Value('TRANSFER'),
        amountCent: drift.Value(amount * 100),
        hopCount: drift.Value(txHopCount),
        syncStatus: const drift.Value('PENDING'),
        counterpartyName: drift.Value(counterpartyName.isNotEmpty ? counterpartyName : null),
      ),
    );
    debugPrint('💰 [SEND] Transaksi tersimpan di DB (hop=$txHopCount)');

    // 2. Kurangi saldo di wallet_balance
    if (currentUser != null) {
      final balance = await db.getWalletBalance(currentUser.id);
      debugPrint('💰 [SEND] Saldo sebelum: ${balance?.amountCent ?? 0}');

      if (balance != null) {
        final newAmount = balance.amountCent - (amount * 100);
        await (db.update(db.walletBalances)..where((w) => w.userId.equals(currentUser.id))).write(
          WalletBalancesCompanion(
            amountCent: drift.Value(newAmount < 0 ? 0 : newAmount),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        debugPrint('💰 [SEND] Saldo sesudah: $newAmount');
      }

      // 3. Increment hop count
      await db.incrementHopCount(currentUser.id);
      debugPrint('💰 [SEND] Hop count incremented');
    }

    // 4. Refresh provider supaya UI update
    ref.invalidate(walletBalanceProvider);

    if (!mounted) return;
    setState(() {
      _nfcState = NfcState.success;
      _nfcFeedback = 'Transfer berhasil!';
    });
  }

  void _cancelNfcTransfer() {
    _pollTimer?.cancel();
    _hceChannel.invokeMethod('cancelTransfer').ignore();
    if (mounted) {
      setState(() {
        _nfcState = NfcState.idle;
        _transactionId = null;
        _dataSentAt = null;
      });
    }
  }

  void _resetNfcForRetry() {
    _pollTimer?.cancel();
    setState(() {
      _nfcState = NfcState.idle;
      _transactionId = null;
      _dataSentAt = null;
    });
  }

  // ─── Main Send Action (non-NFC) ───
  Future<void> _onSendPressed() async {
    if (!_canProceed()) return;
    final amount = _getParsedAmount();
    final note = _noteController.text.trim();

    // Hop validation (untuk BLE dan Online)
    final db = ref.read(appDatabaseProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final balance = await db.getWalletBalance(currentUser.id);
      if (balance != null && balance.hopCount >= balance.maxHop) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Batas transfer offline tercapai (${balance.hopCount}/${balance.maxHop}). '
                'Silakan sync terlebih dahulu.',
              ),
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    final confirmed = await _showConfirmationSheet(amount, note);
    if (!mounted || confirmed != true) return;

    final pinOk = await PinVerificationSheet.show(context);
    if (!mounted || pinOk != true) return;

    if (_selectedMethod == TransferMethod.bluetooth) {
      await _startBleTransfer(amount);
    } else {
      // Online transfer (TODO)
      _showSuccessSheet(amount);
    }
  }

  // ─── Bluetooth Transfer Flow ───
  Future<void> _startBleTransfer(int amount) async {
    if (_selectedBtDevice == null) return;

    final db = ref.read(appDatabaseProvider);
    final currentUser = ref.read(currentUserProvider);

    _transactionId = DateTime.now().microsecondsSinceEpoch.toString();
    debugPrint('🔵 [BT] Starting transfer: amount=$amount, txId=$_transactionId');
    debugPrint('🔵 [BT] Target device: ${_selectedBtDevice!.platformName} (${_selectedBtDevice!.remoteId})');

    // Show transferring dialog
    if (mounted) {
      _showTransferringSheet(amount);
    }

    try {
      // 1. Connect to device
      debugPrint('🔵 [BT] Connecting...');
      await _selectedBtDevice!.connect(
        license: License.free,
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );
      debugPrint('🔵 [BT] Connected!');

      // 2. Discover services
      debugPrint('🔵 [BT] Discovering services...');
      List<BluetoothService> services = await _selectedBtDevice!.discoverServices();
      debugPrint('🔵 [BT] Found ${services.length} services');

      // 3. Find NirPay service
      BluetoothService? nirpayService;
      for (var service in services) {
        debugPrint('🔵 [BT] Service: ${service.uuid}');
        if (service.uuid == _serviceUuid) {
          nirpayService = service;
          break;
        }
      }

      // If NirPay service not found, try first service with write characteristic
      if (nirpayService == null) {
        debugPrint('🔵 [BT] NirPay service not found, using first writable service');
        for (var service in services) {
          for (var char in service.characteristics) {
            if (char.properties.write || char.properties.writeWithoutResponse) {
              nirpayService = service;
              debugPrint('🔵 [BT] Using service: ${service.uuid}');
              break;
            }
          }
          if (nirpayService != null) break;
        }
      }

      if (nirpayService == null) {
        throw Exception('Tidak ditemukan service yang bisa ditulis');
      }

      // 4. Find characteristics
      BluetoothCharacteristic? rxChar; // write to receiver
      BluetoothCharacteristic? ackChar; // read ACK from receiver

      for (var char in nirpayService.characteristics) {
        debugPrint('🔵 [BT]   Char: ${char.uuid} (${char.properties})');
        if (char.uuid == _rxCharUuid || char.properties.write || char.properties.writeWithoutResponse) {
          rxChar ??= char;
        }
        if (char.uuid == _ackCharUuid || char.properties.notify) {
          ackChar ??= char;
        }
      }

      if (rxChar == null) {
        throw Exception('Tidak ditemukan characteristic untuk mengirim data');
      }

      // 5. Prepare payload (dengan hop data)
      final hopBalance = currentUser != null
          ? await db.getWalletBalance(currentUser.id)
          : null;
      final currentHop = hopBalance?.hopCount ?? 0;
      final maxHop = hopBalance?.maxHop ?? 3;

      final senderName = ref.read(currentUserProvider)?.fullName ?? 'Unknown';

      final payload = jsonEncode({
        'transactionId': _transactionId,
        'amount': amount,
        'currency': 'IDR',
        'status': 'DATA_SENT',
        'createdAt': DateTime.now().toIso8601String(),
        'hopCount': currentHop + 1,
        'maxHop': maxHop,
        'senderName': senderName,
        'senderId': currentUser?.id ?? '',
      });
      debugPrint('🔵 [BT] Payload: $payload');

      // 6. Send data
      debugPrint('🔵 [BT] Sending data to ${rxChar.uuid}...');
      await rxChar.write(utf8.encode(payload), withoutResponse: false);
      debugPrint('🔵 [BT] Data sent!');

      // 7. Wait for ACK (if notify characteristic available)
      bool ackReceived = false;
      if (ackChar != null && ackChar.properties.notify) {
        debugPrint('🔵 [BT] Listening for ACK on ${ackChar.uuid}...');

        final completer = Completer<bool>();
        final subscription = ackChar.onValueReceived.listen((data) {
          try {
            final ack = jsonDecode(utf8.decode(data));
            debugPrint('🔵 [BT] Received: $ack');
            if (ack['status'] == 'ACK' || ack['transactionId'] == _transactionId) {
              debugPrint('🔵 [BT] ACK received!');
              ackReceived = true;
              if (!completer.isCompleted) completer.complete(true);
            }
          } catch (e) {
            debugPrint('🔵 [BT] ACK parse error: $e');
          }
        });

        await ackChar.setNotifyValue(true);

        // Wait for ACK with timeout
        final result = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('🔵 [BT] ACK timeout');
            return false;
          },
        );

        await ackChar.setNotifyValue(false);
        subscription.cancel();

        if (!result) {
          // ACK timeout but data was sent — still count as success for P2P
          debugPrint('🔵 [BT] No ACK but data sent, treating as success');
        }
      } else {
        debugPrint('🔵 [BT] No ACK characteristic, data sent directly');
      }

      // 8. Disconnect
      await _selectedBtDevice!.disconnect();
      debugPrint('🔵 [BT] Disconnected');

      // 9. Save transaction & update balance
      await _onTransferSuccess(amount);

      // 10. Close transferring sheet and show success
      if (mounted) {
        Navigator.pop(context); // Close transferring sheet
        _showSuccessSheet(amount);
      }

    } catch (e) {
      debugPrint('🔵 [BT] Transfer error: $e');
      try {
        await _selectedBtDevice!.disconnect();
      } catch (_) {}

      if (mounted) {
        Navigator.pop(context); // Close transferring sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer gagal: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _showTransferringSheet(int amount) {
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 60, height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: context.colors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mengirim Dana...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatRupiah(amount),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: context.colors.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Menghubungkan ke ${_selectedBtDevice?.platformName ?? "device"}...',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Jangan menjauhkan device sampai transfer selesai',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
            if (_nfcState != NfcState.idle) {
              _cancelNfcTransfer();
            }
            if (_selectedMethod != null) {
              setState(() {
                _selectedMethod = null;
                _amountController.clear();
                _noteController.clear();
                _phoneController.clear();
                _isRecipientValid = false;
                _selectedBtDevice = null;
                _nfcState = NfcState.idle;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _selectedMethod == null ? 'Kirim Uang' : _methodTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _selectedMethod == null
          ? _buildMethodSelection()
          : _selectedMethod == TransferMethod.nfc && _nfcState != NfcState.idle
              ? _buildNfcTransferView()
              : _buildTransferForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  String get _methodTitle {
    switch (_selectedMethod!) {
      case TransferMethod.nfc:
        return 'NFC Transfer';
      case TransferMethod.bluetooth:
        return 'Bluetooth Transfer';
      case TransferMethod.online:
        return 'Kirim Online';
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
            'Pilih Metode Transfer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Setiap metode punya cara kerja yang berbeda',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildMethodCard(
            method: TransferMethod.nfc,
            icon: Icons.nfc_rounded,
            title: 'NFC',
            subtitle: 'Tap antar device',
            description: 'Kedua device harus saling menempel. Cocok untuk pembayaran cepat.',
            color: context.colors.primary,
          ),
          const SizedBox(height: 14),
          _buildMethodCard(
            method: TransferMethod.bluetooth,
            icon: Icons.bluetooth_rounded,
            title: 'Bluetooth',
            subtitle: 'Segera Hadir',
            description: 'Fitur ini sedang dalam pengembangan. Gunakan NFC untuk transfer.',
            color: context.colors.textSecondary,
            isDisabled: true,
          ),
          const SizedBox(height: 14),
          _buildMethodCard(
            method: TransferMethod.online,
            icon: Icons.language_rounded,
            title: 'Online',
            subtitle: 'Segera Hadir',
            description: 'Fitur ini sedang dalam pengembangan. Gunakan NFC untuk transfer.',
            color: context.colors.textSecondary,
            isDisabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required TransferMethod method,
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
                  content: Text('Fitur $title akan tersedia di update berikutnya. Gunakan NFC untuk transfer.'),
                  backgroundColor: context.colors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          : () {
              setState(() => _selectedMethod = method);
              if (method == TransferMethod.nfc) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _amountFocus.requestFocus();
                });
              }
            },
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
              width: 56,
              height: 56,
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
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDisabled ? context.colors.warning : color,
                          ),
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
      ),
    );
  }

  // ─── Step 2: Form (NFC idle / Bluetooth / Online) ───
  Widget _buildTransferForm() {
    final balanceAsync = ref.watch(walletBalanceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMethodIndicator(),
          const SizedBox(height: 16),

          // Hop warning banner
          balanceAsync.when(
            data: (balance) {
              final hopCount = balance?.hopCount ?? 0;
              final maxHop = balance?.maxHop ?? 3;
              if (hopCount >= maxHop) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.colors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded, color: context.colors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Batas transfer offline tercapai. Silakan sync terlebih dahulu.',
                          style: TextStyle(fontSize: 13, color: context.colors.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (hopCount >= maxHop - 1) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: const Color(0xFFFF9500), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sisa 1 transfer offline. Setelah ini perlu sync.',
                          style: TextStyle(fontSize: 13, color: const Color(0xFFE08600), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          if (_selectedMethod == TransferMethod.online) ...[
            _buildOnlineRecipient(),
            const SizedBox(height: 24),
          ],
          if (_selectedMethod == TransferMethod.bluetooth) ...[
            _buildBluetoothDeviceSelector(),
            const SizedBox(height: 24),
          ],
          if (_selectedMethod == TransferMethod.nfc) ...[
            _buildNfcInfo(),
            const SizedBox(height: 24),
          ],

          _buildAmountSection(),
          const SizedBox(height: 20),
          _buildQuickAmounts(),
          const SizedBox(height: 20),

          if (_selectedMethod == TransferMethod.online) _buildNoteInput(),
        ],
      ),
    );
  }

  Widget _buildMethodIndicator() {
    final config = _methodConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.$2.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(config.$1, color: config.$2, size: 20),
          const SizedBox(width: 10),
          Text('Metode: ${_methodTitle}', style: TextStyle(fontWeight: FontWeight.w600, color: config.$2, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              _selectedMethod = null;
              _amountController.clear();
              _phoneController.clear();
              _isRecipientValid = false;
              _selectedBtDevice = null;
              _nfcState = NfcState.idle;
            }),
            child: Text('Ubah', style: TextStyle(fontWeight: FontWeight.w600, color: config.$2, fontSize: 13, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  (IconData, Color) get _methodConfig {
    switch (_selectedMethod!) {
      case TransferMethod.nfc:
        return (Icons.nfc_rounded, context.colors.primary);
      case TransferMethod.bluetooth:
        return (Icons.bluetooth_rounded, context.colors.success);
      case TransferMethod.online:
        return (Icons.language_rounded, context.colors.warning);
    }
  }

  // ─── NFC Info (idle state) ───
  Widget _buildNfcInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.nfc_rounded, color: context.colors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          Text('Siap untuk Tap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 10),
          Text(
            'Masukkan nominal lalu tekan Kirim. Setelah PIN diverifikasi, tempelkan device ke penerima.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── NFC Transfer View (after PIN) ───
  Widget _buildNfcTransferView() {
    final amount = _getParsedAmount();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // NFC animation
          _buildNfcAnimation(),

          const Spacer(flex: 1),

          // Amount
          Text(
            formatRupiah(amount),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Status feedback
          Text(
            _nfcFeedback,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _nfcState == NfcState.failed
                  ? context.colors.error
                  : context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Status pill
          _buildNfcStatusPill(),
          const SizedBox(height: 12),

          // Hint text
          if (_nfcState == NfcState.waitingForTap || _nfcState == NfcState.sending)
            Text(
              'Jangan menjauhkan device sampai transfer selesai',
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
            ),

          const SizedBox(height: 32),

          // Action buttons
          if (_nfcState == NfcState.failed)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _cancelNfcTransfer();
                      setState(() => _selectedMethod = null);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: context.colors.border),
                    ),
                    child: Text('Batal', style: TextStyle(color: context.colors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _resetNfcForRetry();
                      _startNfcTransfer();
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

          if (_nfcState == NfcState.success)
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

          if (_nfcState == NfcState.waitingForTap || _nfcState == NfcState.sending)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelNfcTransfer,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: context.colors.error.withValues(alpha: 0.3)),
                ),
                child: Text('Batalkan Transfer', style: TextStyle(color: context.colors.error)),
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
        final scale = _nfcState == NfcState.waitingForTap || _nfcState == NfcState.sending
            ? _pulseAnimation.value
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
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
                color: _nfcState == NfcState.success
                    ? context.colors.success.withValues(alpha: 0.3)
                    : _nfcState == NfcState.failed
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
                color: _nfcState == NfcState.success
                    ? context.colors.success.withValues(alpha: 0.5)
                    : _nfcState == NfcState.failed
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
              color: _nfcState == NfcState.success
                  ? context.colors.success
                  : _nfcState == NfcState.failed
                      ? context.colors.error
                      : context.colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_nfcState == NfcState.success
                          ? context.colors.success
                          : _nfcState == NfcState.failed
                              ? context.colors.error
                              : context.colors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _nfcState == NfcState.success
                  ? Icons.check_rounded
                  : _nfcState == NfcState.failed
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

  Widget _buildNfcStatusPill() {
    final (color, label) = switch (_nfcState) {
      NfcState.preparing => (context.colors.textSecondary, 'Menyiapkan...'),
      NfcState.waitingForTap => (context.colors.primary, 'Menunggu Tap'),
      NfcState.sending => (context.colors.warning, 'Mengirim...'),
      NfcState.success => (context.colors.success, 'Berhasil'),
      NfcState.failed => (context.colors.error, 'Gagal'),
      NfcState.idle => (context.colors.textSecondary, 'Siap'),
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
          if (_nfcState == NfcState.waitingForTap || _nfcState == NfcState.sending)
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
          if (_nfcState == NfcState.waitingForTap || _nfcState == NfcState.sending)
            const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ─── Online Recipient ───
  Widget _buildOnlineRecipient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nomor Penerima', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _isRecipientValid ? context.colors.success : context.colors.border),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('+62', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '812 3456 7890',
                          hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (v) {
                          if (_isRecipientValid) setState(() { _isRecipientValid = false; _recipientName = ''; });
                        },
                        onSubmitted: (_) => _lookupRecipient(),
                      ),
                    ),
                    if (_phoneController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: context.colors.textSecondary, size: 20),
                        onPressed: () {
                          _phoneController.clear();
                          setState(() { _isRecipientValid = false; _recipientName = ''; });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () { /* TODO: QR scanner */ },
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: context.colors.warning, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        if (_isRecipientValid) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.success.withValues(alpha: 0.2),
                  child: Text(_recipientName[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.success)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_recipientName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                      Text('+62 $_recipientPhone', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, color: context.colors.success, size: 20),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text('Kontak Terakhir', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final names = ['Edwin', 'Sari', 'Budi', 'Dewi', 'Rizky'];
              return GestureDetector(
                onTap: () { _phoneController.text = '812345678${index}0'; _lookupRecipient(); },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: context.colors.warning.withValues(alpha: 0.1),
                      child: Text(names[index][0], style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.warning)),
                    ),
                    const SizedBox(height: 6),
                    Text(names[index], style: TextStyle(fontSize: 11, color: context.colors.textSecondary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Bluetooth Device Selector (Real BLE) ───
  Widget _buildBluetoothDeviceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Device Terdekat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
            if (!_isScanning)
              GestureDetector(
                onTap: _startScan,
                child: Row(children: [
                  Icon(Icons.refresh_rounded, size: 18, color: context.colors.success),
                  const SizedBox(width: 4),
                  Text('Scan Ulang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.success)),
                ]),
              ),
            if (_isScanning)
              GestureDetector(
                onTap: _stopScan,
                child: Row(children: [
                  Icon(Icons.stop_rounded, size: 18, color: context.colors.error),
                  const SizedBox(width: 4),
                  Text('Stop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.error)),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isScanning && _scanResults.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(children: [
              SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 3, color: context.colors.success)),
              const SizedBox(height: 20),
              Text('Mencari device...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
              const SizedBox(height: 6),
              Text('Pastikan Bluetooth aktif & receiver sudah standby', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
            ]),
          )
        else if (_scanResults.isEmpty && !_isScanning)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(children: [
              Icon(Icons.bluetooth_disabled_rounded, size: 48, color: context.colors.textSecondary),
              const SizedBox(height: 16),
              Text('Tidak ditemukan device', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Pastikan receiver sudah dalam mode "Menunggu Transfer"', style: TextStyle(fontSize: 12, color: context.colors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Scan Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
          )
        else ...[
          // Found devices
          ..._scanResults.map((result) {
            final device = result.device;
            final name = result.advertisementData.advName.isNotEmpty
                ? result.advertisementData.advName
                : device.platformName.isNotEmpty
                    ? device.platformName
                    : 'Unknown Device';
            final rssi = result.rssi;
            final isSelected = _selectedBtDevice?.remoteId == device.remoteId;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedBtDevice = device);
                debugPrint('🔵 [BT] Selected: $name (${device.remoteId})');
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.success.withValues(alpha: 0.08) : context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? context.colors.success : context.colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: context.colors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.phone_android_rounded, color: context.colors.success, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.signal_cellular_alt_rounded, size: 14, color: _rssiColor(rssi)),
                        const SizedBox(width: 4),
                        Text('${rssi} dBm', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                        const SizedBox(width: 8),
                        Text('(${_rssiLabel(rssi)})', style: TextStyle(fontSize: 11, color: _rssiColor(rssi))),
                      ]),
                    ]),
                  ),
                  if (isSelected) Icon(Icons.check_circle_rounded, color: context.colors.success, size: 22),
                ]),
              ),
            );
          }),
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.success)),
                  const SizedBox(width: 8),
                  Text('Masih mencari...', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: context.colors.success.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 16, color: context.colors.success),
              const SizedBox(width: 8),
              Expanded(child: Text('Transfer P2P langsung tanpa internet.', style: TextStyle(fontSize: 12, color: context.colors.success, height: 1.4))),
            ]),
          ),
        ],
      ],
    );
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -50) return context.colors.success;
    if (rssi >= -70) return context.colors.warning;
    return context.colors.error;
  }

  String _rssiLabel(int rssi) {
    if (rssi >= -50) return 'Sangat Dekat';
    if (rssi >= -70) return 'Dekat';
    if (rssi >= -80) return 'Sedang';
    return 'Jauh';
  }

  // ─── Amount Section ───
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nominal Transfer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Text('Rp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _amountController,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _RupiahInputFormatter()],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ]),
        ),
        if (_getParsedAmount() > 0 && _getParsedAmount() < 10000) ...[
          const SizedBox(height: 8),
          Text('Minimal transfer Rp 10.000', style: TextStyle(fontSize: 12, color: context.colors.error)),
        ],
      ],
    );
  }

  Widget _buildQuickAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilihan Cepat', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _quickAmounts.map((amount) {
            final isSelected = _getParsedAmount() == amount;
            return GestureDetector(
              onTap: () {
                _amountController.text = amount.toString();
                _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
                _amountFocus.requestFocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primary : context.colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? context.colors.primary : context.colors.border),
                ),
                child: Text(formatRupiah(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : context.colors.textPrimary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catatan (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
          ),
          child: TextField(
            controller: _noteController,
            maxLength: 50,
            style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan...',
              hintStyle: TextStyle(color: context.colors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterStyle: TextStyle(fontSize: 11, color: context.colors.textSecondary),
            ),
          ),
        ),
      ],
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
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: context.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.account_balance_wallet_rounded, color: context.colors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Saldo Tersedia', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
            const SizedBox(height: 4),
            balanceAsync.when(
              data: (balance) {
                final amount = ((balance?.amountCent ?? 0) - (balance?.reservedCent ?? 0)) / 100;
                return Text('Rp ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary));
              },
              loading: () => Text('Memuat...', style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
              error: (_, __) => Text('Rp 0', style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ─── Bottom Bar ───
  Widget? _buildBottomBar() {
    // NFC transfer active → no bottom bar (buttons are in the transfer view)
    if (_selectedMethod == TransferMethod.nfc && _nfcState != NfcState.idle) {
      return null;
    }
    if (_selectedMethod == null) return null;

    final canSend = _canProceed();
    final config = _methodConfig;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: canSend
              ? (_selectedMethod == TransferMethod.nfc ? _startNfcTransfer : _onSendPressed)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSend ? config.$2 : context.colors.border,
            foregroundColor: Colors.white,
            disabledBackgroundColor: context.colors.border,
            disabledForegroundColor: context.colors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_selectedMethod == TransferMethod.nfc
                  ? Icons.nfc_rounded
                  : _selectedMethod == TransferMethod.bluetooth
                      ? Icons.bluetooth_rounded
                      : Icons.send_rounded, size: 20),
              const SizedBox(width: 10),
              Text(
                canSend ? 'Kirim ${formatRupiah(_getParsedAmount())}' : _buttonHintText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _buttonHintText {
    switch (_selectedMethod!) {
      case TransferMethod.nfc:
        return _getParsedAmount() < 10000 ? 'Masukkan Nominal' : 'Siap Kirim';
      case TransferMethod.bluetooth:
        if (_selectedBtDevice == null) return 'Pilih Device Tujuan';
        return _getParsedAmount() < 10000 ? 'Masukkan Nominal' : 'Siap Kirim';
      case TransferMethod.online:
        if (!_isRecipientValid) return 'Masukkan Nomor Penerima';
        return _getParsedAmount() < 10000 ? 'Masukkan Nominal' : 'Siap Kirim';
    }
  }

  // ─── Confirmation Sheet (Bluetooth / Online) ───
  Future<bool?> _showConfirmationSheet(int amount, String note) {
    final config = _methodConfig;
    final recipientLabel = _selectedMethod == TransferMethod.bluetooth ? 'Penerima' : 'Penerima';
    final recipientValue = _selectedMethod == TransferMethod.bluetooth ? (_selectedBtDevice?.platformName ?? 'Device') : '$_recipientName (+62 $_recipientPhone)';

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('Konfirmasi Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 24),
          Text(formatRupiah(amount), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          const SizedBox(height: 24),
          _buildInfoRow(recipientLabel, recipientValue),
          if (_selectedMethod == TransferMethod.online && note.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Catatan', note),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: config.$2.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(config.$1, color: config.$2, size: 20),
              const SizedBox(width: 8),
              Text(_methodTitle, style: TextStyle(fontWeight: FontWeight.w600, color: config.$2)),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: context.colors.border),
                ),
                child: Text('Batal', style: TextStyle(color: context.colors.textPrimary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.$2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Kirim Sekarang', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 16),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: context.colors.textSecondary)),
          Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ─── Success Sheet (Bluetooth / Online) ───
  void _showSuccessSheet(int amount) {
    final config = _methodConfig;
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: context.colors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, color: context.colors.success, size: 48),
          ),
          const SizedBox(height: 24),
          Text('Transfer Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 8),
          Text(formatRupiah(amount), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: context.colors.success)),
          const SizedBox(height: 8),
          Text(
            _selectedMethod == TransferMethod.bluetooth
                ? 'Berhasil dikirim ke ${_selectedBtDevice?.platformName ?? "device"}'
                : 'Berhasil dikirim ke $_recipientName',
            style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {/* TODO: Share */},
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Bagikan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: context.colors.border),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); context.goNamed(AppRouteNames.wallet); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.$2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── Rupiah Input Formatter ───
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

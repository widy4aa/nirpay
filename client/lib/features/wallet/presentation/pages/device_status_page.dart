import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';
import 'package:nirpay/core/database/database_service.dart';

class DeviceStatusPage extends StatefulWidget {
  const DeviceStatusPage({super.key});

  @override
  State<DeviceStatusPage> createState() => _DeviceStatusPageState();
}

class _DeviceStatusPageState extends State<DeviceStatusPage> {
  static const _hceChannel = MethodChannel('nirpay.com/hce');
  static const _sendAckApdu = [0x00, 0xDA, 0x00, 0x00, 0x00];
  static const _ackTimeout = Duration(seconds: 5);

  bool _isNfcAvailable = false;
  bool _isNfcChecked = false;

  bool _isUblActive = false;
  bool _isUblChecked = false;

  bool _isTeeActive = false;
  bool _isTeeChecked = false;

  bool _isDbActive = false;
  bool _isDbChecked = false;

  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    _checkNfcStatus();
    _checkBluetoothStatus();
    _checkSecurityStatus();
  }

  Future<void> _checkSecurityStatus() async {
    // Memanggil API native dari plugin safe_device
    bool isJailBroken = false;
    bool isSafeDevice = false;

    try {
      isJailBroken = await SafeDevice.isJailBroken;
      isSafeDevice = await SafeDevice.isSafeDevice;
    } catch (e) {
      debugPrint('Gagal mengecek status keamanan: $e');
    }

    // Cek status database (AES-256 + TEE)
    final dbStatus = await DatabaseService.checkDatabaseStatus();

    if (mounted) {
      setState(() {
        _isUblActive =
            isJailBroken; // Menggunakan status root/jailbreak untuk representasi UBL yang terbuka
        _isUblChecked = true;
        _isTeeActive =
            isSafeDevice; // Menggunakan isSafeDevice sebagai representasi lingkungan aman (TEE)
        _isTeeChecked = true;
        _isDbActive = dbStatus;
        _isDbChecked = true;
      });
    }
  }

  Future<void> _checkNfcStatus() async {
    try {
      final availability = await NfcManager.instance.checkAvailability();
      final isAvailable = availability == NfcAvailability.enabled;
      if (mounted) {
        setState(() {
          _isNfcAvailable = isAvailable;
          _isNfcChecked = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNfcAvailable = false;
          _isNfcChecked = true;
        });
      }
    }
  }

  void _checkBluetoothStatus() {
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() {
          _bluetoothState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  void _showNfcTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test NFC'),
        content: Text('Pilih mode device untuk test NFC:'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNfcReceiver();
            },
            child: Text(
              'Penerima',
              style: TextStyle(color: Color(0xFF1B1E28)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNfcSenderDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B1E28),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Pengirim'),
          ),
        ],
      ),
    );
  }

  void _startNfcReceiver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Ready to Receiving'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1B1E28)),
            SizedBox(height: 16),
            Text('Dekatkan perangkat pengirim atau tag NFC...'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              NfcManager.instance.stopSession();
              Navigator.pop(context);
            },
            child: Text(
              'Batal',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          String resultText =
              'NFC Tag terdeteksi, tapi bukan dari perangkat Nirpay.';

          try {
            final isoDep = IsoDepAndroid.from(tag);
            if (isoDep != null) {
              // Kirim SELECT AID APDU
              final selectApdu = Uint8List.fromList([
                0x00,
                0xA4,
                0x04,
                0x00,
                0x07,
                0xF0,
                0x01,
                0x02,
                0x03,
                0x04,
                0x05,
                0x06,
              ]);
              final selectResponse = await isoDep.transceive(selectApdu);

              if (selectResponse.length >= 2 &&
                  selectResponse[selectResponse.length - 2] == 0x90 &&
                  selectResponse[selectResponse.length - 1] == 0x00) {
                // Jika SELECT berhasil, kirim READ DATA APDU
                final readApdu = Uint8List.fromList([
                  0x00,
                  0xCA,
                  0x00,
                  0x00,
                  0x00,
                ]);
                final readResponse = await isoDep.transceive(readApdu);

                if (readResponse.length >= 2 &&
                    readResponse[readResponse.length - 2] == 0x90 &&
                    readResponse[readResponse.length - 1] == 0x00) {
                  final dataBytes = readResponse.sublist(
                    0,
                    readResponse.length - 2,
                  );
                  final nfcData = utf8.decode(dataBytes);
                  final ackResponse = await isoDep.transceive(
                    Uint8List.fromList(_sendAckApdu),
                  );
                  final isAckAccepted =
                      ackResponse.length >= 2 &&
                      ackResponse[ackResponse.length - 2] == 0x90 &&
                      ackResponse[ackResponse.length - 1] == 0x00;

                  resultText = isAckAccepted
                      ? 'Data diterima: $nfcData\nACK terkirim ke pengirim.'
                      : 'Data diterima: $nfcData\nACK gagal dikirim ke pengirim.';
                } else {
                  resultText = 'Gagal membaca data dari perangkat Pengirim.';
                }
              }
            }
          } catch (e) {
            resultText = 'Gagal memproses HCE: $e';
          }

          NfcManager.instance.stopSession();

          if (mounted) {
            Navigator.pop(context); // Close loading
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Hasil Terima NFC'),
                content: Text(resultText),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Color(0xFF1B1E28)),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } catch (e) {
      NfcManager.instance.stopSession();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showNfcSenderDialog() {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kirim via NFC'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Masukkan teks untuk dikirim',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B1E28)),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (textController.text.isNotEmpty) {
                _startNfcSender(textController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B1E28),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Pairing'),
          ),
        ],
      ),
    );
  }

  void _startNfcSender(String data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pairing...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1B1E28)),
            SizedBox(height: 16),
            Text(
              'Sebagai Pengirim, HCE telah aktif. Silakan tempelkan perangkat ini ke HP Penerima.',
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Batal',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    try {
      final transactionId = DateTime.now().microsecondsSinceEpoch.toString();
      await _hceChannel.invokeMethod('setNfcData', {
        'data': data,
        'transactionId': transactionId,
      });
      unawaited(_waitForAckFeedback(transactionId));
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal set HCE data: $e')));
      }
    }
  }

  Future<void> _waitForAckFeedback(String transactionId) async {
    DateTime? dataSentAt;

    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 400));

      final rawStatus = await _hceChannel.invokeMapMethod<String, Object?>(
        'getNfcTransferStatus',
      );
      final status = rawStatus?['status']?.toString() ?? 'IDLE';
      final activeTransactionId = rawStatus?['transactionId']?.toString();

      if (activeTransactionId != transactionId) return;

      if (status == 'PENDING_SYNC') {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diterima penerima'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
        return;
      }

      if (status == 'DATA_SENT') {
        dataSentAt ??= DateTime.now();
        if (DateTime.now().difference(dataSentAt) >= _ackTimeout) {
          await _hceChannel.invokeMethod('markNoAck');
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'NO_ACK: penerima belum mengonfirmasi. Silakan tap ulang.',
              ),
              backgroundColor: Color(0xFFFF9500),
            ),
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F7FB), Colors.white, Color(0xFFC7F4ED)],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Status Hardware',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E24),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Berikut adalah status konektivitas perangkat keras yang diperlukan untuk transaksi aplikasi Anda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7D8C9E),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildStatusCard(
                  title: 'Bluetooth',
                  icon: Icons.bluetooth_rounded,
                  isActive: _bluetoothState == BluetoothAdapterState.on,
                  isLoading: _bluetoothState == BluetoothAdapterState.unknown,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  title: 'NFC',
                  icon: Icons.nfc_rounded,
                  isActive: _isNfcAvailable,
                  isLoading: !_isNfcChecked,
                  actionButton: _isNfcAvailable
                      ? InkWell(
                          onTap: _showNfcTestDialog,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1E28),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  title: 'Unlocked Bootloader (UBL)',
                  icon: Icons.lock_open_rounded,
                  isActive: _isUblActive,
                  isLoading: !_isUblChecked,
                  isWarningIfActive: true, // UBL aktif berarti rentan
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  title: 'Trusted Execution Env (TEE)',
                  icon: Icons.security_rounded,
                  isActive: _isTeeActive,
                  isLoading: !_isTeeChecked,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  title: 'Database Lokal (AES-256)',
                  icon: Icons.storage_rounded,
                  isActive: _isDbActive,
                  isLoading: !_isDbChecked,
                ),
              ],
            ),
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1E28)),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Cek Device',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B1E28),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isLoading,
    bool isWarningIfActive = false,
    Widget? actionButton,
  }) {
    Color statusColor;
    if (isWarningIfActive) {
      statusColor = isActive
          ? const Color(0xFFFF3B30)
          : const Color(0xFF34C759);
    } else {
      statusColor = isActive
          ? const Color(0xFF34C759)
          : const Color(0xFFFF3B30);
    }

    final statusText = isActive ? 'Aktif' : 'Non-Aktif';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E6EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E1E24), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E24),
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actionButton != null) ...[
                  actionButton,
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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
}

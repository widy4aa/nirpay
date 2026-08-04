import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';

enum PinStep { verifyOld, enterNew, confirmNew, success }

class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({super.key});

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  PinStep _step = PinStep.verifyOld;
  String _oldPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String _errorMessage = '';
  bool _isProcessing = false;

  void _onDigitPressed(String digit) {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = '';

      switch (_step) {
        case PinStep.verifyOld:
          if (_oldPin.length < 6) {
            _oldPin += digit;
            if (_oldPin.length == 6) {
              _verifyOldPin();
            }
          }
          break;
        case PinStep.enterNew:
          if (_newPin.length < 6) {
            _newPin += digit;
            if (_newPin.length == 6) {
              setState(() => _step = PinStep.confirmNew);
            }
          }
          break;
        case PinStep.confirmNew:
          if (_confirmPin.length < 6) {
            _confirmPin += digit;
            if (_confirmPin.length == 6) {
              _changePin();
            }
          }
          break;
        case PinStep.success:
          break;
      }
    });
  }

  void _onBackspace() {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = '';
      switch (_step) {
        case PinStep.verifyOld:
          if (_oldPin.isNotEmpty) _oldPin = _oldPin.substring(0, _oldPin.length - 1);
          break;
        case PinStep.enterNew:
          if (_newPin.isNotEmpty) _newPin = _newPin.substring(0, _newPin.length - 1);
          break;
        case PinStep.confirmNew:
          if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          break;
        case PinStep.success:
          break;
      }
    });
  }

  Future<void> _verifyOldPin() async {
    final storage = ref.read(secureStorageProvider);
    final savedPinHash = await storage.read('saved_pin_hash');

    if (savedPinHash == null) {
      setState(() {
        _errorMessage = 'PIN tidak tersimpan. Login ulang dengan internet.';
        _oldPin = '';
      });
      return;
    }

    // Convert PHP bcrypt $2y$ ke Dart $2b$
    final hash = savedPinHash.replaceAll(r'$2y$', r'$2b$');
    final isValid = BCrypt.checkpw(_oldPin, hash);

    if (isValid) {
      setState(() => _step = PinStep.enterNew);
    } else {
      setState(() {
        _errorMessage = 'PIN lama salah';
        _oldPin = '';
      });
    }
  }

  Future<void> _changePin() async {
    // Validasi PIN baru sama dengan konfirmasi
    if (_newPin != _confirmPin) {
      setState(() {
        _errorMessage = 'PIN baru tidak cocok';
        _confirmPin = '';
      });
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final storage = ref.read(secureStorageProvider);
      final accessToken = await storage.read('access_token');

      // Update PIN hash lokal
      final newHash = BCrypt.hashpw(_newPin, BCrypt.gensalt());
      await storage.write('saved_pin_hash', newHash);

      // Jika online, sync ke server
      if (accessToken != null && accessToken != 'offline_token' && accessToken != 'seeded_token') {
        try {
          final config = ref.read(appConfigProvider);
          final dio = Dio(BaseOptions(
            baseUrl: config.apiBaseUrl,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          ));

          // Convert Dart $2b$ ke PHP $2y$ untuk server
          final phpHash = newHash.replaceAll(r'$2b$', r'$2y$');

          await dio.post(
            '/profile/change-pin',
            data: {
              'oldPin': _oldPin,
              'newPin': _newPin,
              'newPin_confirmation': _confirmPin,
            },
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );

          debugPrint('🔑 [ChangePIN] PIN synced to server');
        } catch (e) {
          debugPrint('🔑 [ChangePIN] Failed to sync PIN to server: $e');
          // Tetap lanjut — PIN sudah tersimpan lokal
        }
      }

      setState(() => _step = PinStep.success);

      // Tampilkan SnackBar sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('PIN berhasil diubah!'),
              ],
            ),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Auto-navigate ke home setelah2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop(); // Kembali ke settings
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengubah PIN: $e';
        _isProcessing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _step = PinStep.verifyOld;
      _oldPin = '';
      _newPin = '';
      _confirmPin = '';
      _errorMessage = '';
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () {
            if (_step == PinStep.success) {
              context.pop();
            } else if (_step == PinStep.confirmNew || _step == PinStep.enterNew) {
              _reset();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Ubah PIN',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Icon
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _step == PinStep.success
                    ? colors.success.withValues(alpha: 0.1)
                    : colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _step == PinStep.success
                    ? Icons.check_circle_rounded
                    : Icons.lock_rounded,
                color: _step == PinStep.success ? colors.success : colors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              _getSubtitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // PIN dots
            _buildPinDots(colors),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            if (_step == PinStep.success) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colors.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'PIN baru sudah disimpan. Gunakan PIN baru untuk login berikutnya.',
                          style: TextStyle(fontSize: 13, color: colors.success, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Kembali ke Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(flex: 2),

            // Number pad
            if (_step != PinStep.success) _buildNumberPad(colors),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_step) {
      case PinStep.verifyOld:
        return 'Masukkan PIN Lama';
      case PinStep.enterNew:
        return 'Masukkan PIN Baru';
      case PinStep.confirmNew:
        return 'Konfirmasi PIN Baru';
      case PinStep.success:
        return 'PIN Berhasil Diubah!';
    }
  }

  String _getSubtitle() {
    switch (_step) {
      case PinStep.verifyOld:
        return 'Masukkan PIN 6 digit Anda saat ini';
      case PinStep.enterNew:
        return 'Buat PIN 6 digit baru Anda';
      case PinStep.confirmNew:
        return 'Masukkan ulang PIN baru Anda';
      case PinStep.success:
        return 'PIN Anda telah berhasil diubah.\nGunakan PIN baru untuk login berikutnya.';
    }
  }

  Widget _buildPinDots(AppColorsExtension colors) {
    String currentPin;
    switch (_step) {
      case PinStep.verifyOld:
        currentPin = _oldPin;
        break;
      case PinStep.enterNew:
        currentPin = _newPin;
        break;
      case PinStep.confirmNew:
        currentPin = _confirmPin;
        break;
      case PinStep.success:
        currentPin = '6';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < currentPin.length;
        final hasError = _errorMessage.isNotEmpty && _step != PinStep.success;

        return Container(
          width: 16, height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _step == PinStep.success
                ? colors.success
                : isFilled
                    ? colors.primary
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? colors.error
                  : _step == PinStep.success
                      ? colors.success
                      : isFilled
                          ? colors.primary
                          : colors.border,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (int row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    _buildNumberButton('${row * 3 + col + 1}', colors),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _buildNumberButton('0', colors),
              _buildBackspaceButton(colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String digit, AppColorsExtension colors) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(AppColorsExtension colors) {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Center(
          child: Icon(Icons.backspace_rounded, color: colors.textPrimary, size: 24),
        ),
      ),
    );
  }
}

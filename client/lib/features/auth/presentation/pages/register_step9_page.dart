import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cryptography/cryptography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/pin_input_widget.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../providers/registration_form_provider.dart';

class RegisterStep9Page extends ConsumerStatefulWidget {
  RegisterStep9Page({super.key});

  @override
  ConsumerState<RegisterStep9Page> createState() => _RegisterStep9PageState();
}

class _RegisterStep9PageState extends ConsumerState<RegisterStep9Page> {
  final _pinNotifier = ValueNotifier<String>('');

  @override
  void dispose() {
    _pinNotifier.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_pinNotifier.value.length < 6) {
      _pinNotifier.value += number;
    }
  }

  void _onDeleteTap() {
    if (_pinNotifier.value.isNotEmpty) {
      _pinNotifier.value = _pinNotifier.value.substring(0, _pinNotifier.value.length - 1);
    }
  }

  void _onNext() async {
    if (_pinNotifier.value.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan 6 digit PIN'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    try {
      final formState = ref.read(registrationFormProvider);

      final ed25519 = Ed25519();
      final keyPair = await ed25519.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyB64 = base64Encode(publicKey.bytes);

      final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
      await ref
          .read(secureStorageProvider)
          .write('ed25519_private_key', base64Encode(privateKeyBytes));

      final params = RegisterParams(
        email: formState.email,
        phone: formState.phone,
        username: formState.username,
        fullName: formState.fullName,
        pin: _pinNotifier.value,
        password: formState.password,
        publicKeyB64: publicKeyB64,
        nik: formState.nik,
        province: formState.province,
        city: formState.city,
        district: formState.district,
        village: formState.village,
        postalCode: formState.postalCode,
        rt: formState.rt,
        rw: formState.rw,
        ktpPhotoUrl: formState.ktpPhotoUrl,
        kycFaceUrl: formState.kycFaceUrl,
        gender: formState.gender,
        birthDate: formState.birthDate,
      );

      await ref.read(authControllerProvider.notifier).register(params);

      // Simpan PIN ke local storage untuk verifikasi lokal nanti
      await ref.read(secureStorageProvider).write('saved_pin', _pinNotifier.value);

      if (mounted) {
        context.goNamed(AppRouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: context.colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Container(
      decoration: BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressBar(),
                    const SizedBox(height: 32),
                    _buildHeader(),
                  ],
                ),
              ),
              const Spacer(),
              PinInputWidget(
                pinNotifier: _pinNotifier,
                onNumberTap: _onNumberTap,
                onDeleteTap: _onDeleteTap,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildNextButton(context, isLoading),
              ),
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Registrasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah 9 dari 9',
          style: TextStyle(
            color: context.colors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Buat PIN Keamanan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          'PIN 6-digit ini akan digunakan untuk\nlogin dan memverifikasi transaksi.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Selesai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    );
  }
}

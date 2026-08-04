import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/pin_input_widget.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/network_service.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _pinNotifier = ValueNotifier<String>('');
  bool _isEmailStep = true;
  bool _pinOnly = false;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  Future<void> _checkExistingSession() async {
    FlowLogger.page('LoginPage — Checking session');
    final storage = ref.read(secureStorageProvider);
    final savedPinHash = await storage.read('saved_pin_hash');

    if (mounted) {
      setState(() {
        _checkingSession = false;

        // Sudah pernah login → langsung ke PIN
        if (savedPinHash != null && savedPinHash.isNotEmpty) {
          _pinOnly = true;
          _isEmailStep = false;
          FlowLogger.state('LoginPage', 'PIN Mode', data: {'hasPinHash': true});
        } else {
          FlowLogger.state('LoginPage', 'Login Form Mode', data: {'hasPinHash': false});
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pinNotifier.dispose();
    super.dispose();
  }

  void _onEmailSubmit() {
    if (_formKey.currentState!.validate()) {
      // Login langsung dengan email + password (tanpa PIN)
      _onLogin();
    }
  }

  void _onNumberTap(String number) {
    if (_pinNotifier.value.length < 6) {
      _pinNotifier.value += number;
      if (_pinNotifier.value.length == 6) {
        _onVerifyPin();
      }
    }
  }

  void _onDeleteTap() {
    if (_pinNotifier.value.isNotEmpty) {
      _pinNotifier.value = _pinNotifier.value.substring(0, _pinNotifier.value.length - 1);
    }
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    FlowLogger.action('Login', params: {
      'email': email,
      'password': '${password.substring(0, 2)}${'*' * (password.length - 2)}',
      'passwordLength': password.length,
    });

    // 1. Cek koneksi
    final networkService = ref.read(networkServiceProvider);
    final isConnected = await networkService.isConnected();

    if (!isConnected && mounted) {
      FlowLogger.error('LoginPage', 'Tidak ada koneksi internet');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.wifi_off, color: Colors.red, size: 48),
          title: Text('Tidak Ada Koneksi'),
          content: Text(
            'Pastikan perangkat terhubung ke internet untuk melakukan login.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Login ke server (hanya email + password)
    try {
      await ref.read(authControllerProvider.notifier).login(
        email,
        _passwordController.text,
      );

      FlowLogger.success('Login berhasil');

      // Cek apakah sudah ada pinHash tersimpan
      final storage = ref.read(secureStorageProvider);
      final savedPinHash = await storage.read('saved_pin_hash');

      if (mounted) {
        if (savedPinHash != null && savedPinHash.isNotEmpty) {
          // Sudah ada pinHash → minta verifikasi PIN dulu
          FlowLogger.state('LoginPage', 'PIN verification after login');
          setState(() {
            _pinOnly = true;
            _isEmailStep = false;
          });
        } else {
          // Belum ada PIN → langsung wallet
          FlowLogger.state('LoginPage', 'No PIN saved → direct to Wallet');
          context.goNamed(AppRouteNames.wallet);
        }
      }
    } catch (e) {
      _pinNotifier.value = '';
      FlowLogger.error('LoginPage — Login', e);

      if (mounted) {
        final errorStr = e.toString();

        // 3. Cek KYC status
        if (errorStr.contains('KYC_PENDING') || errorStr.contains('KYC belum')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              icon: Icon(Icons.warning_amber, color: Colors.amber, size: 48),
              title: Text('KYC Belum Disetujui'),
              content: Text(
                'Akun Anda sedang dalam proses verifikasi. '
                'Silakan tunggu hingga admin menyetujui KYC Anda.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.goNamed(AppRouteNames.kycPending);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorStr),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }

  void _onVerifyPin() async {
    FlowLogger.action('Verify PIN', params: {'pin': _pinNotifier.value, 'pinLength': _pinNotifier.value.length});
    try {
      await ref.read(authControllerProvider.notifier).verifyPin(_pinNotifier.value);
      FlowLogger.success('PIN verified → navigasi ke Wallet');
      if (mounted) {
        context.goNamed(AppRouteNames.wallet);
      }
    } catch (e) {
      _pinNotifier.value = '';
      FlowLogger.error('LoginPage — Verify PIN', e);
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    if (_checkingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: (_isEmailStep && !_pinOnly) ? null : _buildAppBar(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isEmailStep
            ? _buildEmailStep()
            : _buildPinStep(isLoading),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leading: _pinOnly
          ? null
          : IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: context.colors.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  _isEmailStep = true;
                });
                _pinNotifier.value = '';
              },
            ),
    );
  }

  Widget _buildEmailStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 48),
            _buildLogo(),
            const SizedBox(height: 48),
            Text(
              'Selamat Datang Kembali!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Masukkan email dan password Anda',
              style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
            ),
            SizedBox(height: 32),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onEmailSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Lanjutkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 32),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinStep(bool isLoading) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - kToolbarHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Masukkan PIN Anda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Masukkan PIN 6-digit untuk\nmelanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  if (isLoading)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
            if (!isLoading)
              PinInputWidget(
                pinNotifier: _pinNotifier,
                onNumberTap: _onNumberTap,
                onDeleteTap: _onDeleteTap,
              ),
        if (_pinOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
            child: Center(
              child: TextButton(
                onPressed: () async {
                  final storage = ref.read(secureStorageProvider);
                  await storage.deleteAll();
                  if (mounted) {
                    setState(() {
                      _pinOnly = false;
                      _isEmailStep = true;
                    });
                    _pinNotifier.value = '';
                  }
                },
                child: Text(
                  'Bukan akun Anda? Login ulang',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 32),
      ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: 40,
          color: context.colors.primary,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
          if (!value.contains('@')) return 'Format email tidak valid';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Email Anda',
          hintStyle: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: context.colors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password tidak boleh kosong';
          }
          if (value.length < 8) return 'Minimal 8 karakter';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: context.colors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => context.pushNamed(AppRouteNames.registerStep1),
          child: Text(
            'Daftar',
            style: TextStyle(
              color: context.colors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

}

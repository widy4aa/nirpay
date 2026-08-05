import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/services/secure_storage_service.dart';
import 'package:nirpay/features/auth/presentation/pages/login_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step1_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step2_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step3_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step4_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step5_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step6_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step7_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step8_page.dart';
import 'package:nirpay/features/auth/presentation/pages/register_step9_page.dart';
import 'package:nirpay/features/auth/presentation/pages/kyc_pending_page.dart';
import 'package:nirpay/features/sync/presentation/pages/status_sync_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/nfc_transfer_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/receive_money_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/send_money_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/history_page.dart';
import 'package:nirpay/features/settings/presentation/pages/settings_page.dart';
import 'package:nirpay/features/settings/presentation/pages/personal_info_page.dart';
import 'package:nirpay/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/topup_page.dart';
import 'package:nirpay/features/transaction/presentation/pages/withdraw_page.dart';
import 'package:nirpay/features/settings/presentation/pages/change_pin_page.dart';
import 'package:nirpay/features/wallet/presentation/pages/device_status_page.dart';
import 'package:nirpay/features/wallet/presentation/pages/home_page.dart';
import 'package:nirpay/shared/widgets/app_shell.dart';

// ─── Custom Transition Helpers ───

/// Fade transition untuk tab navigation (Home ↔ History ↔ Settings)
Page<T> _fadePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

/// Slide from right untuk push navigation (Kirim, Top Up, dll)
Page<T> _slideFromRightPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Slide from bottom untuk modal-like pages (NFC, Receive, dll)
Page<T> _slideFromBottomPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

class AppRoutePaths {
  static const String wallet = '/wallet';
  static const String history = '/history';
  static const String sendMoney = '/send-money';
  static const String nfcTransfer = '/nfc-transfer';
  static const String receiveMoney = '/receive-money';
  static const String statusSync = '/status-sync';
  static const String settings = '/settings';
  static const String deviceStatus = '/device-status';
  static const String personalInfo = '/personal-info';
  static const String editProfile = '/edit-profile';
  static const String topUp = '/topup';
  static const String withdraw = '/withdraw';
  static const String changePin = '/change-pin';
  static const String login = '/login';
  static const String kycPending = '/kyc-pending';
  static const String registerStep1 = '/register-step-1';
  static const String registerStep2 = '/register-step-2';
  static const String registerStep3 = '/register-step-3';
  static const String registerStep4 = '/register-step-4';
  static const String registerStep5 = '/register-step-5';
  static const String registerStep6 = '/register-step-6';
  static const String registerStep7 = '/register-step-7';
  static const String registerStep8 = '/register-step-8';
  static const String registerStep9 = '/register-step-9';

  const AppRoutePaths._();
}

class AppRouteNames {
  static const String wallet = 'wallet';
  static const String history = 'history';
  static const String sendMoney = 'sendMoney';
  static const String nfcTransfer = 'nfcTransfer';
  static const String receiveMoney = 'receiveMoney';
  static const String statusSync = 'statusSync';
  static const String settings = 'settings';
  static const String deviceStatus = 'deviceStatus';
  static const String personalInfo = 'personalInfo';
  static const String editProfile = 'editProfile';
  static const String topUp = 'topUp';
  static const String withdraw = 'withdraw';
  static const String changePin = 'changePin';
  static const String login = 'login';
  static const String kycPending = 'kycPending';
  static const String registerStep1 = 'registerStep1';
  static const String registerStep2 = 'registerStep2';
  static const String registerStep3 = 'registerStep3';
  static const String registerStep4 = 'registerStep4';
  static const String registerStep5 = 'registerStep5';
  static const String registerStep6 = 'registerStep6';
  static const String registerStep7 = 'registerStep7';
  static const String registerStep8 = 'registerStep8';
  static const String registerStep9 = 'registerStep9';

  const AppRouteNames._();
}

// Daftar route yang tidak butuh autentikasi
const _publicRoutes = [
  AppRoutePaths.login,
  AppRoutePaths.registerStep1,
  AppRoutePaths.registerStep2,
  AppRoutePaths.registerStep3,
  AppRoutePaths.registerStep4,
  AppRoutePaths.registerStep5,
  AppRoutePaths.registerStep6,
  AppRoutePaths.registerStep7,
  AppRoutePaths.registerStep8,
  AppRoutePaths.registerStep9,
  AppRoutePaths.kycPending,
];

final goRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.read(secureStorageProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.login,
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(path);

      // Cek apakah ada session tersimpan
      final accessToken = await storage.read('access_token');
      final refreshToken = await storage.read('refresh_token');
      final savedPin = await storage.read('saved_pin');
      final hasSession = (accessToken != null && accessToken.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty) ||
          (savedPin != null && savedPin.isNotEmpty);

      // Jika tidak ada session & bukan public route → ke login
      if (!hasSession && !isPublicRoute) {
        return AppRoutePaths.login;
      }

      // Jika ada session & sedang di login page → biarkan (LoginPage handle PIN mode)
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.kycPending,
        name: AppRouteNames.kycPending,
        builder: (context, state) => KycPendingPage(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep1,
        name: AppRouteNames.registerStep1,
        builder: (context, state) => RegisterStep1Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep2,
        name: AppRouteNames.registerStep2,
        builder: (context, state) => RegisterStep2Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep3,
        name: AppRouteNames.registerStep3,
        builder: (context, state) => RegisterStep3Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep4,
        name: AppRouteNames.registerStep4,
        builder: (context, state) => RegisterStep4Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep5,
        name: AppRouteNames.registerStep5,
        builder: (context, state) => RegisterStep5Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep6,
        name: AppRouteNames.registerStep6,
        builder: (context, state) => RegisterStep6Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep7,
        name: AppRouteNames.registerStep7,
        builder: (context, state) => RegisterStep7Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep8,
        name: AppRouteNames.registerStep8,
        builder: (context, state) => RegisterStep8Page(),
      ),
      GoRoute(
        path: AppRoutePaths.registerStep9,
        name: AppRouteNames.registerStep9,
        builder: (context, state) => RegisterStep9Page(),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) {
          return _fadePage(AppShell(child: child), state);
        },
        routes: [
          GoRoute(
            path: AppRoutePaths.wallet,
            name: AppRouteNames.wallet,
            pageBuilder: (context, state) => _fadePage(HomePage(), state),
          ),
          GoRoute(
            path: AppRoutePaths.history,
            name: AppRouteNames.history,
            pageBuilder: (context, state) => _fadePage(HistoryPage(), state),
          ),
          GoRoute(
            path: AppRoutePaths.settings,
            name: AppRouteNames.settings,
            pageBuilder: (context, state) => _fadePage(SettingsPage(), state),
          ),
        ],
      ),
      // ─── Slide from right (push pages) ───
      GoRoute(
        path: AppRoutePaths.sendMoney,
        name: AppRouteNames.sendMoney,
        pageBuilder: (context, state) => _slideFromRightPage(SendMoneyPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.statusSync,
        name: AppRouteNames.statusSync,
        pageBuilder: (context, state) => _slideFromRightPage(StatusSyncPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.deviceStatus,
        name: AppRouteNames.deviceStatus,
        pageBuilder: (context, state) => _slideFromRightPage(DeviceStatusPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.personalInfo,
        name: AppRouteNames.personalInfo,
        pageBuilder: (context, state) => _slideFromRightPage(PersonalInfoPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.editProfile,
        name: AppRouteNames.editProfile,
        pageBuilder: (context, state) => _slideFromRightPage(EditProfilePage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.topUp,
        name: AppRouteNames.topUp,
        pageBuilder: (context, state) => _slideFromRightPage(TopUpPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.withdraw,
        name: AppRouteNames.withdraw,
        pageBuilder: (context, state) => _slideFromRightPage(WithdrawPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.changePin,
        name: AppRouteNames.changePin,
        pageBuilder: (context, state) => _slideFromRightPage(ChangePinPage(), state),
      ),

      // ─── Slide from bottom (modal-like pages) ───
      GoRoute(
        path: AppRoutePaths.nfcTransfer,
        name: AppRouteNames.nfcTransfer,
        pageBuilder: (context, state) => _slideFromBottomPage(NfcTransferPage(), state),
      ),
      GoRoute(
        path: AppRoutePaths.receiveMoney,
        name: AppRouteNames.receiveMoney,
        pageBuilder: (context, state) => _slideFromBottomPage(ReceiveMoneyPage(), state),
      ),
    ],
    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  );
});

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Route error: ${error ?? 'Unknown error'}')),
    );
  }
}

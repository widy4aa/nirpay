import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nirpay/core/router/app_router.dart';
import 'package:nirpay/core/theme/app_theme.dart';
import 'package:nirpay/core/services/device_service.dart';
import 'package:nirpay/core/services/auto_sync_service.dart';
import 'package:nirpay/core/services/secure_storage_service.dart';
import 'package:nirpay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nirpay/features/auth/presentation/providers/auth_providers.dart';
import 'package:nirpay/features/settings/presentation/providers/settings_provider.dart';
import 'package:nirpay/features/sync/presentation/providers/last_sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceServiceProvider.overrideWithValue(DeviceService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Trigger sync saat app resume dari background
    if (state == AppLifecycleState.resumed) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        debugPrint('🔄 [App] Resumed — triggering auto sync');
        ref.read(autoSyncServiceProvider).onAppResume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Restore user session
    ref.watch(authControllerProvider);
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'NirPay',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

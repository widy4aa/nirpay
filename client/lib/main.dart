import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nirpay/core/router/app_router.dart';
import 'package:nirpay/core/theme/app_theme.dart';
import 'package:nirpay/core/database/seeders/client_seeder.dart';
import 'package:nirpay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nirpay/features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

final _seedProvider = FutureProvider<void>((ref) async {
  final seeder = ref.read(clientSeederProvider);
  await seeder.seedDummyUser();
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed data & restore user dari local DB
    ref.watch(_seedProvider);
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

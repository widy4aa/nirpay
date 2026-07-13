import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirpay/app/app.dart';
import 'package:nirpay/app/app_observer.dart';
import 'package:nirpay/core/services/app_logger.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = AppLogger.create();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          observers: [AppObserver(logger)],
          overrides: [appLoggerProvider.overrideWithValue(logger)],
          child: const NirpayApp(),
        ),
      );
    },
    (error, stackTrace) {
      logger.e('ZoneError', error: error, stackTrace: stackTrace);
    },
  );
}

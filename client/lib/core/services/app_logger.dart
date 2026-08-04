import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class AppLogger {
  const AppLogger._();

  static Logger create() {
    return Logger(
      filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
      ),
    );
  }
}

/// Logger khusus untuk track page & data flow
class FlowLogger {
  static final _logger = AppLogger.create();

  /// Log saat masuk page
  static void page(String pageName, {Map<String, dynamic>? data}) {
    final dataStr = data != null ? _formatData(data) : '';
    _logger.i(
      '📍 PAGE: $pageName'
      '${dataStr.isNotEmpty ? '\n   Data: $dataStr' : ''}',
    );
  }

  /// Log data yang ditampilkan di UI
  static void data(String label, dynamic value) {
    _logger.d(
      '📊 [$label] ${_formatValue(value)}',
    );
  }

  /// Log action/user interaction
  static void action(String action, {Map<String, dynamic>? params}) {
    final paramsStr = params != null ? _formatData(params) : '';
    _logger.i(
      '👆 ACTION: $action'
      '${paramsStr.isNotEmpty ? '\n   Params: $paramsStr' : ''}',
    );
  }

  /// Log state change
  static void state(String component, String newState, {dynamic data}) {
    final dataStr = data != null ? _formatValue(data) : '';
    _logger.d(
      '🔄 STATE: $component → $newState'
      '${dataStr.isNotEmpty ? '\n   Data: $dataStr' : ''}',
    );
  }

  /// Log API call dengan context
  static void api(String method, String endpoint, {dynamic requestBody, dynamic response}) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 API: $method $endpoint');
    if (requestBody != null) buffer.writeln('   Request: ${_formatValue(requestBody)}');
    if (response != null) buffer.writeln('   Response: ${_formatValue(response)}');
    _logger.i(buffer.toString().trim());
  }

  /// Log error dengan context
  static void error(String context, dynamic error, {StackTrace? stackTrace}) {
    _logger.e(
      '❌ ERROR di $context\n   $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log success
  static void success(String message, {dynamic data}) {
    final dataStr = data != null ? _formatValue(data) : '';
    _logger.i(
      '✅ $message'
      '${dataStr.isNotEmpty ? '\n   Data: $dataStr' : ''}',
    );
  }

  static String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}: ${_formatValue(e.value)}').join(', ');
  }

  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is Map || value is List) return value.toString();
    return value.toString();
  }
}

final appLoggerProvider = Provider<Logger>((ref) => AppLogger.create());

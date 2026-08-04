import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  final Logger _logger;

  LoggerInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final uri = options.uri;

    _logger.i(
      '┌── REQUEST ──────────────────────────────────────\n'
      '│ $method $uri\n'
      '│ Headers: ${_formatHeaders(options.headers)}\n'
      '│ Body: ${_formatBody(options.data)}\n'
      '└────────────────────────────────────────────────',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final uri = response.requestOptions.uri;
    final statusCode = response.statusCode;

    _logger.i(
      '┌── RESPONSE ─────────────────────────────────────\n'
      '│ $method $uri\n'
      '│ Status: $statusCode\n'
      '│ Body: ${_formatBody(response.data)}\n'
      '└────────────────────────────────────────────────',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method.toUpperCase();
    final uri = err.requestOptions.uri;
    final statusCode = err.response?.statusCode;

    _logger.e(
      '┌── ERROR ────────────────────────────────────────\n'
      '│ $method $uri\n'
      '│ Status: $statusCode\n'
      '│ Type: ${err.type}\n'
      '│ Message: ${err.message}\n'
      '│ Response: ${_formatBody(err.response?.data)}\n'
      '└────────────────────────────────────────────────',
    );

    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    return headers.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';
    if (data is Map || data is List) {
      return data.toString();
    }
    return data.toString();
  }
}

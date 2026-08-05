import 'package:nirpay/core/config/app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableNetworkLogs,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableNetworkLogs;

  factory AppConfig.fromEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.dev:
        return const AppConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://10.161.163.215:3001/api',
          enableNetworkLogs: true,
        );
      case AppEnvironment.staging:
        return const AppConfig(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://api-staging.example.com',
          enableNetworkLogs: true,
        );
      case AppEnvironment.prod:
        return const AppConfig(
          environment: AppEnvironment.prod,
          apiBaseUrl: 'https://api.example.com',
          enableNetworkLogs: false,
        );
    }
  }

  static AppEnvironment parse(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      default:
        return AppEnvironment.prod;
    }
  }
}

const String _appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
final AppConfig currentAppConfig = AppConfig.fromEnvironment(
  AppConfig.parse(_appEnv),
);

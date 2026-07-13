# AGENTS.md — Client (Flutter) Coding Conventions
> **Single source of truth** untuk semua coding style di `client/`.
> Wajib diikuti oleh semua agent/programmer yang kerja di folder ini.

---

## 1. Architecture: Clean Architecture + Feature-Based

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── app_bootstrap.dart
├── core/
│   ├── config/          # AppConfig, env
│   ├── constants/       # App-wide constants
│   ├── database/        # Drift DB + SQLCipher
│   ├── errors/          # Sealed failure/error types
│   ├── network/         # DioClient, interceptors
│   ├── providers/       # Core providers (DI)
│   ├── router/          # GoRouter config
│   ├── services/        # Logger, crypto, encryption
│   ├── theme/           # AppTheme, colors, typography
│   └── widgets/         # Shared generic widgets
├── shared/
│   └── widgets/         # EmptyState, ErrorState, LoadingState
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasource/
        │   │   ├── <feature>_remote_datasource.dart
        │   │   └── <feature>_local_datasource.dart
        │   ├── models/
        │   │   └── <feature>_model.dart         # Freezed + JSON
        │   └── repositories/
        │       └── <feature>_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── <feature>.dart               # Freezed, no JSON
        │   ├── repositories/
        │   │   └── <feature>_repository.dart     # Abstract
        │   └── usecases/
        │       └── get_<feature>.dart
        └── presentation/
            ├── controllers/
            │   └── <feature>_controller.dart
            ├── pages/
            │   └── <feature>_page.dart
            ├── providers/
            │   └── <feature>_providers.dart
            └── widgets/
                └── <feature>_widget.dart
```

### Rule: Setiap feature WAJIB punya minimal `data/` + `domain/` + `presentation/`

Kalau feature baru ditambah, buat 3 layer ini. Jangan cuma `presentation/pages/` saja.

---

## 2. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case.dart` | `auth_remote_datasource.dart` |
| Classes | `PascalCase` | `AuthRemoteDatasource`, `DioClient` |
| Variables/functions | `camelCase` | `apiBaseUrl`, `getWalletBalance()` |
| Private | `_camelCase` | `_selectedMethod`, `_isScanning` |
| Constants | `lowerCamelCase` | `networkTimeout`, `maxRetries` |
| Providers | `camelCase` + `Provider` | `dioProvider`, `authControllerProvider` |
| Routes path | `kebab-case` | `/register-step-1`, `/send-money` |
| Routes name | `camelCase` | `registerStep1`, `sendMoney` |
| DB tables | `snake_case` | `wallet_balances`, `global_ledger` |
| DB columns | `snake_case` | `amount_cent`, `hop_count` |
| API paths | `kebab-case` | `/auth/check-availability`, `/wallet/balance` |

---

## 3. File Naming Rules

```dart
// Model: entity + _model.dart
wallet_item_model.dart          // class WalletItemModel
wallet_item_model.freezed.dart  // generated
wallet_item_model.g.dart        // generated

// Entity: entity name only (no _model suffix)
wallet_item.dart                // class WalletItem

// Repository
wallet_repository.dart          // abstract class WalletRepository
wallet_repository_impl.dart     // class WalletRepositoryImpl

// DataSource
wallet_remote_datasource.dart   // class WalletRemoteDatasource
wallet_local_datasource.dart    // class WalletLocalDatasource

// Controller
wallet_controller.dart          // class WalletController extends _$WalletController

// Provider
wallet_providers.dart           // all provider definitions for wallet

// Page
home_page.dart                  // class HomePage
login_page.dart                 // class LoginPage

// Widget
wallet_list_item.dart           // class WalletListItem
```

---

## 4. Import Rules

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

// 4. Project: core (relative dari lib/)
import '../core/network/dio_client.dart';
import '../core/errors/failure.dart';

// 5. Project: features (relative dari lib/)
import '../features/wallet/domain/entities/wallet_item.dart';

// 6. Generated
import 'app_database.g.dart';
```

### Rule: JANGAN pernah pakai `package:nirpay/...` — selalu pakai relative import

---

## 5. Error Handling

### 5.1 Gunakan Sealed Class (bukan Exception hierarchy)

```dart
// BENAR ✅
sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  final String message;
  final int? statusCode;
  const NetworkFailure({required this.message, this.statusCode});
}

class CacheFailure extends Failure {
  final String message;
  const CacheFailure({required this.message});
}

class ServerFailure extends Failure {
  final String message;
  final String? code;
  const ServerFailure({required this.message, this.code});
}

// SALAH ❌
class CustomException implements Exception { ... }
```

### 5.2 Return `Either<Failure, T>` dari Repository

```dart
// BENAR ✅
abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginParams params);
}

// Impl
@override
Future<Either<Failure, User>> login(LoginParams params) async {
  try {
    final response = await _remoteDatasource.login(params);
    return Right(response.toEntity());
  } on DioException catch (e) {
    return Left(ServerFailure(
      message: e.message ?? 'Server error',
      statusCode: e.response?.statusCode,
    ));
  } catch (e) {
    return Left(CacheFailure(message: e.toString()));
  }
}
```

### 5.3 Controller: Pakai `AsyncValue.guard()`

```dart
// BENAR ✅
Future<void> login() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final result = await _authRepository.login(params);
    return result.fold(
      (failure) => throw failure,
      (user) => user,
    );
  });
}
```

### 5.4 Page: Handle `AsyncValue.when()`

```dart
// BENAR ✅
controller.when(
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => ErrorState(
    message: err.toString(),
    onRetry: () => controller.retry(),
  ),
  data: (user) => Text('Welcome ${user.name}'),
)

// JANGAN ❌
controller.whenOrNull(
  data: (user) => Text('Welcome ${user.name}'),
)
```

### 5.5 User-facing errors: pakai SnackBar

```dart
// BENAR ✅
if (context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(failure.message)),
  );
}

// JANGAN ❌
print('Error: $e');
```

---

## 6. State Management (Riverpod)

### 6.1 Gunakan `@riverpod` code generation untuk provider baru

```dart
// BENAR ✅ — generated provider
@riverpod
Future<AuthRemoteDatasource> authRemoteDatasource(
  AuthRemoteDatasourceRef ref,
) async {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDatasource(dio);
}

// BENAR ✅ — manual provider (simple case)
final dioProvider = Provider<Dio>((ref) => DioClient.create());

// JANGAN ❌
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(dioProvider));
});
```

### 6.2 State Management per Feature

```dart
// 1. Entity (Domain layer)
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
  }) = _User;
}

// 2. Model (Data layer) — extends Entity
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String username,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(id: id, email: email, username: username);
}

// 3. Repository Interface (Domain layer)
abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginParams params);
}

// 4. Repository Impl (Data layer)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  // ...
}

// 5. Controller (Presentation layer)
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() async {}

  Future<void> login(LoginParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authRepositoryProvider).login(params);
      return result.fold((l) => throw l, (r) => r);
    });
  }
}

// 6. Provider wiring (providers file)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});
```

### 6.3 State Pattern

```dart
// Untuk list data → AsyncNotifier<List<T>>
// Untuk single item → AsyncNotifier<T>
// Untuk form state → StateNotifier<FormState>
// Untuk simple flag → StateProvider<bool>
```

---

## 7. Database (Drift ORM)

### 7.1 Table Definition

```dart
// BENAR ✅
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get txId => text().named('tx_id')();
  TextColumn get direction => text().withLength(min: 1, max: 7)();
  TextColumn get txType => text().named('tx_type')();
  IntColumn get amountCent => integer().named('amount_cent')();
  IntColumn get hopCount => integer().named('hop_count').withDefault(const Constant(0))();
  TextColumn get syncStatus => text().named('sync_status').withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
}

// SALAH ❌ — tidak pakai named()
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tx_id => text()();  // ❌ harus named()
  TextColumn get txType => text()(); // ❌ tidak konsisten
}
```

### 7.2 Migration Strategy

```dart
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    // Selalu handle migration dari versi sebelumnya
    // Jangan hapus kolom lama — tambah kolom baru saja
  },
  beforeOpen: (details) async {
    // Enable WAL mode untuk performance
    await customStatement('PRAGMA journal_mode=WAL');
    await customStatement('PRAGMA foreign_keys=ON');
  },
);
```

### 7.3 Naming DB Tables & Columns

```
Tables:   snake_case, plural    → users, wallet_balances, transactions
Columns:  snake_case            → amount_cent, hop_count, sync_status
```

---

## 8. Network (Dio + API)

### 8.1 API Response Format

```dart
// BENAR ✅ — wrapper response
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
  }) = _ApiResponse;
}

// Usage
final response = await dio.get('/wallet/balance');
final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
  response.data,
  (json) => json as Map<String, dynamic>,
);
```

### 8.2 Interceptor Pattern

```dart
// AuthInterceptor: attach token
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Baca token dari secure storage
    final token = tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// TokenInterceptor: handle 401 + refresh
class TokenInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Refresh token logic
      final newToken = await refreshToken();
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }
}
```

### 8.3 Timeout

```dart
// Default timeout: 30 detik
const networkTimeout = Duration(seconds: 30);

// Upload timeout: 120 detik
const uploadTimeout = Duration(seconds: 120);
```

---

## 9. Routing (GoRouter)

### 9.1 Route Definition

```dart
// BENAR ✅
class AppRoutePaths {
  static const login = '/login';
  static const home = '/home';
  static const registerStep1 = '/register-step-1';
  static const sendMoney = '/send-money';
}

class AppRouteNames {
  static const login = 'login';
  static const home = 'home';
  static const registerStep1 = 'registerStep1';
  static const sendMoney = 'sendMoney';
}

// Route list
GoRoute(
  path: AppRoutePaths.registerStep1,
  name: AppRouteNames.registerStep1,
  builder: (context, state) => const RegisterStep1Page(),
),
```

### 9.2 Navigation

```dart
// BENAR ✅
context.pushNamed(AppRouteNames.sendMoney);
context.goNamed(AppRouteNames.home);  // replace stack
context.pop();  // go back

// JANGAN ❌
Navigator.of(context).maybePop();  // pakai go_router
context.go('/send-money');         // pakai named route
```

---

## 10. Theme & Colors

### 10.1 Define colors di satu tempat

```dart
// BENAR ✅ — app_colors.dart
abstract class AppColors {
  static const primary = Color(0xFF009CFF);
  static const success = Color(0xFF26644A);
  static const error = Color(0xFFD63C42);
  static const warning = Color(0xFFFF9500);
  static const background = Color(0xFFF4F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1E1E24);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE2E6EE);
}

// SALAH ❌ — hardcoded langsung di widget
Container(
  color: Color(0xFF009CFF),  // ❌ hardcode
)
```

### 10.2 Gradient Pattern

```dart
// BENAR ✅ — centralized gradient
abstract class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F7FB), Colors.white, Color(0xFFC7F4ED)],
  );
}
```

---

## 11. Debugging Rules

### 11.1 Logger

```dart
// Gunakan logger provider, BUKAN print/debugPrint
final logger = Logger(printer: PrettyPrinter(methodCount: 0));

// Usage
logger.d('API Response: ${response.data}');
logger.e('Login failed', error: e, stackTrace: stackTrace);

// JANGAN ❌
print('Debug: $value');
debugPrint('Error: $e');
```

### 11.2 Naming Log Messages

```dart
// Format: [FeatureName] message
logger.d('[Auth] Sending login request');
logger.d('[Auth] Login successful: ${user.id}');
logger.e('[Auth] Login failed: ${failure.message}');
logger.d('[Wallet] Syncing balance');
logger.d('[NFC] APDU response: ${response.map((b) => b.toRadixString(16)).join(' ')}');
```

---

## 12. Build & Code Generation

```bash
# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
dart run build_runner watch --delete-conflicting-outputs

# Lint
flutter analyze

# Format
dart format .
```

---

## 13. Anti-Patterns (JANGAN LAKUKAN)

| # | Anti-Pattern | Yang Benar |
|---|-------------|-----------|
| 1 | Hardcode color hex di widget | Pakai `AppColors.primary` |
| 2 | `print()` / `debugPrint()` | Pakai `Logger` provider |
| 3 | State management di page langsung | Pakai controller + provider |
| 4 | Business logic di UI widget | Pakai use case / controller |
| 5 | `Navigator.of(context).maybePop()` | Pakai `context.pop()` |
| 6 | Import pakai `package:nirpay/...` | Relative import `../` |
| 7 | Catch semua error tanpa logging | Selalu `logger.e()` |
| 8 | Dummy data di production code | Dummy hanya di `test/` atau `assets/` |
| 9 | Model tanpa Freezed | Selalu pakai `@freezed` |
| 10 | `setState` untuk server state | Pakai Riverpod provider |
| 11 | `async` tanpa `mounted` check | Selalu `if (context.mounted)` |
| 12 | `String` untuk enum values | Pakai enum atau sealed class |
| 13 | Feature tanpa data/domain layer | Selalu buat 3 layer |
| 14 | `Provider` untuk state yang berubah | Pakai `StateProvider` / `Notifier` |
| 15 | Hardcode URL/endpoint | Pakai `AppConfig` |

---

## 14. Checklist Sebelum Commit

```
□ Semua import pakai relative path
□ Tidak ada print()/debugPrint() — pakai Logger
□ Tidak ada hardcoded color — pakai AppColors
□ Semua model pakai Freezed + JSON serialization
□ Error handling pakai sealed class + Either
□ Async operations ada mounted check
□ Widget test pass
□ dart analyze tanpa error
□ Code format sesuai dart format
```

# AGENTS.md — Backend (Laravel) Coding Conventions
> **Single source of truth** untuk semua coding style di `backend-laravel/`.
> Wajib diikuti oleh semua agent/programmer yang kerja di folder ini.

---

## 1. Architecture: Modular + Service Layer

```
backend-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── Auth/
│   │   │   │   │   ├── RegisterController.php
│   │   │   │   │   ├── LoginController.php
│   │   │   │   │   ├── OtpController.php
│   │   │   │   │   └── PinController.php
│   │   │   │   ├── Wallet/
│   │   │   │   │   └── WalletController.php
│   │   │   │   └── Admin/
│   │   │   │       ├── UserController.php
│   │   │   │       ├── StatsController.php
│   │   │   │       └── KycController.php
│   │   ├── Middleware/
│   │   │   ├── JwtMiddleware.php
│   │   │   ├── RoleMiddleware.php
│   │   │   └── EnsureRequestHasContent.php
│   │   └── Requests/
│   │       ├── Auth/
│   │       │   ├── RegisterRequest.php
│   │       │   ├── LoginRequest.php
│   │       │   ├── SendOtpRequest.php
│   │       │   ├── VerifyOtpRequest.php
│   │       │   └── VerifyPinRequest.php
│   │       └── Admin/
│   │           └── RejectKycRequest.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Admin.php
│   │   ├── WalletBalance.php
│   │   ├── DeviceSession.php
│   │   ├── OtpVerification.php
│   │   └── AuditLog.php
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── AuthService.php
│   │   │   ├── OtpService.php
│   │   │   └── TokenService.php
│   │   ├── Wallet/
│   │   │   └── WalletService.php
│   │   └── Admin/
│   │       ├── AdminService.php
│   │       └── KycService.php
│   └── Exceptions/
│       └── Handler.php
├── config/
│   └── jwt.php
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   └── api.php
└── .env
```

### Rule: 
- Controllers WAJIB di `app/Http/Controllers/Api/`
- Request Validation WAJIB di `app/Http/Requests/`
- Service Layer WAJIB di `app/Services/`
- Models WAJIB di `app/Models/`

---

## 2. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `PascalCase` | `AuthController.php`, `RegisterRequest.php` |
| Classes | `PascalCase` | `AuthService`, `RegisterRequest` |
| Methods | `camelCase` | `register()`, `verifyOtp()` |
| Variables | `camelCase` | `$accessToken`, `$refreshToken` |
| Requests | `PascalCase` + `Request` | `RegisterRequest`, `LoginRequest` |
| Services | `PascalCase` + `Service` | `AuthService`, `OtpService` |
| Controllers | `PascalCase` + `Controller` | `AuthController` |
| Models | `PascalCase` (singular) | `User`, `WalletBalance` |
| Middleware | `PascalCase` + `Middleware` | `JwtMiddleware`, `RoleMiddleware` |
| DB tables | `snake_case` plural | `users`, `wallet_balances` |
| DB columns | `snake_case` | `amount_cent`, `hop_count` |
| API paths | `kebab-case` | `/auth/check-availability`, `/wallet/balance` |
| Env vars | `UPPER_SNAKE_CASE` | `DB_HOST`, `JWT_SECRET` |

---

## 3. Controller Pattern

### 3.1 Controller Structure

```php
// BENAR ✅
class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $this->authService->register($request->validated());
        return ApiResponse::success($data, 'Registration successful', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $data = $this->authService->login($request->validated());
        return ApiResponse::success($data, 'Login successful');
    }
}

// SALAH ❌ — logic di controller
class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        // ❌ logic registration di controller
        $hashedPassword = Hash::make($request->pin);
        $user = User::create([...]);
        return response()->json($user);
    }
}
```

### 3.2 Route Definition

```php
// routes/api.php
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/check-availability', [AuthController::class, 'checkAvailability']);
    Route::get('/check-username/{username}', [AuthController::class, 'checkUsername']);
    Route::post('/send-otp', [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
});

// Protected routes
Route::middleware(['auth:api'])->group(function () {
    Route::post('/auth/verify-pin', [PinController::class, 'verifyPin']);
    
    Route::prefix('wallet')->group(function () {
        Route::get('/balance', [WalletController::class, 'balance']);
        Route::get('/resolve/{username}', [WalletController::class, 'resolve']);
    });
});

// Admin routes
Route::middleware(['auth:api', 'role:ADMIN,SUPER_ADMIN'])->prefix('admin')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/stats', [StatsController::class, 'index']);
    Route::get('/kyc', [KycController::class, 'index']);
    Route::get('/kyc/{id}', [KycController::class, 'show']);
    Route::post('/kyc/{id}/approve', [KycController::class, 'approve']);
    Route::post('/kyc/{id}/reject', [KycController::class, 'reject']);
});
```

---

## 4. Service Layer Pattern

### 4.1 Service Structure

```php
// BENAR ✅
class AuthService
{
    public function __construct(
        private readonly TokenService $tokenService,
        private readonly OtpService $otpService
    ) {}

    public function register(array $data): array
    {
        // 1. Check availability
        $this->checkAvailability($data['email'], $data['phone']);

        // 2. Create user with transaction
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'email' => $data['email'],
                'phone' => $data['phone'],
                'username' => $data['username'],
                'full_name' => $data['fullName'],
                'password_hash' => Hash::make($data['password']),
                'pin_hash' => Hash::make($data['pin']),
                'public_key_b64' => $data['publicKeyB64'] ?? null,
                'nik' => $data['nik'] ?? null,
                // ... other fields
            ]);

            // 3. Create wallet
            WalletBalance::create([
                'user_id' => $user->id,
                'amount_cent' => 0,
            ]);

            // 4. Generate tokens
            $tokens = $this->tokenService->generateTokens($user);

            return [
                'userId' => $user->id,
                'accessToken' => $tokens['accessToken'],
                'refreshToken' => $tokens['refreshToken'],
            ];
        });
    }
}

// JANGAN ❌
class AuthService
{
    public function register(Request $request)
    {
        return User::create($request->all()); // ❌ no validation, no logging
    }
}
```

---

## 5. Request Validation (Form Request)

### 5.1 Always use Form Request

```php
// BENAR ✅
class RegisterRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users,email'],
            'phone' => ['required', 'string', 'regex:/^(\+62|62|0)8[1-9][0-9]{6,9}$/', 'unique:users,phone_number'],
            'fullName' => ['required', 'string', 'min:2', 'max:100'],
            'username' => ['required', 'string', 'min:3', 'max:20', 'regex:/^[a-zA-Z0-9_]+$/', 'unique:users,username'],
            'password' => ['required', 'string', 'min:8'],
            'pin' => ['required', 'string', 'size:6', 'regex:/^[0-9]+$/'],
            'publicKeyB64' => ['required', 'string'],
            'nik' => ['required', 'string', 'size:16', 'regex:/^[0-9]+$/'],
            'province' => ['nullable', 'string'],
            'city' => ['nullable', 'string'],
            'district' => ['nullable', 'string'],
            'village' => ['nullable', 'string'],
            'postalCode' => ['nullable', 'string'],
            'rt' => ['nullable', 'string'],
            'rw' => ['nullable', 'string'],
            'ktpPhotoUrl' => ['nullable', 'string'],
            'kycFaceUrl' => ['nullable', 'string'],
            'gender' => ['nullable', 'in:MALE,FEMALE'],
            'birthDate' => ['nullable', 'date'],
        ];
    }
}

// SALAH ❌
class AuthController extends Controller
{
    public function register(Request $request)
    {
        // ❌ manual validation di controller
        $request->validate([
            'email' => 'required|email',
        ]);
    }
}
```

---

## 6. API Response Wrapper

```php
// app/Helpers/ApiResponse.php
class ApiResponse
{
    public static function success(mixed $data = null, string $message = 'Success', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    public static function error(string $message, int $code = 400, ?string $errorCode = null): JsonResponse
    {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errorCode) {
            $response['error'] = ['code' => $errorCode];
        }

        return response()->json($response, $code);
    }
}
```

---

## 7. Error Handling

### 7.1 HTTP Error Codes

```php
// Map error types to HTTP codes
return ApiResponse::error('Invalid PIN format', 400);           // 400 Bad Request
return ApiResponse::error('Invalid credentials', 401);          // 401 Unauthorized
return ApiResponse::error('Admin access required', 403);        // 403 Forbidden
return ApiResponse::error('User not found', 404);               // 404 Not Found
return ApiResponse::error('Email already registered', 409);     // 409 Conflict
```

### 7.2 Exception Handler

```php
// app/Exceptions/Handler.php
public function register(): void
{
    $this->renderable(function (AuthenticationException $e) {
        return ApiResponse::error('Unauthorized', 401);
    });

    $this->renderable(function (ValidationException $e) {
        return ApiResponse::error($e->getMessage(), 400, 'VALIDATION_ERROR');
    });

    $this->renderable(function (ModelNotFoundException $e) {
        return ApiResponse::error('Resource not found', 404);
    });
}
```

### 7.3 Logging

```php
// BENAR ✅ — use Laravel Log facade
use Illuminate\Support\Facades\Log;

Log::info('[Auth] Registering user: ' . $email);
Log::warning('[Auth] Rate limit exceeded for: ' . $email);
Log::error('[Auth] Login failed', ['exception' => $e]);

// JANGAN ❌
echo 'User registered';  // ❌
var_dump($data);         // ❌
```

---

## 8. Authentication (JWT)

### 8.1 JWT Middleware

```php
// app/Http/Middleware/JwtMiddleware.php
class JwtMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
        } catch (Exception $e) {
            return ApiResponse::error('Unauthorized', 401);
        }

        $request->auth = $user;
        return $next($request);
    }
}
```

### 8.2 Role Middleware

```php
// app/Http/Middleware/RoleMiddleware.php
class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles)
    {
        $user = $request->auth;

        if (!in_array($user->role, $roles)) {
            return ApiResponse::error('Admin access required', 403);
        }

        return $next($request);
    }
}
```

### 8.3 Token Generation

```php
// app/Services/Auth/TokenService.php
class TokenService
{
    public function generateTokens(User $user): array
    {
        $customClaims = [
            'sub' => $user->id,
            'email' => $user->email,
            'role' => $user->role ?? 'USER',
        ];

        $accessToken = JWTAuth::customClaims($customClaims)->fromUser($user);
        
        // Refresh token with longer TTL
        $refreshToken = JWTAuth::customClaims(array_merge($customClaims, [
            'type' => 'refresh',
        ]))->setTTL(config('jwt.refresh_ttl'))->fromUser($user);

        return [
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
        ];
    }
}
```

---

## 9. Eloquent Model

### 9.1 Model Rules

```php
// BENAR ✅
class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $table = 'users';
    
    protected $fillable = [
        'email',
        'phone_number',
        'username',
        'full_name',
        'password_hash',
        'pin_hash',
        'public_key_b64',
        'kyc_status',
        'nik',
        'province',
        'city',
        'district',
        'village',
        'postal_code',
        'rt',
        'rw',
        'ktp_photo_url',
        'kyc_face_url',
        'gender',
        'birth_date',
        'is_active',
        'is_locked',
    ];

    protected $hidden = [
        'password_hash',
        'pin_hash',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'is_active' => 'boolean',
        'is_locked' => 'boolean',
        'is_kyc_done' => 'boolean',
        'last_login_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // JWT Subject
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    // Relationships
    public function wallet()
    {
        return $this->hasOne(WalletBalance::class);
    }

    public function sessions()
    {
        return $this->hasMany(DeviceSession::class);
    }
}

// JANGAN ❌
class User extends Model
{
    protected $fillable = ['*']; // ❌ mass assignment vulnerability
}
```

---

## 10. Database Migration

### 10.1 Migration Rules

```php
// BENAR ✅ — use snake_case, descriptive names
Schema::create('users', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('email')->unique();
    $table->string('phone_number')->unique()->nullable();
    $table->string('username')->unique()->nullable();
    $table->string('full_name');
    $table->string('password_hash');
    $table->string('pin_hash');
    $table->text('public_key_b64')->nullable();
    $table->string('kyc_status')->default('UNVERIFIED');
    $table->boolean('is_kyc_done')->default(false);
    $table->boolean('is_active')->default(true);
    $table->boolean('is_locked')->default(false);
    $table->timestamps();
});

// JANGAN ❌
Schema::create('Users', function (Blueprint $table) { // ❌ PascalCase
    $table->id();
    $table->string('email');
    $table->string('pin_hash'); // ❌ no unique constraint
});
```

---

## 11. Anti-Patterns (JANGAN LAKUKAN)

| # | Anti-Pattern | Yang Benar |
|---|-------------|-----------|
| 1 | Logic di controller | Logic di service, controller handle HTTP only |
| 2 | `Request $request` tanpa Form Request | Buat Form Request untuk setiap endpoint |
| 3 | No validation di Request | Selalu pakai rules() di Form Request |
| 4 | `echo` / `var_dump` | Pakai `Log::info()` |
| 5 | Raw SQL queries | Pakai Eloquent ORM |
| 6 | `response()->json()` langsung | Pakai `ApiResponse::success()` / `ApiResponse::error()` |
| 7 | Hardcode secrets | Pakai `env()` + `.env` |
| 8 | No error handling | Selalu return `ApiResponse::error()` |
| 9 | N+1 queries | Pakai `with()` eager loading |
| 10 | No transaction | `DB::transaction()` untuk multi-step |
| 11 | No logging | Selalu log critical operations |
| 12 | `$request->all()` di create | Pakai `$request->validated()` |
| 13 | Missing middleware | Public endpoints harus explicit `withoutMiddleware()` |
| 14 | No rate limiting | Rate limit di auth endpoints |

---

## 12. Checklist Sebelum Commit

```
□ Semua Request pakai Form Request dengan rules()
□ Tidak ada echo/var_dump — pakai Log facade
□ Semua service methods return array/object untuk ApiResponse
□ Error handling pakai ApiResponse::error()
□ Eloquent queries pakai transaction untuk multi-step
□ Logging untuk semua critical operations
□ .env.example updated (jangan commit .env)
□ Unit test pass
□ php artisan lint tanpa error (jika ada)
□ php artisan test tanpa error
```

---

## 13. Quick Reference Commands

```bash
# Buat Controller
php artisan make:controller Api/Auth/AuthController

# Buat Model
php artisan make:model User -m

# Buat Request
php artisan make:request Auth/RegisterRequest

# Buat Migration
php artisan make:migration create_users_table

# Buat Seeder
php artisan make:seeder UserSeeder

# Run Migration
php artisan migrate

# Run Seeder
php artisan db:seed

# Run Test
php artisan test

# Clear Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

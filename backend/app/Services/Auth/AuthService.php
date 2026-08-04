<?php

namespace App\Services\Auth;

use App\Models\User;
use App\Models\WalletBalance;
use App\Models\DeviceSession;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AuthService
{
    public function __construct(
        private readonly TokenService $tokenService,
        private readonly OtpService $otpService
    ) {}

    public function register(array $data): array
    {
        Log::info("[Auth] Registering user: {$data['email']}");

        // Check availability
        $this->checkAvailability($data['email'], $data['phone'] ?? null, $data['username'] ?? null);

        // Create user with transaction
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'email' => $data['email'],
                'phone_number' => $data['phone'] ?? null,
                'username' => $data['username'] ?? null,
                'full_name' => $data['fullName'],
                'password_hash' => Hash::make($data['password']),
                'pin_hash' => Hash::make($data['pin']),
                'public_key_b64' => $data['publicKeyB64'] ?? null,
                'nik' => $data['nik'] ?? null,
                'province' => $data['province'] ?? null,
                'city' => $data['city'] ?? null,
                'district' => $data['district'] ?? null,
                'village' => $data['village'] ?? null,
                'postal_code' => $data['postalCode'] ?? null,
                'rt' => $data['rt'] ?? null,
                'rw' => $data['rw'] ?? null,
                'ktp_photo_url' => $data['ktpPhotoUrl'] ?? null,
                'kyc_face_url' => $data['kycFaceUrl'] ?? null,
                'gender' => $data['gender'] ?? null,
                'birth_date' => isset($data['birthDate']) ? $data['birthDate'] : null,
            ]);

            // Create wallet
            WalletBalance::create([
                'user_id' => $user->id,
                'amount_cent' => 0,
                'reserved_cent' => 0,
                'currency' => 'IDR',
            ]);

            // Generate tokens
            $tokens = $this->tokenService->generateTokens($user);

            Log::info("[Auth] User registered successfully: {$user->id}");

            return [
                'userId' => $user->id,
                'accessToken' => $tokens['accessToken'],
                'refreshToken' => $tokens['refreshToken'],
            ];
        });
    }

    public function login(array $data): array
    {
        Log::info("[Auth] Login attempt: {$data['email']}");

        $user = User::where('email', $data['email'])->first();

        if (!$user) {
            Log::warning("[Auth] User not found: {$data['email']}");
            throw new \Exception('Invalid credentials');
        }

        if (!$user->is_active) {
            Log::warning("[Auth] Account inactive: {$data['email']}");
            throw new \Exception('Account is inactive');
        }

        if ($user->is_locked) {
            Log::warning("[Auth] Account locked: {$data['email']}");
            throw new \Exception('Account is locked');
        }

        // Verify password
        if (!Hash::check($data['password'], $user->password_hash)) {
            // Increment failed login count
            $user->increment('failed_login_count');

            // Lock account after 5 failed attempts
            if ($user->failed_login_count >= 5) {
                $user->update([
                    'is_locked' => true,
                    'locked_reason' => 'Too many failed login attempts',
                ]);
            }

            Log::warning("[Auth] Invalid password: {$data['email']}");
            throw new \Exception('Invalid credentials');
        }

        // Check KYC status
        if ($user->kyc_status === 'PENDING') {
            Log::warning("[Auth] KYC pending: {$data['email']}");
            throw new \Exception('KYC_PENDING');
        }

        // Reset failed login count on success
        $user->update([
            'failed_login_count' => 0,
            'last_login_at' => now(),
            'last_login_ip' => request()->ip(),
        ]);

        // Generate tokens
        $tokens = $this->tokenService->generateTokens($user);

        Log::info("[Auth] Login successful: {$user->id}");

        return [
            'accessToken' => $tokens['accessToken'],
            'refreshToken' => $tokens['refreshToken'],
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'fullName' => $user->full_name,
                'username' => $user->username,
                'role' => 'USER',
                'kycStatus' => $user->kyc_status,
                'pinHash' => $user->pin_hash,
            ],
        ];
    }

    public function checkAvailability(string $email, ?string $phone, ?string $username = null): array
    {
        $emailAvailable = !User::where('email', $email)->exists();
        $phoneAvailable = $phone ? !User::where('phone_number', $phone)->exists() : true;
        $usernameAvailable = $username ? !User::where('username', $username)->exists() : true;

        return [
            'emailAvailable' => $emailAvailable,
            'phoneAvailable' => $phoneAvailable,
            'usernameAvailable' => $usernameAvailable,
        ];
    }

    public function checkUsername(string $username): array
    {
        $available = !User::where('username', $username)->exists();

        return [
            'available' => $available,
        ];
    }

    public function verifyPin(User $user, string $pin): array
    {
        Log::info("[Auth] Verifying PIN for user: {$user->id}");

        if (!Hash::check($pin, $user->pin_hash)) {
            Log::warning("[Auth] Invalid PIN for user: {$user->id}");
            throw new \Exception('Invalid PIN');
        }

        // Generate new tokens
        $tokens = $this->tokenService->generateTokens($user);

        Log::info("[Auth] PIN verified successfully: {$user->id}");

        return [
            'accessToken' => $tokens['accessToken'],
            'refreshToken' => $tokens['refreshToken'],
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'fullName' => $user->full_name,
                'username' => $user->username,
                'role' => 'USER',
            ],
        ];
    }

    public function adminLogin(array $data): array
    {
        Log::info("[Auth] Admin login attempt: {$data['email']}");

        $admin = \App\Models\Admin::where('email', $data['email'])->first();

        if (!$admin) {
            Log::warning("[Auth] Admin not found: {$data['email']}");
            throw new \Exception('Invalid credentials');
        }

        if (!$admin->is_active) {
            Log::warning("[Auth] Admin account inactive: {$data['email']}");
            throw new \Exception('Account is inactive');
        }

        if (!Hash::check($data['password'], $admin->password_hash)) {
            Log::warning("[Auth] Invalid admin password: {$data['email']}");
            throw new \Exception('Invalid credentials');
        }

        // Update last login
        $admin->update([
            'last_login_at' => now(),
            'last_login_ip' => request()->ip(),
        ]);

        // Generate tokens
        $tokens = $this->tokenService->generateAdminTokens($admin);

        Log::info("[Auth] Admin login successful: {$admin->id}");

        return [
            'accessToken' => $tokens['accessToken'],
            'refreshToken' => $tokens['refreshToken'],
            'user' => [
                'id' => $admin->id,
                'email' => $admin->email,
                'fullName' => $admin->name,
                'role' => $admin->role,
            ],
        ];
    }
}

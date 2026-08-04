<?php

namespace App\Services\Auth;

use App\Models\User;
use App\Models\Admin;
use App\Models\DeviceSession;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class TokenService
{
    public function generateTokens(User $user, ?string $ipAddress = null): array
    {
        return DB::transaction(function () use ($user, $ipAddress) {
            $customClaims = [
                'sub' => $user->id,
                'email' => $user->email,
                'role' => 'USER',
            ];

            $accessToken = JWTAuth::customClaims($customClaims)->fromUser($user);
            
            JWTAuth::factory()->setTTL(config('jwt.refresh_ttl'));
            $refreshToken = JWTAuth::customClaims(array_merge($customClaims, [
                'type' => 'refresh',
            ]))->fromUser($user);

            // Save session
            DeviceSession::create([
                'user_id' => $user->id,
                'device_id' => request()->header('User-Agent'),
                'device_name' => request()->header('Device-Name'),
                'ip_address' => $ipAddress ?? request()->ip(),
                'auth_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'expires_at' => now()->addMinutes((int) config('jwt.refresh_ttl')),
            ]);

            Log::info("[Token] Generated tokens for user: {$user->id}");

            return [
                'accessToken' => $accessToken,
                'refreshToken' => $refreshToken,
            ];
        });
    }

    public function generateAdminTokens(Admin $admin, ?string $ipAddress = null): array
    {
        $customClaims = [
            'sub' => $admin->id,
            'email' => $admin->email,
            'role' => $admin->role,
            'type' => 'admin',
        ];

        JWTAuth::factory()->setTTL(config('jwt.ttl'));
        $accessToken = JWTAuth::customClaims($customClaims)->fromUser($admin);
        
        JWTAuth::factory()->setTTL(config('jwt.refresh_ttl'));
        $refreshToken = JWTAuth::customClaims(array_merge($customClaims, [
            'type' => 'admin_refresh',
        ]))->fromUser($admin);

        Log::info("[Token] Generated admin tokens for: {$admin->id}");

        return [
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
        ];
    }

    public function refreshToken(string $refreshToken): array
    {
        try {
            $payload = JWTAuth::setToken($refreshToken)->getPayload();
            $user = User::find($payload->get('sub'));

            if (!$user) {
                throw new \Exception('User not found');
            }

            return $this->generateTokens($user);
        } catch (\Exception $e) {
            Log::error("[Token] Refresh failed: {$e->getMessage()}");
            throw $e;
        }
    }
}

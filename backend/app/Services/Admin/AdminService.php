<?php

namespace App\Services\Admin;

use App\Models\User;
use App\Models\WalletBalance;
use Illuminate\Support\Facades\Log;

class AdminService
{
    public function getUsers(int $page = 1, int $limit = 10): array
    {
        $query = User::select([
            'id',
            'email',
            'username',
            'full_name',
            'kyc_status',
            'is_active',
            'created_at',
        ]);

        $total = $query->count();
        $users = $query
            ->skip(($page - 1) * $limit)
            ->take($limit)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($user) {
                return [
                    'id' => $user->id,
                    'email' => $user->email,
                    'username' => $user->username,
                    'fullName' => $user->full_name,
                    'role' => 'USER',
                    'kycStatus' => $user->kyc_status,
                    'isActive' => $user->is_active,
                    'createdAt' => $user->created_at->toISOString(),
                ];
            });

        return [
            'users' => $users,
            'meta' => [
                'total' => $total,
                'page' => $page,
                'limit' => $limit,
                'totalPages' => ceil($total / $limit),
            ],
        ];
    }

    public function getUserDetail(string $id): ?array
    {
        $user = User::with(['wallet', 'sessions'])->find($id);

        if (!$user) {
            return null;
        }

        return [
            'id' => $user->id,
            'email' => $user->email,
            'username' => $user->username,
            'fullName' => $user->full_name,
            'phoneNumber' => $user->phone_number,
            'kycStatus' => $user->kyc_status,
            'isActive' => $user->is_active,
            'isLocked' => $user->is_locked,
            'lockedReason' => $user->locked_reason,
            'lastLoginAt' => $user->last_login_at?->toISOString(),
            'createdAt' => $user->created_at->toISOString(),
            'province' => $user->province,
            'city' => $user->city,
            'district' => $user->district,
            'village' => $user->village,
            'nik' => $user->nik,
            'gender' => $user->gender,
            'ktpPhotoUrl' => $user->ktp_photo_url,
            'kycFaceUrl' => $user->kyc_face_url,
            'wallet' => $user->wallet ? [
                'amountCent' => $user->wallet->amount_cent,
                'reservedCent' => $user->wallet->reserved_cent,
                'currency' => $user->wallet->currency,
                'totalMinted' => $user->wallet->total_minted,
                'totalSent' => $user->wallet->total_sent,
                'totalReceived' => $user->wallet->total_received,
            ] : null,
            'sessions' => $user->sessions->map(fn($s) => [
                'id' => $s->id,
                'deviceName' => $s->device_name,
                'deviceId' => $s->device_id,
                'ipAddress' => $s->ip_address,
                'lastActiveAt' => $s->last_active_at?->toISOString(),
                'expiresAt' => $s->expires_at->toISOString(),
                'createdAt' => $s->created_at->toISOString(),
            ]),
            'totalTransactions' => 0,
            'riskScore' => 0,
        ];
    }

    public function getStats(): array
    {
        $totalUsers = User::count();
        $totalTransactions = 0; // Will be implemented with transactions table
        $totalVolume = 0; // Will be implemented with transactions table

        return [
            'totalUsers' => $totalUsers,
            'totalTransactions' => $totalTransactions,
            'totalVolume' => $totalVolume,
        ];
    }
}

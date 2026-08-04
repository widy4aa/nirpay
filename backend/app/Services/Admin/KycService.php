<?php

namespace App\Services\Admin;

use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class KycService
{
    public function getKycUsers(?string $status = null, int $page = 1, int $limit = 20): array
    {
        $query = User::select([
            'id',
            'email',
            'full_name',
            'username',
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
            'kyc_status',
            'kyc_reject_reason',
            'kyc_reviewed_at',
            'created_at',
        ]);

        if ($status) {
            $query->where('kyc_status', $status);
        }

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
                    'fullName' => $user->full_name,
                    'username' => $user->username,
                    'nik' => $user->nik,
                    'province' => $user->province,
                    'city' => $user->city,
                    'district' => $user->district,
                    'village' => $user->village,
                    'postalCode' => $user->postal_code,
                    'rt' => $user->rt,
                    'rw' => $user->rw,
                    'ktpPhotoUrl' => $user->ktp_photo_url,
                    'kycFaceUrl' => $user->kyc_face_url,
                    'kycStatus' => $user->kyc_status,
                    'kycRejectReason' => $user->kyc_reject_reason,
                    'kycReviewedAt' => $user->kyc_reviewed_at?->toISOString(),
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

    public function getKycDetail(string $userId): array
    {
        $user = User::find($userId);

        if (!$user) {
            Log::warning("[KYC] User not found: {$userId}");
            throw new \Exception('User not found');
        }

        return [
            'id' => $user->id,
            'email' => $user->email,
            'fullName' => $user->full_name,
            'username' => $user->username,
            'nik' => $user->nik,
            'province' => $user->province,
            'city' => $user->city,
            'district' => $user->district,
            'village' => $user->village,
            'postalCode' => $user->postal_code,
            'rt' => $user->rt,
            'rw' => $user->rw,
            'ktpPhotoUrl' => $user->ktp_photo_url,
            'kycFaceUrl' => $user->kyc_face_url,
            'kycStatus' => $user->kyc_status,
            'kycRejectReason' => $user->kyc_reject_reason,
            'kycReviewedAt' => $user->kyc_reviewed_at?->toISOString(),
            'createdAt' => $user->created_at->toISOString(),
        ];
    }

    public function approveKyc(string $userId): array
    {
        Log::info("[KYC] Approving KYC for user: {$userId}");

        return DB::transaction(function () use ($userId) {
            $user = User::find($userId);

            if (!$user) {
                Log::warning("[KYC] User not found: {$userId}");
                throw new \Exception('User not found');
            }

            if ($user->kyc_status === 'APPROVED') {
                Log::warning("[KYC] Already approved: {$userId}");
                throw new \Exception('KYC already approved');
            }

            $user->update([
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
                'kyc_reviewed_at' => now(),
                'kyc_reject_reason' => null,
            ]);

            Log::info("[KYC] KYC approved: {$userId}");

            return $this->getKycDetail($userId);
        });
    }

    public function rejectKyc(string $userId, string $reason): array
    {
        Log::info("[KYC] Rejecting KYC for user: {$userId}");

        return DB::transaction(function () use ($userId, $reason) {
            $user = User::find($userId);

            if (!$user) {
                Log::warning("[KYC] User not found: {$userId}");
                throw new \Exception('User not found');
            }

            if ($user->kyc_status === 'APPROVED') {
                Log::warning("[KYC] Cannot reject approved KYC: {$userId}");
                throw new \Exception('Cannot reject already approved KYC');
            }

            $user->update([
                'kyc_status' => 'REJECTED',
                'is_kyc_done' => false,
                'kyc_reviewed_at' => now(),
                'kyc_reject_reason' => $reason,
            ]);

            Log::info("[KYC] KYC rejected: {$userId}");

            return $this->getKycDetail($userId);
        });
    }
}

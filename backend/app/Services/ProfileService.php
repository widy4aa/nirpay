<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Log;

class ProfileService
{
    // Field yang boleh di-edit oleh user
    private const EDITABLE_FIELDS = [
        'full_name',
        'phone_number',
        'province',
        'city',
        'district',
        'village',
        'postal_code',
        'rt',
        'rw',
    ];

    /**
     * Update profile user.
     * Hanya field yang ada di EDITABLE_FIELDS yang akan di-update.
     */
    public function updateProfile(User $user, array $data): array
    {
        $filtered = [];

        foreach (self::EDITABLE_FIELDS as $field) {
            if (isset($data[$field])) {
                $filtered[$field] = $data[$field];
            }
        }

        // Map camelCase dari client ke snake_case untuk DB
        $camelToSnake = [
            'fullName' => 'full_name',
            'phoneNumber' => 'phone_number',
            'postalCode' => 'postal_code',
        ];

        foreach ($camelToSnake as $camel => $snake) {
            if (isset($data[$camel])) {
                $filtered[$snake] = $data[$camel];
            }
        }

        // Juga support snake_case langsung dari client
        foreach (self::EDITABLE_FIELDS as $field) {
            if (isset($data[$field])) {
                $filtered[$field] = $data[$field];
            }
        }

        if (empty($filtered)) {
            throw new \Exception('No valid fields to update');
        }

        $user->update($filtered);

        Log::info("[Profile] User {$user->id} updated: " . implode(', ', array_keys($filtered)));

        return $this->formatUser($user);
    }

    /**
     * Format user data untuk response.
     */
    public function formatUser(User $user): array
    {
        return [
            'id' => $user->id,
            'email' => $user->email,
            'username' => $user->username,
            'fullName' => $user->full_name,
            'phone' => $user->phone_number,
            'role' => 'USER',
            'kycStatus' => $user->kyc_status,
            'nik' => $user->nik,
            'province' => $user->province,
            'city' => $user->city,
            'district' => $user->district,
            'village' => $user->village,
            'postalCode' => $user->postal_code,
            'rt' => $user->rt,
            'rw' => $user->rw,
            'gender' => $user->gender,
            'publicKeyB64' => $user->public_key_b64,
            'ktpPhotoUrl' => $user->ktp_photo_url,
            'profilePhotoUrl' => $user->profile_photo_url,
            'kycFaceUrl' => $user->kyc_face_url,
        ];
    }
}

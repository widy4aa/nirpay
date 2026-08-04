<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ProfileService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function __construct(
        private readonly ProfileService $profileService
    ) {}

    public function update(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;

            $validated = $request->validate([
                'fullName' => 'sometimes|string|max:255',
                'phone' => 'sometimes|string|max:20',
                'province' => 'sometimes|string|max:100',
                'city' => 'sometimes|string|max:100',
                'district' => 'sometimes|string|max:100',
                'village' => 'sometimes|string|max:100',
                'postalCode' => 'sometimes|string|max:10',
                'rt' => 'sometimes|string|max:10',
                'rw' => 'sometimes|string|max:10',
            ]);

            $data = $this->profileService->updateProfile($user, $validated);
            return ApiResponse::success($data, 'Profile updated');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function changePin(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;

            $validated = $request->validate([
                'oldPin' => 'required|string|min:6|max:8',
                'newPin' => 'required|string|min:6|max:8|confirmed',
            ]);

            // Verifikasi PIN lama
            if (!Hash::check($validated['oldPin'], $user->pin_hash)) {
                return ApiResponse::error('PIN lama salah', 400);
            }

            // Update PIN baru
            $user->update([
                'pin_hash' => Hash::make($validated['newPin']),
            ]);

            \Log::info("[Profile] User {$user->id} changed PIN");

            return ApiResponse::success(null, 'PIN berhasil diubah');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

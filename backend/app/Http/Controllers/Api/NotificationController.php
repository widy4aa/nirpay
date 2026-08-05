<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeviceSession;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Simpan FCM token untuk push notification.
     */
    public function saveFcmToken(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;

            $validated = $request->validate([
                'fcmToken' => 'required|string',
            ]);

            // Update FCM token di device session terbaru
            $session = DeviceSession::where('user_id', $user->id)
                ->where('is_revoked', false)
                ->orderBy('last_active_at', 'desc')
                ->first();

            if ($session) {
                $session->update(['fcm_token' => $validated['fcmToken']]);
            } else {
                // Buat session baru jika belum ada
                DeviceSession::create([
                    'user_id' => $user->id,
                    'device_id' => $request->header('Device-Id', 'unknown'),
                    'device_name' => $request->header('Device-Name', 'Flutter'),
                    'ip_address' => $request->ip(),
                    'auth_token' => '',
                    'fcm_token' => $validated['fcmToken'],
                    'expires_at' => now()->addDays(30),
                ]);
            }

            return ApiResponse::success(null, 'FCM token saved');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

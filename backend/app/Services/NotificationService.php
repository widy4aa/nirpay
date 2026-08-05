<?php

namespace App\Services;

use App\Models\User;
use App\Models\DeviceSession;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Kirim notifikasi ke user via FCM.
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): void
    {
        // Ambil FCM token dari device session terbaru
        $session = DeviceSession::where('user_id', $user->id)
            ->where('is_revoked', false)
            ->orderBy('last_active_at', 'desc')
            ->first();

        if (!$session || empty($session->fcm_token)) {
            Log::warning("[Notification] No FCM token for user {$user->id}");
            return;
        }

        $this->sendFcm($session->fcm_token, $title, $body, $data);
    }

    /**
     * Kirim FCM notification.
     */
    private function sendFcm(string $fcmToken, string $title, string $body, array $data = []): void
    {
        $serverKey = config('services.fcm.server_key');

        if (empty($serverKey)) {
            Log::warning("[Notification] FCM server key not configured");
            return;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'to' => $fcmToken,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                    'sound' => 'default',
                    'badge' => 1,
                ],
                'data' => array_merge($data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
                'priority' => 'high',
            ]);

            if ($response->successful()) {
                Log::info("[Notification] Sent to {$fcmToken}: {$title}");
            } else {
                Log::error("[Notification] FCM error: " . $response->body());
            }
        } catch (\Exception $e) {
            Log::error("[Notification] FCM exception: " . $e->getMessage());
        }
    }
}

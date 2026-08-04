<?php

namespace App\Services\Auth;

use App\Models\OtpVerification;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Mail\OtpMail;

class OtpService
{
    public function generateOtp(string $email, string $channel, string $purpose): array
    {
        // Invalidate any existing OTP for this email/purpose
        OtpVerification::where('email', $email)
            ->where('purpose', $purpose)
            ->where('is_used', false)
            ->update(['is_used' => true]);

        // Generate 6-digit OTP
        $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        
        $otp = OtpVerification::create([
            'id' => Str::uuid(),
            'email' => $email,
            'otp_hash' => bcrypt($otpCode),
            'channel' => $channel,
            'purpose' => $purpose,
            'expires_at' => now()->addMinutes(5),
        ]);

        Log::info("[OTP] Generated OTP for {$email}, purpose: {$purpose}");

        // Send OTP via email
        $this->sendOtpEmail($email, $otpCode, $purpose);

        return [
            'otpId' => $otp->id,
            'expiresIn' => 300, // 5 minutes in seconds
        ];
    }

    public function verifyOtp(string $otpId, string $otpCode): bool
    {
        $otp = OtpVerification::find($otpId);

        if (!$otp) {
            Log::warning("[OTP] OTP not found: {$otpId}");
            throw new \Exception('OTP not found');
        }

        if ($otp->is_used) {
            Log::warning("[OTP] OTP already used: {$otpId}");
            throw new \Exception('OTP already used');
        }

        if ($otp->expires_at->isPast()) {
            Log::warning("[OTP] OTP expired: {$otpId}");
            throw new \Exception('OTP expired');
        }

        if ($otp->attempt_count >= $otp->max_attempts) {
            Log::warning("[OTP] Max attempts reached: {$otpId}");
            throw new \Exception('Maximum OTP attempts reached');
        }

        // Increment attempt count
        $otp->increment('attempt_count');

        if (!password_verify($otpCode, $otp->otp_hash)) {
            Log::warning("[OTP] Invalid OTP code: {$otpId}");
            throw new \Exception('Invalid OTP code');
        }

        // Mark as used
        $otp->update(['is_used' => true]);

        Log::info("[OTP] OTP verified successfully: {$otpId}");

        return true;
    }

    private function sendOtpEmail(string $email, string $otpCode, string $purpose): void
    {
        try {
            // In production, use Mailable class
            // For now, just log it
            Log::info("[OTP] Sending OTP to {$email}: {$otpCode} (purpose: {$purpose})");
            
            // Example with Mail facade:
            Mail::to($email)->send(new OtpMail($otpCode, $purpose));
        } catch (\Exception $e) {
            Log::error("[OTP] Failed to send email: {$e->getMessage()}");
        }
    }
}

<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Services\Auth\OtpService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class OtpController extends Controller
{
    public function __construct(
        private readonly OtpService $otpService
    ) {}

    public function sendOtp(SendOtpRequest $request): JsonResponse
    {
        try {
            $data = $this->otpService->generateOtp(
                $request->email,
                'email',
                $request->type
            );
            return ApiResponse::success($data);
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        try {
            $verified = $this->otpService->verifyOtp($request->otpId, $request->otpCode);
            return ApiResponse::success(['verified' => $verified], 'OTP verified');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

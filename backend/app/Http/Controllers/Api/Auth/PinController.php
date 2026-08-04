<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\VerifyPinRequest;
use App\Services\Auth\AuthService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Tymon\JWTAuth\Facades\JWTAuth;

class PinController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {}

    public function verifyPin(VerifyPinRequest $request): JsonResponse
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
            if (!$user) {
                return ApiResponse::error('User not found', 401);
            }
            $data = $this->authService->verifyPin($user, $request->pin);
            return ApiResponse::success($data, 'PIN verified');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 401);
        }
    }
}

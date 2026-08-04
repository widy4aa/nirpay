<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\AdminLoginRequest;
use App\Services\Auth\AuthService;
use App\Services\Auth\TokenService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class LoginController extends Controller
{
    public function __construct(
        private readonly AuthService $authService,
        private readonly TokenService $tokenService
    ) {}

    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $data = $this->authService->login($request->validated());
            return ApiResponse::success($data, 'Login successful');
        } catch (\Exception $e) {
            if ($e->getMessage() === 'KYC_PENDING') {
                return ApiResponse::error('KYC belum disetujui', 403, 'KYC_PENDING');
            }
            if (str_contains($e->getMessage(), 'Invalid credentials') || 
                str_contains($e->getMessage(), 'inactive') || 
                str_contains($e->getMessage(), 'locked')) {
                return ApiResponse::error($e->getMessage(), 401);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function adminLogin(AdminLoginRequest $request): JsonResponse
    {
        try {
            $data = $this->authService->adminLogin($request->validated());
            return ApiResponse::success($data, 'Admin login successful');
        } catch (\Exception $e) {
            if (str_contains($e->getMessage(), 'Invalid credentials') || 
                str_contains($e->getMessage(), 'inactive')) {
                return ApiResponse::error($e->getMessage(), 401);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function refresh(): JsonResponse
    {
        try {
            $refreshToken = request()->bearerToken();
            if (!$refreshToken) {
                return ApiResponse::error('Refresh token required', 401);
            }

            $data = $this->tokenService->refreshToken($refreshToken);
            return ApiResponse::success($data, 'Token refreshed');
        } catch (\Exception $e) {
            return ApiResponse::error('Invalid refresh token', 401);
        }
    }
}

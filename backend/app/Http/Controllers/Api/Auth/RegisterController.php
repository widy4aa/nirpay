<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\CheckAvailabilityRequest;
use App\Services\Auth\AuthService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class RegisterController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $data = $this->authService->register($request->validated());
            return ApiResponse::success($data, 'Registration successful', 201);
        } catch (\Exception $e) {
            if (str_contains($e->getMessage(), 'already registered') || str_contains($e->getMessage(), 'already exists')) {
                return ApiResponse::error($e->getMessage(), 409, 'DUPLICATE_ENTRY');
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function checkAvailability(CheckAvailabilityRequest $request): JsonResponse
    {
        $data = $this->authService->checkAvailability(
            $request->email,
            $request->phone
        );

        return ApiResponse::success($data);
    }

    public function checkUsername(string $username): JsonResponse
    {
        $data = $this->authService->checkUsername($username);
        return ApiResponse::success($data);
    }
}

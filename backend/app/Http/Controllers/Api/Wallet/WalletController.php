<?php

namespace App\Http\Controllers\Api\Wallet;

use App\Http\Controllers\Controller;
use App\Services\Wallet\WalletService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function __construct(
        private readonly WalletService $walletService
    ) {}

    public function balance(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;
            $data = $this->walletService->getBalance($user->id);
            return ApiResponse::success($data);
        } catch (\Exception $e) {
            if ($e->getMessage() === 'Wallet not found') {
                return ApiResponse::error($e->getMessage(), 404);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function transactions(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;
            $data = $this->walletService->getTransactions($user->id);
            return ApiResponse::success($data);
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function resolve(Request $request, string $username): JsonResponse
    {
        try {
            $data = $this->walletService->resolveUsername($username);
            return ApiResponse::success($data);
        } catch (\Exception $e) {
            if ($e->getMessage() === 'User not found') {
                return ApiResponse::error($e->getMessage(), 404);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

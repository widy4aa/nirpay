<?php

namespace App\Http\Controllers\Api\Wallet;

use App\Http\Controllers\Controller;
use App\Services\Wallet\TopUpService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TopUpController extends Controller
{
    public function __construct(
        private readonly TopUpService $topUpService
    ) {}

    public function request(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;

            $validated = $request->validate([
                'amountCent' => 'required|integer|min:1',
            ]);

            $data = $this->topUpService->requestTopUp($user, $validated['amountCent']);
            return ApiResponse::success($data, 'Top up request submitted');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function approve(Request $request, string $txId): JsonResponse
    {
        try {
            $data = $this->topUpService->approveTopUp($txId);
            return ApiResponse::success($data, 'Top up approved');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function reject(Request $request, string $txId): JsonResponse
    {
        try {
            $reason = $request->input('reason', '');
            $data = $this->topUpService->rejectTopUp($txId, $reason);
            return ApiResponse::success($data, 'Top up rejected');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

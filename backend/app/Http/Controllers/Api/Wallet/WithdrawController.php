<?php

namespace App\Http\Controllers\Api\Wallet;

use App\Http\Controllers\Controller;
use App\Services\Wallet\WithdrawService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WithdrawController extends Controller
{
    public function __construct(
        private readonly WithdrawService $withdrawService
    ) {}

    public function request(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;

            $validated = $request->validate([
                'amountCent' => 'required|integer|min:1',
                'method' => 'required|string|max:20',
                'accountNumber' => 'required|string|max:50',
            ]);

            $data = $this->withdrawService->requestWithdraw(
                $user,
                $validated['amountCent'],
                $validated['method'],
                $validated['accountNumber']
            );

            return ApiResponse::success($data, 'Withdraw request submitted');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function approve(Request $request, string $txId): JsonResponse
    {
        try {
            $data = $this->withdrawService->approveWithdraw($txId);
            return ApiResponse::success($data, 'Withdraw approved');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function reject(Request $request, string $txId): JsonResponse
    {
        try {
            $reason = $request->input('reason', '');
            $data = $this->withdrawService->rejectWithdraw($txId, $reason);
            return ApiResponse::success($data, 'Withdraw rejected');
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

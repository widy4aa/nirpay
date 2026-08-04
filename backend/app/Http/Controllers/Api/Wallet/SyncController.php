<?php

namespace App\Http\Controllers\Api\Wallet;

use App\Http\Controllers\Controller;
use App\Services\Wallet\SyncService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function __construct(
        private readonly SyncService $syncService
    ) {}

    public function sync(Request $request): JsonResponse
    {
        try {
            $user = $request->auth;
            $transactions = $request->input('transactions', []);

            if (empty($transactions)) {
                // Tidak ada transaksi, cukup return balance
                $wallet = \App\Models\WalletBalance::where('user_id', $user->id)->first();
                return ApiResponse::success([
                    'synced' => [],
                    'rejected' => [],
                    'balance' => [
                        'amountCent' => (string) ($wallet->amount_cent ?? 0),
                        'reservedCent' => (string) ($wallet->reserved_cent ?? 0),
                        'currency' => $wallet->currency ?? 'IDR',
                    ],
                ], 'No pending transactions');
            }

            $result = $this->syncService->processSync($user, $transactions);
            return ApiResponse::success($result, 'Sync completed');
        } catch (\Exception $e) {
            return ApiResponse::error('Sync failed: ' . $e->getMessage(), 500);
        }
    }
}

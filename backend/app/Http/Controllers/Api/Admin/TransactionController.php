<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Transaction::with('user');

            // Filter by status
            $status = $request->input('status');
            if ($status && $status !== 'all') {
                $query->where('sync_status', $status);
            }

            // Filter by tx_type
            $txType = $request->input('txType');
            if ($txType && $txType !== 'all') {
                $query->where('tx_type', $txType);
            }

            // Paginate
            $page = (int) $request->input('page', 1);
            $limit = (int) $request->input('limit', 20);

            $total = $query->count();
            $transactions = $query
                ->orderBy('created_at', 'desc')
                ->skip(($page - 1) * $limit)
                ->take($limit)
                ->get()
                ->map(function ($tx) {
                    return [
                        'id' => $tx->id,
                        'txId' => $tx->tx_id,
                        'userId' => $tx->user_id,
                        'userName' => $tx->user?->full_name ?? '-',
                        'userEmail' => $tx->user?->email ?? '-',
                        'direction' => $tx->direction,
                        'txType' => $tx->tx_type,
                        'amountCent' => (int) $tx->amount_cent,
                        'hopCount' => $tx->hop_count,
                        'syncStatus' => $tx->sync_status,
                        'counterpartyName' => $tx->counterparty_name,
                        'counterpartyId' => $tx->counterparty_id,
                        'rejectReason' => $tx->reject_reason,
                        'createdAt' => $tx->created_at->toIso8601String(),
                    ];
                })
                ->toArray();

            return ApiResponse::success([
                'transactions' => $transactions,
                'meta' => [
                    'total' => $total,
                    'page' => $page,
                    'limit' => $limit,
                    'totalPages' => ceil($total / $limit),
                ],
            ]);
        } catch (\Exception $e) {
            return ApiResponse::error($e->getMessage(), 500);
        }
    }
}

<?php

namespace App\Services\Wallet;

use App\Models\User;
use App\Models\WalletBalance;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class TopUpService
{
    /**
     * Request top up. Transaksi dibuat dengan status PENDING.
     * Saldo TIDAK ditambah sampai admin ACC.
     */
    public function requestTopUp(User $user, int $amountCent): array
    {
        if ($amountCent <= 0) {
            throw new \Exception('Amount must be greater than 0');
        }

        // Buat atau ambil wallet
        $wallet = WalletBalance::firstOrCreate(
            ['user_id' => $user->id],
            [
                'id' => Str::uuid(),
                'amount_cent' => 0,
                'reserved_cent' => 0,
                'currency' => 'IDR',
                'max_hop' => 3,
            ]
        );

        $txId = Str::uuid();

        DB::transaction(function () use ($user, $amountCent, $txId) {
            Transaction::create([
                'id' => Str::uuid(),
                'tx_id' => $txId,
                'user_id' => $user->id,
                'direction' => 'CREDIT',
                'tx_type' => 'TOPUP',
                'amount_cent' => $amountCent,
                'hop_count' => 0,
                'sync_status' => 'PENDING',
            ]);
        });

        Log::info("[TopUp] User {$user->id} requested top up: {$amountCent} cent, txId: {$txId}");

        return [
            'txId' => $txId,
            'status' => 'PENDING',
            'amountCent' => $amountCent,
            'currency' => 'IDR',
        ];
    }

    /**
     * Admin approve top up. Saldo ditambahkan.
     */
    public function approveTopUp(string $txId): array
    {
        $tx = Transaction::where('tx_id', $txId)->firstOrFail();

        if ($tx->sync_status !== 'PENDING') {
            throw new \Exception('Transaction is not pending');
        }

        DB::transaction(function () use ($tx) {
            // Tambah saldo
            $wallet = WalletBalance::where('user_id', $tx->user_id)->first();
            if ($wallet) {
                $wallet->increment('amount_cent', $tx->amount_cent);
                $wallet->increment('total_minted', $tx->amount_cent);
                $wallet->update(['last_tx_at' => now()]);
            }

            // Update status transaksi
            $tx->update(['sync_status' => 'SYNCED']);
        });

        Log::info("[TopUp] Approved: {$txId}, amount: {$tx->amount_cent}");

        return [
            'txId' => $txId,
            'status' => 'SYNCED',
            'amountCent' => (int) $tx->amount_cent,
        ];
    }

    /**
     * Admin reject top up.
     */
    public function rejectTopUp(string $txId, string $reason = ''): array
    {
        $tx = Transaction::where('tx_id', $txId)->firstOrFail();

        if ($tx->sync_status !== 'PENDING') {
            throw new \Exception('Transaction is not pending');
        }

        $tx->update([
            'sync_status' => 'REJECTED',
            'reject_reason' => $reason,
        ]);

        Log::info("[TopUp] Rejected: {$txId}, reason: {$reason}");

        return [
            'txId' => $txId,
            'status' => 'REJECTED',
            'reason' => $reason,
        ];
    }
}

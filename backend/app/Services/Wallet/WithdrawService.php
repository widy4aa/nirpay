<?php

namespace App\Services\Wallet;

use App\Models\User;
use App\Models\WalletBalance;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class WithdrawService
{
    // Metode pencairan yang diizinkan
    const WITHDRAW_METHODS = [
        'BCA', 'MANDIRI', 'BRI', 'BNI',
        'GOPAY', 'OVO', 'DANA',
    ];

    /**
     * Request withdraw. Saldo langsung di-reserve (dikurangi).
     * Jika admin REJECT, saldo dikembalikan.
     */
    public function requestWithdraw(User $user, int $amountCent, string $method, string $accountNumber): array
    {
        if ($amountCent <= 0) {
            throw new \Exception('Amount must be greater than 0');
        }

        if (!in_array(strtoupper($method), self::WITHDRAW_METHODS)) {
            throw new \Exception('Invalid withdrawal method');
        }

        if (empty($accountNumber)) {
            throw new \Exception('Account number is required');
        }

        // Ambil wallet
        $wallet = WalletBalance::where('user_id', $user->id)->first();

        if (!$wallet) {
            throw new \Exception('Wallet not found');
        }

        // Cek saldo cukup
        $availableBalance = $wallet->amount_cent - $wallet->reserved_cent;
        if ($availableBalance < $amountCent) {
            throw new \Exception('Insufficient balance');
        }

        $txId = Str::uuid();

        DB::transaction(function () use ($user, $wallet, $amountCent, $method, $accountNumber, $txId) {
            // Reserve saldo (kurangi available)
            $wallet->increment('reserved_cent', $amountCent);

            // Buat transaksi
            Transaction::create([
                'id' => Str::uuid(),
                'tx_id' => $txId,
                'user_id' => $user->id,
                'direction' => 'DEBIT',
                'tx_type' => 'WITHDRAW',
                'amount_cent' => $amountCent,
                'hop_count' => 0,
                'sync_status' => 'PENDING',
                'counterparty_name' => $method,
                'counterparty_id' => $accountNumber,
            ]);
        });

        Log::info("[Withdraw] User {$user->id} requested withdraw: {$amountCent} cent via {$method} ({$accountNumber}), txId: {$txId}");

        return [
            'txId' => $txId,
            'status' => 'PENDING',
            'amountCent' => $amountCent,
            'method' => $method,
            'accountNumber' => $accountNumber,
            'currency' => 'IDR',
        ];
    }

    /**
     * Admin approve withdraw. Proses pencairan.
     */
    public function approveWithdraw(string $txId): array
    {
        $tx = Transaction::where('tx_id', $txId)->firstOrFail();

        if ($tx->sync_status !== 'PENDING') {
            throw new \Exception('Transaction is not pending');
        }

        DB::transaction(function () use ($tx) {
            // Kurangi saldo permanen
            $wallet = WalletBalance::where('user_id', $tx->user_id)->first();
            if ($wallet) {
                $wallet->decrement('amount_cent', $tx->amount_cent);
                $wallet->decrement('reserved_cent', $tx->amount_cent);
                $wallet->increment('total_sent', $tx->amount_cent);
                $wallet->update(['last_tx_at' => now()]);
            }

            // Update status transaksi
            $tx->update(['sync_status' => 'SYNCED']);
        });

        Log::info("[Withdraw] Approved: {$txId}, amount: {$tx->amount_cent}");

        return [
            'txId' => $txId,
            'status' => 'SYNCED',
            'amountCent' => (int) $tx->amount_cent,
        ];
    }

    /**
     * Admin reject withdraw. Kembalikan saldo.
     */
    public function rejectWithdraw(string $txId, string $reason = ''): array
    {
        $tx = Transaction::where('tx_id', $txId)->firstOrFail();

        if ($tx->sync_status !== 'PENDING') {
            throw new \Exception('Transaction is not pending');
        }

        DB::transaction(function () use ($tx) {
            // Kembalikan reserved balance
            $wallet = WalletBalance::where('user_id', $tx->user_id)->first();
            if ($wallet) {
                $wallet->decrement('reserved_cent', $tx->amount_cent);
            }

            // Update status transaksi
            $tx->update([
                'sync_status' => 'REJECTED',
                'reject_reason' => $reason,
            ]);
        });

        Log::info("[Withdraw] Rejected: {$txId}, reason: {$reason}");

        return [
            'txId' => $txId,
            'status' => 'REJECTED',
            'reason' => $reason,
        ];
    }
}

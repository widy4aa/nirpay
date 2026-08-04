<?php

namespace App\Services\Wallet;

use App\Models\User;
use App\Models\WalletBalance;
use Illuminate\Support\Facades\Log;

class WalletService
{
    public function getBalance(string $userId): array
    {
        // Auto-provision saldo awal untuk user baru
        $user = User::find($userId);
        if ($user) {
            app(SyncService::class)->provisionInitialBalance($user);
        }

        $wallet = WalletBalance::where('user_id', $userId)->first();

        if (!$wallet) {
            Log::warning("[Wallet] Wallet not found for user: {$userId}");
            throw new \Exception('Wallet not found');
        }

        return [
            'amountCent' => (string) $wallet->amount_cent,
            'reservedCent' => (string) $wallet->reserved_cent,
            'currency' => $wallet->currency,
        ];
    }

    public function getTransactions(string $userId): array
    {
        $transactions = \App\Models\Transaction::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($tx) {
                return [
                    'txId' => $tx->tx_id,
                    'direction' => $tx->direction,
                    'txType' => $tx->tx_type,
                    'amountCent' => (int) $tx->amount_cent,
                    'hopCount' => $tx->hop_count,
                    'syncStatus' => $tx->sync_status,
                    'counterpartyName' => $tx->counterparty_name,
                    'counterpartyId' => $tx->counterparty_id,
                    'createdAt' => $tx->created_at->toIso8601String(),
                ];
            })
            ->toArray();

        return $transactions;
    }

    public function resolveUsername(string $username): array
    {
        $user = User::where('username', $username)->first();

        if (!$user) {
            Log::warning("[Wallet] User not found: {$username}");
            throw new \Exception('User not found');
        }

        return [
            'id' => $user->id,
            'username' => $user->username,
            'publicKeyB64' => $user->public_key_b64,
        ];
    }
}

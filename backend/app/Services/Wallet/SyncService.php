<?php

namespace App\Services\Wallet;

use App\Models\User;
use App\Models\WalletBalance;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class SyncService
{
    // Saldo awal untuk user baru (dalam cent)
    // 5000000 cent = Rp 50.000
    const INITIAL_BALANCE_CENT = 5000000;

    /**
     * Proses sync: cek user baru, terima transaksi dari client, validasi, update balance.
     */
    public function processSync(User $user, array $transactions): array
    {
        // Cek dan berikan saldo awal jika user baru (belum pernah dapat TOPUP)
        $this->provisionInitialBalance($user);

        $synced = [];
        $rejected = [];

        DB::transaction(function () use ($user, $transactions, &$synced, &$rejected) {
            foreach ($transactions as $tx) {
                $result = $this->processTransaction($user, $tx);

                if ($result['success']) {
                    $synced[] = [
                        'txId' => $tx['txId'],
                        'status' => 'SYNCED',
                    ];
                } else {
                    $rejected[] = [
                        'txId' => $tx['txId'],
                        'reason' => $result['reason'],
                    ];
                }
            }
        });

        // Ambil balance terbaru setelah semua transaksi diproses
        $wallet = WalletBalance::where('user_id', $user->id)->first();
        $balance = [
            'amountCent' => (string) ($wallet->amount_cent ?? 0),
            'reservedCent' => (string) ($wallet->reserved_cent ?? 0),
            'currency' => $wallet->currency ?? 'IDR',
        ];

        Log::info("[Sync] User {$user->id}: " . count($synced) . " synced, " . count($rejected) . " rejected");

        return [
            'synced' => $synced,
            'rejected' => $rejected,
            'balance' => $balance,
        ];
    }

    /**
     * Berikan saldo awal ke user baru.
     * Dipanggil otomatis saat sync pertama kali.
     * Hanya berjalan jika user belum punya transaksi TOPUP.
     */
    public function provisionInitialBalance(User $user): void
    {
        // Cek apakah user sudah pernah dapat TOPUP
        $hasTopup = Transaction::where('user_id', $user->id)
            ->where('tx_type', 'TOPUP')
            ->exists();

        if ($hasTopup) {
            Log::info("[Provision] User {$user->id} already has TOPUP, skipping");
            return;
        }

        DB::transaction(function () use ($user) {
            // Buat transaksi TOPUP
            $txId = Str::uuid();
            Transaction::create([
                'id' => Str::uuid(),
                'tx_id' => $txId,
                'user_id' => $user->id,
                'direction' => 'CREDIT',
                'tx_type' => 'TOPUP',
                'amount_cent' => self::INITIAL_BALANCE_CENT,
                'hop_count' => 0,
                'sync_status' => 'SYNCED',
            ]);

            // Buat atau update wallet balance
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

            $wallet->update([
                'amount_cent' => $wallet->amount_cent + self::INITIAL_BALANCE_CENT,
                'total_minted' => $wallet->total_minted + self::INITIAL_BALANCE_CENT,
                'total_received' => $wallet->total_received + self::INITIAL_BALANCE_CENT,
                'last_tx_at' => now(),
            ]);

            Log::info("[Provision] User {$user->id} received initial balance: " . self::INITIAL_BALANCE_CENT . " cent");
        });
    }

    /**
     * Modifikasi balance user secara manual (untuk admin/debug).
     * Bisa dipanggil lewat artisan command atau admin endpoint.
     */
    public static function setBalance(string $userId, int $amountCent, string $reason = 'MANUAL_ADJUST'): void
    {
        $wallet = WalletBalance::where('user_id', $userId)->first();

        if (!$wallet) {
            $wallet = WalletBalance::create([
                'id' => Str::uuid(),
                'user_id' => $userId,
                'amount_cent' => 0,
                'reserved_cent' => 0,
                'currency' => 'IDR',
                'max_hop' => 3,
            ]);
        }

        $oldBalance = $wallet->amount_cent;
        $diff = $amountCent - $oldBalance;

        DB::transaction(function () use ($wallet, $userId, $amountCent, $diff, $reason) {
            $wallet->update([
                'amount_cent' => $amountCent,
                'last_tx_at' => now(),
            ]);

            // Catat sebagai transaksi ADJUSTMENT
            Transaction::create([
                'id' => Str::uuid(),
                'tx_id' => Str::uuid(),
                'user_id' => $userId,
                'direction' => $diff >= 0 ? 'CREDIT' : 'DEBIT',
                'tx_type' => 'TOPUP',
                'amount_cent' => abs($diff),
                'hop_count' => 0,
                'sync_status' => 'SYNCED',
                'reject_reason' => $reason,
            ]);
        });

        Log::info("[Balance] User {$userId}: {$oldBalance} → {$amountCent} ({$reason})");
    }

    private function processTransaction(User $user, array $tx): array
    {
        // Validasi dasar
        if (empty($tx['txId'])) {
            return ['success' => false, 'reason' => 'MISSING_TX_ID'];
        }

        if (!in_array($tx['direction'] ?? '', ['CREDIT', 'DEBIT'])) {
            return ['success' => false, 'reason' => 'INVALID_DIRECTION'];
        }

        $amountCent = (int) ($tx['amountCent'] ?? 0);
        if ($amountCent <= 0) {
            return ['success' => false, 'reason' => 'INVALID_AMOUNT'];
        }

        // Cek duplikat
        $exists = Transaction::where('tx_id', $tx['txId'])->exists();
        if ($exists) {
            return ['success' => false, 'reason' => 'DUPLICATE_TX'];
        }

        // Ambil atau buat wallet
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

        // Proses berdasarkan direction
        if ($tx['direction'] === 'DEBIT') {
            // Kirim uang: kurangi balance
            if ($wallet->amount_cent < $amountCent) {
                return ['success' => false, 'reason' => 'INSUFFICIENT_BALANCE'];
            }
            $wallet->decrement('amount_cent', $amountCent);
            $wallet->decrement('total_sent', $amountCent);
        } else {
            // Terima uang: tambah balance
            $wallet->increment('amount_cent', $amountCent);
            $wallet->increment('total_received', $amountCent);
        }

        // Update last_tx_at
        $wallet->update(['last_tx_at' => now()]);

        // Simpan transaksi
        Transaction::create([
            'id' => Str::uuid(),
            'tx_id' => $tx['txId'],
            'user_id' => $user->id,
            'direction' => $tx['direction'],
            'tx_type' => $tx['txType'] ?? 'TRANSFER',
            'amount_cent' => $amountCent,
            'hop_count' => $tx['hopCount'] ?? 0,
            'sync_status' => 'SYNCED',
            'counterparty_name' => $tx['counterpartyName'] ?? null,
            'counterparty_id' => $tx['counterpartyId'] ?? null,
        ]);

        Log::info("[Sync] Transaction {$tx['txId']} synced: {$tx['direction']} {$amountCent} cent");

        return ['success' => true];
    }
}

<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\WalletBalance;
use App\Models\Transaction;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'id' => Str::uuid(),
                'email' => 'user1@gmail.com',
                'phone_number' => '081111111111',
                'username' => 'user1',
                'full_name' => 'User Satu',
                'password_hash' => Hash::make('password'),
                'pin_hash' => Hash::make('123456'),
                'public_key_b64' => 'base64-ed25519-public-key-user1',
                'nik' => '3201234567890001',
                'province' => 'DKI Jakarta',
                'city' => 'Jakarta Selatan',
                'district' => 'Kebayoran Baru',
                'village' => 'Gandaria Utara',
                'postal_code' => '12140',
                'rt' => '001',
                'rw' => '002',
                'gender' => 'MALE',
                'birth_date' => '1995-01-15',
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
            ],
            [
                'id' => Str::uuid(),
                'email' => 'user2@gmail.com',
                'phone_number' => '082222222222',
                'username' => 'user2',
                'full_name' => 'User Dua',
                'password_hash' => Hash::make('password'),
                'pin_hash' => Hash::make('123456'),
                'public_key_b64' => 'base64-ed25519-public-key-user2',
                'nik' => '3201234567890002',
                'province' => 'Jawa Barat',
                'city' => 'Bandung',
                'district' => 'Coblong',
                'village' => 'Dago',
                'postal_code' => '40135',
                'rt' => '003',
                'rw' => '005',
                'gender' => 'FEMALE',
                'birth_date' => '1998-05-20',
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
            ],
        ];

        // Saldo awal: Rp 100.000 (10000000 cent) per user
        $initialBalance = 10000000; // 100000 * 100

        foreach ($users as $userData) {
            $user = User::create($userData);

            // Buat wallet balance
            $wallet = WalletBalance::create([
                'user_id' => $user->id,
                'amount_cent' => $initialBalance,
                'reserved_cent' => 0,
                'currency' => 'IDR',
                'max_hop' => 3,
                'total_minted' => $initialBalance,
                'total_received' => $initialBalance,
            ]);

            // Buat transaksi TOPUP awal
            Transaction::create([
                'id' => Str::uuid(),
                'tx_id' => Str::uuid(),
                'user_id' => $user->id,
                'direction' => 'CREDIT',
                'tx_type' => 'TOPUP',
                'amount_cent' => $initialBalance,
                'hop_count' => 0,
                'sync_status' => 'SYNCED',
            ]);

            $this->command->info("User {$userData['email']} created with balance: Rp " . number_format($initialBalance / 100, 0, ',', '.'));
        }

        $this->command->info('2 dummy users seeded successfully!');
    }
}

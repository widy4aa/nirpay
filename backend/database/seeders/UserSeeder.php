<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\WalletBalance;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'id' => Str::uuid(),
                'email' => 'user1@nirpay.com',
                'phone_number' => '081234567890',
                'username' => 'budisan',
                'full_name' => 'Budi Santoso',
                'password_hash' => Hash::make('Password1'),
                'pin_hash' => Hash::make('123456'),
                'public_key_b64' => 'base64-ed25519-public-key-1',
                'nik' => '3201234567890001',
                'province' => 'Jawa Barat',
                'city' => 'Bandung',
                'district' => 'Coblong',
                'village' => 'Dago',
                'postal_code' => '40135',
                'rt' => '01',
                'rw' => '02',
                'gender' => 'MALE',
                'birth_date' => '1990-05-15',
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
            ],
            [
                'id' => Str::uuid(),
                'email' => 'user2@nirpay.com',
                'phone_number' => '081234567891',
                'username' => 'sitinur',
                'full_name' => 'Siti Nurhaliza',
                'password_hash' => Hash::make('Password1'),
                'pin_hash' => Hash::make('123456'),
                'public_key_b64' => 'base64-ed25519-public-key-2',
                'nik' => '3201234567890002',
                'province' => 'Jawa Barat',
                'city' => 'Bandung',
                'district' => 'Coblong',
                'village' => 'Dago',
                'postal_code' => '40135',
                'rt' => '01',
                'rw' => '02',
                'gender' => 'FEMALE',
                'birth_date' => '1992-08-20',
                'kyc_status' => 'UNVERIFIED',
                'is_kyc_done' => false,
            ],
            [
                'id' => Str::uuid(),
                'email' => 'user3@nirpay.com',
                'phone_number' => '081234567892',
                'username' => 'ahmadfauzi',
                'full_name' => 'Ahmad Fauzi',
                'password_hash' => Hash::make('Password1'),
                'pin_hash' => Hash::make('123456'),
                'public_key_b64' => 'base64-ed25519-public-key-3',
                'nik' => '3201234567890003',
                'province' => 'Jawa Barat',
                'city' => 'Bandung',
                'district' => 'Coblong',
                'village' => 'Dago',
                'postal_code' => '40135',
                'rt' => '01',
                'rw' => '02',
                'gender' => 'MALE',
                'birth_date' => '1988-12-10',
                'kyc_status' => 'PENDING',
                'is_kyc_done' => false,
            ],
            [
                'id' => Str::uuid(),
                'email' => 'dio34678@gmail.com',
                'phone_number' => '081234567893',
                'username' => 'dio34678',
                'full_name' => 'Dio Pratama',
                'password_hash' => Hash::make('12312312'),
                'pin_hash' => Hash::make('123123'),
                'public_key_b64' => 'base64-ed25519-public-key-4',
                'nik' => '3201234567890004',
                'province' => 'DKI Jakarta',
                'city' => 'Jakarta Selatan',
                'district' => 'Kebayoran Baru',
                'village' => 'Gandaria Utara',
                'postal_code' => '12140',
                'rt' => '003',
                'rw' => '005',
                'gender' => 'MALE',
                'birth_date' => '1995-03-20',
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
            ],
            [
                'id' => Str::uuid(),
                'email' => 'drivedio34@gmail.com',
                'phone_number' => '081234567894',
                'username' => 'drivedio34',
                'full_name' => 'Drive Dio',
                'password_hash' => Hash::make('12312312'),
                'pin_hash' => Hash::make('123123'),
                'public_key_b64' => 'base64-ed25519-public-key-5',
                'nik' => '3201234567890005',
                'province' => 'DKI Jakarta',
                'city' => 'Jakarta Timur',
                'district' => 'Cakung',
                'village' => 'Penggilingan',
                'postal_code' => '13940',
                'rt' => '001',
                'rw' => '002',
                'gender' => 'MALE',
                'birth_date' => '1998-07-15',
                'kyc_status' => 'APPROVED',
                'is_kyc_done' => true,
            ],
        ];

        foreach ($users as $userData) {
            $user = User::create($userData);

            // Buat wallet balance (mulai dari 0)
            // Saldo awal akan diberikan otomatis oleh SyncService::provisionInitialBalance()
            // saat user pertama kali sync
            WalletBalance::create([
                'user_id' => $user->id,
                'amount_cent' => 0,
                'reserved_cent' => 0,
                'currency' => 'IDR',
                'max_hop' => 3,
            ]);
        }

        $this->command->info('Users seeded! Initial balance will be provisioned on first sync.');
    }
}

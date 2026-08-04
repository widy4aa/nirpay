<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Admin;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $admins = [
            [
                'id' => Str::uuid(),
                'email' => 'admin@nirpay.com',
                'password_hash' => Hash::make('Admin123'),
                'name' => 'Super Admin',
                'role' => 'SUPER_ADMIN',
            ],
            [
                'id' => Str::uuid(),
                'email' => 'admin2@nirpay.com',
                'password_hash' => Hash::make('Admin123'),
                'name' => 'Admin KYC',
                'role' => 'ADMIN',
            ],
        ];

        foreach ($admins as $adminData) {
            Admin::create($adminData);
        }

        $this->command->info('Admins seeded successfully!');
    }
}

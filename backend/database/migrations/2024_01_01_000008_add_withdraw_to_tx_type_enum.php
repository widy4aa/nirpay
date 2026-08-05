<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // PostgreSQL: alter enum type to add WITHDRAW
        DB::statement("ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_tx_type_check");
        DB::statement("ALTER TABLE transactions ADD CONSTRAINT transactions_tx_type_check CHECK (tx_type IN ('TOPUP', 'TRANSFER', 'WITHDRAW'))");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_tx_type_check");
        DB::statement("ALTER TABLE transactions ADD CONSTRAINT transactions_tx_type_check CHECK (tx_type IN ('TOPUP', 'TRANSFER'))");
    }
};

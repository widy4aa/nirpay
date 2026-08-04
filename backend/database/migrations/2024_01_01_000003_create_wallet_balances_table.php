<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallet_balances', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id')->unique();
            $table->decimal('amount_cent', 20, 0)->default(0);
            $table->decimal('reserved_cent', 20, 0)->default(0);
            $table->string('currency')->default('IDR');
            $table->integer('max_hop')->default(3);
            $table->decimal('total_minted', 20, 0)->default(0);
            $table->decimal('total_sent', 20, 0)->default(0);
            $table->decimal('total_received', 20, 0)->default(0);
            $table->timestamp('last_tx_at')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_balances');
    }
};

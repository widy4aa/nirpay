<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('tx_id')->unique();
            $table->uuid('user_id');
            $table->enum('direction', ['CREDIT', 'DEBIT']);
            $table->enum('tx_type', ['TOPUP', 'TRANSFER']);
            $table->decimal('amount_cent', 20, 0);
            $table->integer('hop_count')->default(0);
            $table->enum('sync_status', ['PENDING', 'SYNCED', 'REJECTED'])->default('SYNCED');
            $table->string('reject_reason')->nullable();
            $table->string('counterparty_name')->nullable();
            $table->string('counterparty_id')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('sync_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};

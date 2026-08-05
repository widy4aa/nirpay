<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('device_sessions', function (Blueprint $table) {
            $table->string('fcm_token')->nullable()->after('refresh_token');
        });
    }

    public function down(): void
    {
        Schema::table('device_sessions', function (Blueprint $table) {
            $table->dropColumn('fcm_token');
        });
    }
};

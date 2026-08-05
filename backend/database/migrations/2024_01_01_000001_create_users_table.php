<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('email')->unique();
            $table->string('username')->unique()->nullable();
            $table->string('full_name');
            $table->string('phone_number')->unique()->nullable();
            $table->string('password_hash');
            $table->string('pin_hash');
            $table->text('public_key_b64')->nullable();
            $table->boolean('is_kyc_done')->default(false);
            $table->string('kyc_status')->default('UNVERIFIED');
            $table->string('kyc_face_url')->nullable();
            $table->timestamp('kyc_submitted_at')->nullable();
            $table->timestamp('kyc_reviewed_at')->nullable();
            $table->text('kyc_reject_reason')->nullable();
            $table->string('nik')->nullable();
            $table->string('province')->nullable();
            $table->string('city')->nullable();
            $table->string('district')->nullable();
            $table->string('village')->nullable();
            $table->string('postal_code')->nullable();
            $table->string('rt')->nullable();
            $table->string('rw')->nullable();
            $table->string('ktp_photo_url')->nullable();
            $table->string('profile_photo_url')->nullable();
            $table->string('device_id')->nullable();
            $table->string('gender')->nullable();
            $table->date('birth_date')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('is_locked')->default(false);
            $table->string('locked_reason')->nullable();
            $table->integer('failed_login_count')->default(0);
            $table->timestamp('last_login_at')->nullable();
            $table->string('last_login_ip')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};

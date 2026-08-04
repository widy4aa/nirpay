<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class OtpVerification extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'otp_verifications';

    protected $fillable = [
        'email',
        'otp_hash',
        'channel',
        'purpose',
        'attempt_count',
        'max_attempts',
        'is_used',
        'expires_at',
    ];

    protected $casts = [
        'is_used' => 'boolean',
        'expires_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}

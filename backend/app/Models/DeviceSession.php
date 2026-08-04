<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class DeviceSession extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'device_sessions';

    protected $fillable = [
        'user_id',
        'device_id',
        'device_name',
        'ip_address',
        'auth_token',
        'refresh_token',
        'is_revoked',
        'expires_at',
        'last_active_at',
    ];

    protected $casts = [
        'is_revoked' => 'boolean',
        'expires_at' => 'datetime',
        'last_active_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

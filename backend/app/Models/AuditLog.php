<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AuditLog extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'audit_logs';

    protected $fillable = [
        'actor_id',
        'actor_role',
        'event_type',
        'resource_type',
        'resource_id',
        'ip_address',
        'user_agent',
        'detail',
    ];

    protected $casts = [
        'detail' => 'json',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}

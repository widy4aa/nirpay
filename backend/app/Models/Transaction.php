<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasUuids;

    protected $fillable = [
        'tx_id',
        'user_id',
        'direction',
        'tx_type',
        'amount_cent',
        'hop_count',
        'sync_status',
        'reject_reason',
        'counterparty_name',
        'counterparty_id',
    ];

    protected $casts = [
        'amount_cent' => 'decimal:0',
        'hop_count' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

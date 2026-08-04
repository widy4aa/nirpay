<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class WalletBalance extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'wallet_balances';

    protected $fillable = [
        'user_id',
        'amount_cent',
        'reserved_cent',
        'currency',
        'max_hop',
        'total_minted',
        'total_sent',
        'total_received',
        'last_tx_at',
    ];

    protected $casts = [
        'amount_cent' => 'decimal:0',
        'reserved_cent' => 'decimal:0',
        'total_minted' => 'decimal:0',
        'total_sent' => 'decimal:0',
        'total_received' => 'decimal:0',
        'last_tx_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

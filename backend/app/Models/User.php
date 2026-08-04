<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable, HasUuids;

    protected $table = 'users';

    protected $fillable = [
        'email',
        'phone_number',
        'username',
        'full_name',
        'password_hash',
        'pin_hash',
        'public_key_b64',
        'is_kyc_done',
        'kyc_status',
        'kyc_face_url',
        'kyc_submitted_at',
        'kyc_reviewed_at',
        'kyc_reject_reason',
        'nik',
        'province',
        'city',
        'district',
        'village',
        'postal_code',
        'rt',
        'rw',
        'ktp_photo_url',
        'profile_photo_url',
        'gender',
        'birth_date',
        'is_active',
        'is_locked',
        'locked_reason',
        'failed_login_count',
        'last_login_at',
        'last_login_ip',
    ];

    protected $hidden = [
        'password_hash',
        'pin_hash',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'is_active' => 'boolean',
        'is_locked' => 'boolean',
        'is_kyc_done' => 'boolean',
        'kyc_submitted_at' => 'datetime',
        'kyc_reviewed_at' => 'datetime',
        'last_login_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [
            'sub' => $this->id,
            'email' => $this->email,
            'role' => 'USER',
        ];
    }

    public function wallet(): HasOne
    {
        return $this->hasOne(WalletBalance::class);
    }

    public function sessions(): HasMany
    {
        return $this->hasMany(DeviceSession::class);
    }
}

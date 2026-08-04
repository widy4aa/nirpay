<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\OtpController;
use App\Http\Controllers\Api\Auth\PinController;
use App\Http\Controllers\Api\Wallet\WalletController;
use App\Http\Controllers\Api\Wallet\SyncController;
use App\Http\Controllers\Api\Wallet\TopUpController;
use App\Http\Controllers\Api\Wallet\WithdrawController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\Admin\UserController as AdminUserController;
use App\Http\Controllers\Api\Admin\StatsController;
use App\Http\Controllers\Api\Admin\KycController;
use App\Http\Controllers\Api\UploadController;
use App\Http\Controllers\Api\Admin\ActivityController;
use App\Http\Controllers\Api\Admin\TransactionController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public Auth Routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [RegisterController::class, 'register']);
    Route::post('/login', [LoginController::class, 'login']);
    Route::post('/admin/login', [LoginController::class, 'adminLogin']);
    Route::post('/check-availability', [RegisterController::class, 'checkAvailability']);
    Route::get('/check-username/{username}', [RegisterController::class, 'checkUsername']);
    Route::post('/send-otp', [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
    Route::post('/refresh', [LoginController::class, 'refresh']);
});

// Upload Routes (public, used during registration)
Route::prefix('upload')->group(function () {
    Route::post('/ktp', [UploadController::class, 'ktp']);
    Route::post('/selfie', [UploadController::class, 'selfie']);
});

// Protected Routes (require JWT)
Route::middleware(['jwt'])->group(function () {
    // Auth - Verify PIN (uses refresh token)
    Route::post('/auth/verify-pin', [PinController::class, 'verifyPin']);

    // Profile Routes
    Route::post('/profile/update', [ProfileController::class, 'update']);
    Route::post('/profile/change-pin', [ProfileController::class, 'changePin']);
    Route::post('/profile/photo', [UploadController::class, 'profilePhoto']);

    // Wallet Routes
    Route::prefix('wallet')->group(function () {
        Route::get('/balance', [WalletController::class, 'balance']);
        Route::get('/transactions', [WalletController::class, 'transactions']);
        Route::get('/resolve/{username}', [WalletController::class, 'resolve']);
        Route::post('/sync', [SyncController::class, 'sync']);

        // Top Up
        Route::post('/topup', [TopUpController::class, 'request']);
        Route::post('/topup/{txId}/approve', [TopUpController::class, 'approve']);
        Route::post('/topup/{txId}/reject', [TopUpController::class, 'reject']);

        // Withdraw
        Route::post('/withdraw', [WithdrawController::class, 'request']);
        Route::post('/withdraw/{txId}/approve', [WithdrawController::class, 'approve']);
        Route::post('/withdraw/{txId}/reject', [WithdrawController::class, 'reject']);
    });
});

// Admin Routes (require JWT + Admin role)
Route::middleware(['jwt', 'role:ADMIN,SUPER_ADMIN'])->prefix('admin')->group(function () {
    Route::get('/users', [AdminUserController::class, 'index']);
    Route::get('/users/{id}', [AdminUserController::class, 'show']);
    Route::get('/stats', [StatsController::class, 'index']);
    Route::get('/kyc', [KycController::class, 'index']);
    Route::get('/kyc/{id}', [KycController::class, 'show']);
    Route::post('/kyc/{id}/approve', [KycController::class, 'approve']);
    Route::post('/kyc/{id}/reject', [KycController::class, 'reject']);
    Route::get('/activity', [ActivityController::class, 'index']);
    Route::get('/transactions', [TransactionController::class, 'index']);
});

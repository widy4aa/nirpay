<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    public function ktp(Request $request): JsonResponse
    {
        $request->validate([
            'ktpPhoto' => ['required', 'file', 'mimes:jpg,jpeg,png', 'max:5120'],
        ]);

        $file = $request->file('ktpPhoto');
        $filename = 'ktp/' . Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs($filename, 'public');

        return ApiResponse::success([
            'url' => Storage::url($path),
            'filename' => $filename,
        ], 'KTP uploaded successfully');
    }

    public function selfie(Request $request): JsonResponse
    {
        $request->validate([
            'selfiePhoto' => ['required', 'file', 'mimes:jpg,jpeg,png', 'max:5120'],
        ]);

        $file = $request->file('selfiePhoto');
        $filename = 'selfie/' . Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs($filename, 'public');

        return ApiResponse::success([
            'url' => Storage::url($path),
            'filename' => $filename,
        ], 'Selfie uploaded successfully');
    }

    public function profilePhoto(Request $request): JsonResponse
    {
        $request->validate([
            'photo' => ['required', 'file', 'mimes:jpg,jpeg,png', 'max:5120'],
        ]);

        $file = $request->file('photo');
        $filename = 'profile/' . Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs($filename, 'public');

        // Update user profile_photo_url
        $user = $request->auth;
        if ($user) {
            $user->update(['profile_photo_url' => Storage::url($path)]);
        }

        return ApiResponse::success([
            'url' => Storage::url($path),
            'filename' => $filename,
        ], 'Profile photo uploaded successfully');
    }
}

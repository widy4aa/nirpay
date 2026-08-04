<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class VerifyOtpRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'otpId' => ['required', 'string', 'uuid'],
            'otpCode' => ['required', 'string', 'size:6', 'regex:/^[0-9]+$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'otpId.required' => 'OTP ID is required',
            'otpId.uuid' => 'Invalid OTP ID format',
            'otpCode.required' => 'OTP code is required',
            'otpCode.size' => 'OTP code must be exactly 6 digits',
            'otpCode.regex' => 'OTP code must contain only numbers',
        ];
    }
}

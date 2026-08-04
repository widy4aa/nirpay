<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'max:255'],
            'phone' => ['required', 'string', 'regex:/^(\+62|62|0)8[1-9][0-9]{6,9}$/'],
            'fullName' => ['required', 'string', 'min:2', 'max:100'],
            'username' => ['required', 'string', 'min:3', 'max:20', 'regex:/^[a-zA-Z0-9_]+$/'],
            'password' => ['required', 'string', 'min:8'],
            'pin' => ['required', 'string', 'size:8', 'regex:/^[0-9]+$/'],
            'publicKeyB64' => ['required', 'string'],
            'nik' => ['required', 'string', 'size:16', 'regex:/^[0-9]+$/'],
            'province' => ['nullable', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'district' => ['nullable', 'string', 'max:100'],
            'village' => ['nullable', 'string', 'max:100'],
            'postalCode' => ['nullable', 'string', 'max:10'],
            'rt' => ['nullable', 'string', 'max:5'],
            'rw' => ['nullable', 'string', 'max:5'],
            'ktpPhotoUrl' => ['nullable', 'string', 'max:500'],
            'kycFaceUrl' => ['nullable', 'string', 'max:500'],
            'gender' => ['nullable', 'in:MALE,FEMALE'],
            'birthDate' => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'phone.required' => 'Phone number is required',
            'phone.regex' => 'Invalid Indonesian phone number format',
            'fullName.required' => 'Full name is required',
            'username.required' => 'Username is required',
            'username.regex' => 'Username can only contain letters, numbers, and underscores',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 8 characters',
            'pin.required' => 'PIN is required',
            'pin.size' => 'PIN must be exactly 8 digits',
            'pin.regex' => 'PIN must contain only numbers',
            'publicKeyB64.required' => 'Public key is required',
            'nik.required' => 'NIK is required',
            'nik.size' => 'NIK must be exactly 16 digits',
            'nik.regex' => 'NIK must contain only numbers',
        ];
    }
}

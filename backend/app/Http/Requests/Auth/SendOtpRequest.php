<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class SendOtpRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'phone' => ['required', 'string', 'regex:/^(\+62|62|0)8[1-9][0-9]{6,9}$/'],
            'type' => ['required', 'in:register,reset'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'phone.required' => 'Phone number is required',
            'phone.regex' => 'Invalid Indonesian phone number format',
            'type.required' => 'OTP type is required',
            'type.in' => 'OTP type must be register or reset',
        ];
    }
}

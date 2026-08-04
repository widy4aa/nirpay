<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class VerifyPinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'pin' => ['required', 'string', 'size:8', 'regex:/^[0-9]+$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'pin.required' => 'PIN is required',
            'pin.size' => 'PIN must be exactly 8 digits',
            'pin.regex' => 'PIN must contain only numbers',
        ];
    }
}

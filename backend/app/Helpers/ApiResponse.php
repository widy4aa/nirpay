<?php

namespace App\Helpers;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    public static function success(mixed $data = null, string $message = 'Success', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    public static function error(string $message, int $code = 400, ?string $errorCode = null, ?array $details = null): JsonResponse
    {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errorCode || $details) {
            $response['error'] = array_filter([
                'code' => $errorCode,
                'details' => $details,
            ]);
        }

        return response()->json($response, $code);
    }

    public static function paginated(mixed $data, array $meta, string $message = 'Success'): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => array_merge($data, ['meta' => $meta]),
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $limit = (int) $request->query('limit', 10);

        $activities = AuditLog::query()
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get();

        return ApiResponse::success([
            'activities' => $activities,
            'meta' => [
                'total' => AuditLog::count(),
                'limit' => $limit,
            ],
        ]);
    }
}

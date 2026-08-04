<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Services\Admin\AdminService;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class StatsController extends Controller
{
    public function __construct(
        private readonly AdminService $adminService
    ) {}

    public function index(): JsonResponse
    {
        $data = $this->adminService->getStats();

        return ApiResponse::success($data);
    }
}

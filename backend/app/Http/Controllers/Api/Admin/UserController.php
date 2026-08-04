<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Services\Admin\AdminService;
use App\Http\Requests\Admin\PaginationRequest;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function __construct(
        private readonly AdminService $adminService
    ) {}

    public function index(PaginationRequest $request): JsonResponse
    {
        $page = $request->query('page', 1);
        $limit = $request->query('limit', 10);

        $data = $this->adminService->getUsers($page, $limit);

        return ApiResponse::success($data);
    }

    public function show(string $id): JsonResponse
    {
        $data = $this->adminService->getUserDetail($id);

        if (!$data) {
            return ApiResponse::error('User not found', 404);
        }

        return ApiResponse::success($data);
    }
}

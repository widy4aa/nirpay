<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Services\Admin\KycService;
use App\Http\Requests\Admin\RejectKycRequest;
use App\Http\Requests\Admin\KycPaginationRequest;
use App\Helpers\ApiResponse;
use Illuminate\Http\JsonResponse;

class KycController extends Controller
{
    public function __construct(
        private readonly KycService $kycService
    ) {}

    public function index(KycPaginationRequest $request): JsonResponse
    {
        $status = $request->query('status');
        $page = $request->query('page', 1);
        $limit = $request->query('limit', 20);

        $data = $this->kycService->getKycUsers($status, $page, $limit);

        return ApiResponse::success($data);
    }

    public function show(string $id): JsonResponse
    {
        try {
            $data = $this->kycService->getKycDetail($id);
            return ApiResponse::success($data);
        } catch (\Exception $e) {
            if ($e->getMessage() === 'User not found') {
                return ApiResponse::error($e->getMessage(), 404);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function approve(string $id): JsonResponse
    {
        try {
            $data = $this->kycService->approveKyc($id);
            return ApiResponse::success($data, 'KYC approved');
        } catch (\Exception $e) {
            if ($e->getMessage() === 'User not found') {
                return ApiResponse::error($e->getMessage(), 404);
            }
            if (str_contains($e->getMessage(), 'already approved')) {
                return ApiResponse::error($e->getMessage(), 400);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }

    public function reject(RejectKycRequest $request, string $id): JsonResponse
    {
        try {
            $data = $this->kycService->rejectKyc($id, $request->reason);
            return ApiResponse::success($data, 'KYC rejected');
        } catch (\Exception $e) {
            if ($e->getMessage() === 'User not found') {
                return ApiResponse::error($e->getMessage(), 404);
            }
            if (str_contains($e->getMessage(), 'Cannot reject')) {
                return ApiResponse::error($e->getMessage(), 400);
            }
            return ApiResponse::error($e->getMessage(), 400);
        }
    }
}

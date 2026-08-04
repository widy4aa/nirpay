<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Helpers\ApiResponse;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->auth;

        if (!$user) {
            return ApiResponse::error('Unauthorized', 401);
        }

        $userRole = $user->role ?? $request->authRole ?? 'USER';

        if (!in_array($userRole, $roles)) {
            return ApiResponse::error('Admin access required', 403, 'FORBIDDEN');
        }

        return $next($request);
    }
}

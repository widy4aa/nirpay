<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use App\Models\Admin;
use App\Helpers\ApiResponse;

class JwtAdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        try {
            $token = JWTAuth::parseToken();
            $payload = $token->getPayload();
            
            // Check if this is an admin token
            $adminId = $payload->get('sub');
            $admin = Admin::find($adminId);
            
            if (!$admin) {
                return ApiResponse::error('Admin not found', 401);
            }

            if (!$admin->is_active) {
                return ApiResponse::error('Admin account is inactive', 401);
            }
        } catch (TokenInvalidException $e) {
            return ApiResponse::error('Token is invalid', 401);
        } catch (TokenExpiredException $e) {
            return ApiResponse::error('Token has expired', 401);
        } catch (JWTException $e) {
            return ApiResponse::error('Token not provided', 401);
        }

        $request->auth = $admin;
        $request->authRole = $admin->role;

        return $next($request);
    }
}

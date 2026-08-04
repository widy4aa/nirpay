<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use App\Helpers\ApiResponse;
use App\Models\Admin;
use App\Models\User;

class JwtMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        try {
            $token = JWTAuth::parseToken();
            $payload = $token->getPayload();
        } catch (TokenInvalidException $e) {
            return ApiResponse::error('Token is invalid', 401);
        } catch (TokenExpiredException $e) {
            return ApiResponse::error('Token has expired', 401);
        } catch (JWTException $e) {
            return ApiResponse::error('Token not provided', 401);
        }

        $sub = $payload->get('sub');
        $type = $payload->get('type');

        if (str_contains($type, 'admin')) {
            $user = Admin::find($sub);
            if ($user) {
                $request->authRole = $user->role;
            }
        } else {
            $user = User::find($sub);
            if ($user) {
                $request->authRole = 'USER';
            }
        }

        if (!$user) {
            return ApiResponse::error('User not found', 401);
        }

        if (!$user->is_active) {
            return ApiResponse::error('Account is inactive', 401);
        }

        $request->auth = $user;

        return $next($request);
    }
}

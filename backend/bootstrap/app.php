<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Validation\ValidationException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'jwt' => \App\Http\Middleware\JwtMiddleware::class,
            'role' => \App\Http\Middleware\RoleMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        $exceptions->render(function (AuthenticationException $e) {
            return \App\Helpers\ApiResponse::error('Unauthorized', 401);
        });

        $exceptions->render(function (ValidationException $e) {
            return \App\Helpers\ApiResponse::error(
                $e->getMessage(),
                400,
                'VALIDATION_ERROR',
                $e->errors()
            );
        });

        $exceptions->render(function (NotFoundHttpException $e) {
            return \App\Helpers\ApiResponse::error('Resource not found', 404);
        });

        $exceptions->render(function (AccessDeniedHttpException $e) {
            return \App\Helpers\ApiResponse::error('Access denied', 403);
        });
    })->create();

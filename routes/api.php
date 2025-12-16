<?php
// routes/api.php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group.
|
*/

// ============================================
// PUBLIC ROUTES (No Authentication Required)
// ============================================
Route::prefix('v1')->group(function () {
    
    // Authentication Routes
    Route::post('/register', [AuthController::class, 'register'])
        ->name('auth.register');
    
    Route::post('/login', [AuthController::class, 'login'])
        ->name('auth.login');
});

// ============================================
// PROTECTED ROUTES (Authentication Required)
// ============================================
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    
    // Auth Routes
    Route::post('/logout', [AuthController::class, 'logout'])
        ->name('auth.logout');
    
    Route::get('/profile', [AuthController::class, 'profile'])
        ->name('auth.profile');
    
    // Task Routes
    Route::controller(TaskController::class)->prefix('tasks')->group(function () {
        Route::get('/', 'index')->name('tasks.index');
        Route::post('/', 'store')->name('tasks.store');
        Route::get('/{task}', 'show')->name('tasks.show');
        Route::patch('/{task}', 'update')->name('tasks.update');
        Route::delete('/{task}', 'destroy')->name('tasks.destroy');
    });
    
    // Alternative: Using apiResource
    // Route::apiResource('tasks', TaskController::class);
});
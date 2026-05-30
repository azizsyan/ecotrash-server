<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourierPerformance extends Model
{
    protected $fillable = [
        'courier_id',
        'completed_orders',
        'cancelled_orders',
        'average_rating',
        'performance_score',
    ];

    protected $casts = [
        'average_rating' => 'decimal:2',
        'performance_score' => 'decimal:2',
    ];

    // Performance belongs to courier
    public function courier(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'courier_id'
        );
    }
}
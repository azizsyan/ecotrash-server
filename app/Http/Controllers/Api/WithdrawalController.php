<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WalletTransaction;
use App\Models\Withdrawal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WithdrawalController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | REQUEST WITHDRAWAL
    |--------------------------------------------------------------------------
    */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'bank_name' => 'required|string|max:100',
            'account_name' => 'required|string|max:100',
            'account_number' => 'required|string|max:100',
            'amount' => 'required|numeric|min:1000',
        ]);

        $user = $request->user();

        $wallet = $user->wallet;

        // ======================
// CHECK PENDING WITHDRAWAL
// ======================

        $hasPendingWithdrawal =
            Withdrawal::where(
                'user_id',
                $user->id
            )
                ->where(
                    'status',
                    'PENDING'
                )
                ->exists();

        if ($hasPendingWithdrawal) {

            return response()->json([
                'message' =>
                    'Anda masih memiliki withdrawal pending'
            ], 422);
        }

        if (!$wallet) {
            return response()->json([
                'message' => 'Wallet not found'
            ], 404);
        }

        if ($wallet->balance < $validated['amount']) {
            return response()->json([
                'message' => 'Insufficient balance'
            ], 422);
        }

        DB::beginTransaction();

        try {

            $withdrawal = Withdrawal::create([
                'user_id' => $user->id,
                'bank_name' =>
                    $validated['bank_name'],

                'account_name' =>
                    $validated['account_name'],

                'account_number' =>
                    $validated['account_number'],

                'amount' =>
                    $validated['amount'],

                'status' => 'PENDING',
            ]);

            $wallet->decrement(
                'balance',
                $validated['amount']
            );

            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'DEBIT',
                'amount' =>
                    $validated['amount'],

                'description' =>
                    'Withdrawal request',

                'status' => 'PENDING',
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Withdrawal request created',

                'data' => $withdrawal
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to create withdrawal',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    /*
    |--------------------------------------------------------------------------
    | GET MY WITHDRAWALS
    |--------------------------------------------------------------------------
    */
    public function index(Request $request)
    {
        return response()->json([
            'data' => $request->user()
                ->withdrawals()
                ->latest()
                ->get()
        ]);
    }

    public function approve(string $id)
    {
        DB::beginTransaction();

        try {

            $withdrawal = Withdrawal::with(
                'user.wallet'
            )->findOrFail($id);

            if (
                $withdrawal->status
                !== 'PENDING'
            ) {

                return response()->json([
                    'message' =>
                        'Withdrawal already processed'
                ], 422);
            }

            $withdrawal->update([
                'status' =>
                    'APPROVED',

                'processed_at' =>
                    now(),
            ]);

            WalletTransaction::create([
                'wallet_id' =>
                    $withdrawal
                        ->user
                        ->wallet
                        ->id,

                'type' =>
                    'WITHDRAW',

                'amount' =>
                    $withdrawal
                        ->amount,

                'description' =>
                    'Withdrawal approved',

                'status' =>
                    'SUCCESS',
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Withdrawal approved successfully',

                'data' =>
                    $withdrawal
            ]);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to approve withdrawal',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function reject(
        Request $request,
        string $id
    ) {
        $validated = $request->validate([
            'admin_notes' =>
                'nullable|string|max:255'
        ]);

        DB::beginTransaction();

        try {

            $withdrawal = Withdrawal::with(
                'user.wallet'
            )->findOrFail($id);

            if (
                $withdrawal->status
                !== 'PENDING'
            ) {

                return response()->json([
                    'message' =>
                        'Withdrawal already processed'
                ], 422);
            }

            $wallet =
                $withdrawal
                    ->user
                    ->wallet;

            // REFUND BALANCE
            $wallet->increment(
                'balance',
                $withdrawal->amount
            );

            $withdrawal->update([
                'status' =>
                    'REJECTED',

                'admin_notes' =>
                    $validated[
                        'admin_notes'
                    ] ?? null,

                'processed_at' =>
                    now(),
            ]);

            WalletTransaction::create([
                'wallet_id' =>
                    $wallet->id,

                'type' =>
                    'REFUND',

                'amount' =>
                    $withdrawal->amount,

                'description' =>
                    'Withdrawal rejected refund',

                'status' =>
                    'SUCCESS',
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Withdrawal rejected successfully',

                'data' =>
                    $withdrawal
            ]);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to reject withdrawal',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

}
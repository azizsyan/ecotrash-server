import '../../core/api/api_client.dart';

class WalletService {
  final _client = ApiClient();

  /// GET /api/wallet — saldo + 5 transaksi terakhir + 5 withdrawal terakhir
  Future<Map<String, dynamic>> getWallet() async {
    final res = await _client.dio.get('/wallet');
    return res.data['data'];
  }

  /// GET /api/wallet/transactions — semua transaksi
  Future<List<dynamic>> getTransactions() async {
    final res = await _client.dio.get('/wallet/transactions');
    return res.data['data'] as List;
  }

  /// GET /api/wallet/summary — total income, total withdraw, pending withdraw
  Future<Map<String, dynamic>> getSummary() async {
    final res = await _client.dio.get('/wallet/summary');
    return res.data['data'];
  }

  /// GET /api/withdrawals
  Future<List<dynamic>> getWithdrawals() async {
    final res = await _client.dio.get('/withdrawals');
    return res.data['data'] as List;
  }

  /// POST /api/withdrawals — minta withdrawal
  Future<Map<String, dynamic>> requestWithdrawal({
    required String bankName,
    required String accountName,
    required String accountNumber,
    required double amount,
  }) async {
    final res = await _client.dio.post('/withdrawals', data: {
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'amount': amount,
    });
    return res.data['data'];
  }
}

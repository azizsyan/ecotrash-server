import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _service = WalletService();
  Map<String, dynamic>? _wallet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _wallet = await _service.getWallet();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final balance = _wallet?['balance'] ?? 0;
    final transactions = (_wallet?['recent_transactions'] as List? ?? []);
    final withdrawals  = (_wallet?['recent_withdrawals'] as List? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Dompet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // SALDO CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Dompet', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(fmt.format(balance),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/seller/withdrawal').then((_) => _load()),
                            icon: const Icon(Icons.arrow_upward, size: 18),
                            label: const Text('Tarik Dana'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TRANSAKSI TERAKHIR
                  const Text('Transaksi Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    const Card(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ...transactions.map((t) => _TransactionTile(transaction: t, fmt: fmt)),

                  const SizedBox(height: 24),

                  // WITHDRAWAL TERAKHIR
                  const Text('Riwayat Penarikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (withdrawals.isEmpty)
                    const Card(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada penarikan', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ...withdrawals.map((w) => _WithdrawalTile(withdrawal: w, fmt: fmt)),
                ],
              ),
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final NumberFormat fmt;
  const _TransactionTile({required this.transaction, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final type   = transaction['type'] ?? '';
    final amount = (transaction['amount'] as num).toDouble();
    final isCredit = type == 'CREDIT';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(isCredit ? Icons.add : Icons.remove,
            color: isCredit ? Colors.green : Colors.red),
        ),
        title: Text(transaction['description'] ?? type, style: const TextStyle(fontSize: 14)),
        subtitle: Text(transaction['status'] ?? ''),
        trailing: Text(
          '${isCredit ? '+' : '-'}${fmt.format(amount)}',
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  final Map<String, dynamic> withdrawal;
  final NumberFormat fmt;
  const _WithdrawalTile({required this.withdrawal, required this.fmt});

  Color _color(String status) {
    switch (status) {
      case 'APPROVED': return Colors.green;
      case 'REJECTED': return Colors.red;
      default:         return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = withdrawal['status'] ?? 'PENDING';
    final amount = (withdrawal['amount'] as num).toDouble();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.account_balance, color: Color(0xFF2E7D32)),
        ),
        title: Text('${withdrawal['bank_name']} - ${withdrawal['account_number']}'),
        subtitle: Text(fmt.format(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _color(status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(color: _color(status), fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

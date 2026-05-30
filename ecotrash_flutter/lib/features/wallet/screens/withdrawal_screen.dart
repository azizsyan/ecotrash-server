import 'package:flutter/material.dart';
import '../wallet_service.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});
  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _service      = WalletService();
  final _formKey      = GlobalKey<FormState>();
  final _bankCtrl     = TextEditingController();
  final _accNameCtrl  = TextEditingController();
  final _accNumCtrl   = TextEditingController();
  final _amountCtrl   = TextEditingController();
  bool _submitting    = false;

  @override
  void dispose() {
    _bankCtrl.dispose(); _accNameCtrl.dispose();
    _accNumCtrl.dispose(); _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await _service.requestWithdrawal(
        bankName: _bankCtrl.text.trim(),
        accountName: _accNameCtrl.text.trim(),
        accountNumber: _accNumCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan penarikan berhasil!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Dana', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_bankCtrl,    'Nama Bank',       Icons.account_balance),
              const SizedBox(height: 16),
              _field(_accNameCtrl, 'Nama Rekening',   Icons.person_outline),
              const SizedBox(height: 16),
              _field(_accNumCtrl,  'Nomor Rekening',  Icons.credit_card, type: TextInputType.number),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah (min. Rp 1.000)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 1000) return 'Minimal Rp 1.000';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Ajukan Penarikan', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? '$label wajib diisi' : null,
    );
  }
}

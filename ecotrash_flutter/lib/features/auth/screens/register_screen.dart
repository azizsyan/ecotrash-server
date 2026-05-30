import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      passwordConfirmation: _confCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/seller/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registrasi gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun'), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _field(_nameCtrl,  'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 16),
              _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null),
              const SizedBox(height: 16),
              _field(_phoneCtrl, 'Nomor HP', Icons.phone_outlined, type: TextInputType.phone),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: _dec('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v!.length < 8 ? 'Minimal 8 karakter' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confCtrl,
                obscureText: _obscure,
                decoration: _dec('Konfirmasi Password', Icons.lock_outline),
                validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: _dec(label, icon),
      validator: validator ?? (v) => v!.isEmpty ? '$label wajib diisi' : null,
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.grey),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
    ),
  );
}

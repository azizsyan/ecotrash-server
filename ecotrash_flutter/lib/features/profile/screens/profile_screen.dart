import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _profile = await _service.getProfile();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar + nama
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFF2E7D32),
                          child: Text(
                            (_profile?['name'] ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_profile?['name'] ?? '-',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_profile?['email'] ?? '-', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_profile?['phone'] ?? '-', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Menu
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _menuTile(context, 'Alamat Pickup', Icons.location_on_outlined, '/seller/addresses'),
                      const Divider(height: 1, indent: 56),
                      _menuTile(context, 'Ubah Password', Icons.lock_outline, '/profile/change-password'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keluar?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await auth.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _menuTile(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, route).then((_) => _load()),
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

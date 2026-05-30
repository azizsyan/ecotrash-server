import 'package:flutter/material.dart';
import '../../profile/profile_service.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});
  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _service = AddressService();
  List<dynamic> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _addresses = await _service.getAddresses();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _delete(int id) async {
    await _service.deleteAddress(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _addresses.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada alamat', style: TextStyle(color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (ctx, i) {
                    final a = _addresses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                        title: Row(children: [
                          Text(a['label'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (a['is_default'] == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ]),
                        subtitle: Text(a['address'] ?? '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Hapus alamat?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) _delete(a['id']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final labelCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final latCtrl     = TextEditingController();
    final lngCtrl     = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Alamat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (misal: Rumah)')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat lengkap')),
              TextField(controller: latCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitude')),
              TextField(controller: lngCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitude')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _service.createAddress(
                label: labelCtrl.text, address: addressCtrl.text,
                latitude: double.parse(latCtrl.text), longitude: double.parse(lngCtrl.text),
              );
              if (context.mounted) Navigator.pop(context);
              _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

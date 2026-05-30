import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../profile/profile_service.dart';
import '../order_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _addressService  = AddressService();
  final _categoryService = WasteCategoryService();
  final _orderService    = OrderService();

  List<dynamic> _addresses   = [];
  List<dynamic> _categories  = [];
  int? _selectedAddressId;
  double? _selectedLat, _selectedLng;

  // Items yang ditambahkan: [{ waste_category_id, estimated_weight, name, price_per_kg }]
  final List<Map<String, dynamic>> _items = [];

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _addressService.getAddresses(),
        _categoryService.getCategories(),
      ]);
      _addresses  = results[0];
      _categories = results[1];
      if (_addresses.isNotEmpty) {
        _selectedAddressId = _addresses[0]['id'];
        _selectedLat = double.tryParse(_addresses[0]['latitude'].toString());
        _selectedLng = double.tryParse(_addresses[0]['longitude'].toString());
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (_) => _AddItemDialog(
        categories: _categories,
        onAdd: (item) => setState(() => _items.add(item)),
      ),
    );
  }

  double get _estimatedTotal => _items.fold(0, (sum, item) {
    return sum + (item['price_per_kg'] as double) * (item['estimated_weight'] as double);
  });

  Future<void> _submit() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pickup terlebih dahulu'), backgroundColor: Colors.red));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 jenis sampah'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _submitting = true);
    try {
      await _orderService.createOrder(
        sellerAddressId: _selectedAddressId!,
        latitude: _selectedLat ?? 0,
        longitude: _selectedLng ?? 0,
        items: _items.map((e) => {
          'waste_category_id': e['waste_category_id'],
          'estimated_weight': e['estimated_weight'],
        }).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat pesanan'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ALAMAT PICKUP
                  const Text('Alamat Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_addresses.isEmpty)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_off, color: Colors.red),
                        title: const Text('Belum ada alamat'),
                        subtitle: const Text('Tambahkan alamat dulu di Profil'),
                        trailing: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/seller/addresses'),
                          child: const Text('Tambah'),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: _selectedAddressId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      items: _addresses.map<DropdownMenuItem<int>>((a) => DropdownMenuItem(
                        value: a['id'] as int,
                        child: Text(a['label'] ?? ''),
                      )).toList(),
                      onChanged: (val) {
                        final selected = _addresses.firstWhere((a) => a['id'] == val);
                        setState(() {
                          _selectedAddressId = val;
                          _selectedLat = double.tryParse(selected['latitude'].toString());
                          _selectedLng = double.tryParse(selected['longitude'].toString());
                        });
                      },
                    ),

                  const SizedBox(height: 24),

                  // DAFTAR SAMPAH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Belum ada sampah ditambahkan', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._items.asMap().entries.map((e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.delete_outline, color: Color(0xFF2E7D32)),
                        title: Text(e.value['name']),
                        subtitle: Text('Est. ${e.value['estimated_weight']} kg • ${fmt.format((e.value['price_per_kg'] as double)*(e.value['estimated_weight'] as double))}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _items.removeAt(e.key)),
                        ),
                      ),
                    )),

                  if (_items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: const Color(0xFFE8F5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimasi Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(fmt.format(_estimatedTotal),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],

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
                          : const Text('Buat Pesanan', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<dynamic> categories;
  final Function(Map<String, dynamic>) onAdd;

  const _AddItemDialog({required this.categories, required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  int? _selectedCategoryId;
  final _weightCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selected = widget.categories.firstWhere(
      (c) => c['id'] == _selectedCategoryId, orElse: () => null);

    return AlertDialog(
      title: const Text('Tambah Jenis Sampah'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            hint: const Text('Pilih kategori'),
            value: _selectedCategoryId,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: widget.categories.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(
              value: c['id'] as int,
              child: Text('${c['name']} (Rp${c['price_per_kg']}/kg)'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Estimasi berat (kg)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_selectedCategoryId == null || _weightCtrl.text.isEmpty) return;
            final weight = double.tryParse(_weightCtrl.text);
            if (weight == null || weight <= 0) return;
            widget.onAdd({
              'waste_category_id': _selectedCategoryId,
              'estimated_weight': weight,
              'name': selected['name'],
              'price_per_kg': double.parse(selected['price_per_kg'].toString()),
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}

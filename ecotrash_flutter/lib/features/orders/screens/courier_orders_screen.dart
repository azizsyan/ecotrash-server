import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../order_service.dart';
import '../../profile/profile_service.dart';

class CourierOrdersScreen extends StatefulWidget {
  const CourierOrdersScreen({super.key});
  @override
  State<CourierOrdersScreen> createState() => _CourierOrdersScreenState();
}

class _CourierOrdersScreenState extends State<CourierOrdersScreen>
    with SingleTickerProviderStateMixin {
  final _service  = OrderService();
  final _locSvc   = CourierLocationService();
  late TabController _tabCtrl;

  List<dynamic> _available = [];
  bool _loading    = true;
  bool _isOnline   = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _available = await _service.getAvailableOrders();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggleOnline() async {
    try {
      final online = await _locSvc.toggleOnline();
      setState(() => _isOnline = online);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(online ? 'Status: Online' : 'Status: Offline'),
        backgroundColor: online ? Colors.green : Colors.orange,
      ));
    } catch (_) {}
  }

  Future<void> _accept(int orderId) async {
    try {
      await _service.acceptOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan diterima!'), backgroundColor: Colors.green));
      _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menerima pesanan'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pesanan Kurir', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(_isOnline ? 'Online' : 'Offline',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 4),
              Switch(
                value: _isOnline,
                onChanged: (_) => _toggleOnline(),
                activeColor: Colors.white,
                activeTrackColor: Colors.green.shade300,
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Panduan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // TAB 1: Available orders
          _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : _available.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada pesanan tersedia', style: TextStyle(color: Colors.grey)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _available.length,
                        itemBuilder: (ctx, i) => _AvailableOrderCard(
                          order: _available[i],
                          onAccept: () => _accept(_available[i]['id']),
                        ),
                      ),
                    ),
          // TAB 2: Workflow guide
          const _WorkflowGuide(),
        ],
      ),
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;
  const _AvailableOrderCard({required this.order, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final fmt    = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final items  = (order['items'] as List? ?? []);
    final seller = order['seller'];
    final addr   = order['seller_address'];
    final estTotal = order['estimated_total_price'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 6),
                Text(seller?['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            if (addr != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(addr['address'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13))),
                ],
              ),
            ],
            const Divider(height: 16),
            Text('${items.length} jenis sampah', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ...items.take(3).map((item) {
              final cat = item['waste_category'];
              return Text('• ${cat?['name'] ?? '-'} ~${item['estimated_weight']} kg',
                style: const TextStyle(fontSize: 13));
            }),
            if (items.length > 3)
              Text('  +${items.length - 3} lainnya', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (estTotal != null) ...[
              const SizedBox(height: 8),
              Text('Est. ${fmt.format((estTotal as num).toDouble())}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Terima Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowGuide extends StatelessWidget {
  const _WorkflowGuide();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1. Accept', 'Terima pesanan yang tersedia', Icons.check_circle),
      ('2. Pickup', 'Jemput sampah & foto bukti', Icons.camera_alt),
      ('3. Deliver', 'Antarkan ke TPS', Icons.local_shipping),
      ('4. Complete', 'Input berat aktual tiap item\n→ Seller otomatis dapat pembayaran', Icons.done_all),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Alur Kerja Kurir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Gunakan API endpoint berikut untuk setiap tahap:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ...steps.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(s.$3, color: const Color(0xFF2E7D32)),
            ),
            title: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s.$2),
          ),
        )),
      ],
    );
  }
}

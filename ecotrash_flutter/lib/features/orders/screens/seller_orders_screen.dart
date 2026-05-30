import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../order_service.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _service = OrderService();
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _loading = true; _error = null; });
    try {
      _orders = await _service.getMyOrders();
    } catch (e) {
      _error = 'Gagal memuat pesanan';
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pesanan Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/seller/orders/create').then((_) => _loadOrders()),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Pesanan', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  TextButton(onPressed: _loadOrders, child: const Text('Coba lagi')),
                ]))
              : _orders.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.recycling, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada pesanan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (ctx, i) => _OrderCard(order: _orders[i], onCancelled: _loadOrders),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onCancelled;

  const _OrderCard({required this.order, required this.onCancelled});

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':   return Colors.orange;
      case 'ACCEPTED':  return Colors.blue;
      case 'PICKED_UP': return Colors.purple;
      case 'DELIVERED': return Colors.cyan;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':   return 'Menunggu Kurir';
      case 'ACCEPTED':  return 'Diterima Kurir';
      case 'PICKED_UP': return 'Dijemput';
      case 'DELIVERED': return 'Dikirim ke TPS';
      case 'COMPLETED': return 'Selesai';
      case 'CANCELLED': return 'Dibatalkan';
      default:          return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status    = order['status'] as String;
    final orderCode = order['order_code'] ?? '-';
    final items     = (order['items'] as List? ?? []);
    final totalEst  = order['estimated_total_price'];
    final totalReal = order['total_price'];
    final createdAt = DateTime.tryParse(order['created_at'] ?? '');
    final fmt       = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel(status),
                    style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(DateFormat('d MMM yyyy, HH:mm').format(createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
            const Divider(height: 16),
            Text('${items.length} jenis sampah', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            if (totalReal != null)
              Text(fmt.format(totalReal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32)))
            else if (totalEst != null)
              Text('Est. ${fmt.format(totalEst)}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            if (status == 'PENDING') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Batalkan Pesanan?'),
                        content: const Text('Pesanan yang sudah dibatalkan tidak bisa dikembalikan.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await OrderService().cancelOrder(order['id']);
                      onCancelled();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Batalkan'),
                ),
              ),
            ],
            if (status == 'COMPLETED') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/seller/reviews/create', arguments: order['id']),
                  icon: const Icon(Icons.star, size: 16),
                  label: const Text('Beri Ulasan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

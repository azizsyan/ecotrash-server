import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../profile/profile_service.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});
  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final _service = ReviewService();
  List<dynamic> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _reviews = await _service.getMyReceivedReviews();
    } catch (_) {}
    setState(() => _loading = false);
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ulasan Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _reviews.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada ulasan', style: TextStyle(color: Colors.grey)),
                ]))
              : Column(
                  children: [
                    // Rating summary
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_avgRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < _avgRating.round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber, size: 20,
                                )),
                              ),
                              Text('${_reviews.length} ulasan',
                                style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _reviews.length,
                        itemBuilder: (ctx, i) {
                          final r = _reviews[i];
                          final seller = r['seller'];
                          final createdAt = DateTime.tryParse(r['created_at'] ?? '');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFFE8F5E9),
                                        child: Text((seller?['name'] ?? '?')[0],
                                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(seller?['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(5, (si) => Icon(
                                          si < (r['rating'] as int) ? Icons.star : Icons.star_border,
                                          color: Colors.amber, size: 16,
                                        )),
                                      ),
                                    ],
                                  ),
                                  if (r['comment'] != null && r['comment'] != '') ...[
                                    const SizedBox(height: 8),
                                    Text(r['comment'], style: const TextStyle(color: Colors.grey)),
                                  ],
                                  if (createdAt != null)
                                    Text(DateFormat('d MMM yyyy').format(createdAt),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

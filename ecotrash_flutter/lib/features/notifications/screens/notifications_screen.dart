import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<dynamic> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _notifs = await _service.getNotifications();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => n['is_read'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]
        ]),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Baca Semua', style: TextStyle(color: Colors.white)),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _notifs.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada notifikasi', style: TextStyle(color: Colors.grey)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notifs.length,
                    itemBuilder: (ctx, i) {
                      final n = _notifs[i];
                      final isRead = n['is_read'] == true;
                      final createdAt = DateTime.tryParse(n['created_at'] ?? '');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead ? Colors.white : const Color(0xFFE8F5E9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () async {
                            if (!isRead) {
                              await _service.markAsRead(n['id']);
                              _load();
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: isRead ? Colors.grey.shade100 : const Color(0xFFE8F5E9),
                            child: Icon(
                              n['type'] == 'ORDER' ? Icons.recycling : Icons.notifications,
                              color: isRead ? Colors.grey : const Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(n['title'] ?? '', style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n['message'] ?? '', style: const TextStyle(fontSize: 13)),
                              if (createdAt != null)
                                Text(DateFormat('d MMM, HH:mm').format(createdAt),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          trailing: isRead ? null : Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32), shape: BoxShape.circle),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

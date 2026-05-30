import 'package:flutter/material.dart';
import '../../orders/screens/courier_orders_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../reviews/screens/my_reviews_screen.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});
  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CourierOrdersScreen(),
    MyReviewsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ulasan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

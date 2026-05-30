import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/seller_home_screen.dart';
import 'features/courier/screens/courier_home_screen.dart';
import 'features/orders/screens/create_order_screen.dart';
import 'features/wallet/screens/withdrawal_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EcoTrashApp(),
    ),
  );
}

class EcoTrashApp extends StatelessWidget {
  const EcoTrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login':                  (_) => const LoginScreen(),
        '/register':               (_) => const RegisterScreen(),
        '/seller/home':            (_) => const SellerHomeScreen(),
        '/courier/home':           (_) => const CourierHomeScreen(),
        '/seller/orders/create':   (_) => const CreateOrderScreen(),
        '/seller/withdrawal':      (_) => const WithdrawalScreen(),
      },
    );
  }
}

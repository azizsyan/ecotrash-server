class AppConstants {
  // Ganti baseUrl sesuai environment:
  // - Emulator Android  : http://10.0.2.2:8000/api
  // - Device fisik      : http://<IP_LAN_kamu>:8000/api
  // - Production        : https://yourdomain.com/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Role IDs (sync dengan tabel roles di backend)
  static const int roleSuperAdmin = 1;
  static const int roleAdmin      = 2;
  static const int roleSeller     = 3;
  static const int roleCourier    = 4;

  static const String slugSeller  = 'seller';
  static const String slugCourier = 'courier';
}

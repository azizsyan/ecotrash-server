# EcoTrash Flutter App

Flutter client untuk backend EcoTrash (Laravel + Sanctum).

---

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Konfigurasi Base URL

Edit file `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
//                                  ^^^^^^^^^^^^^^^^^
//  - Emulator Android  : http://10.0.2.2:8000/api
//  - Device fisik      : http://<IP_LAN_komputer>:8000/api
//  - Produksi          : https://yourdomain.com/api
```

### 3. Jalankan backend Laravel

```bash
# Di folder ecotrash-server
php artisan serve           # default port 8000
php artisan storage:link    # penting untuk foto pickup!
```

### 4. Jalankan Flutter

```bash
flutter run
```

---

## Struktur Folder

```
lib/
├── core/
│   ├── api/
│   │   └── api_client.dart          # Dio + token interceptor
│   ├── constants/
│   │   └── app_constants.dart       # BASE_URL, role IDs
│   └── providers/
│       └── auth_provider.dart       # Login/logout state
│
└── features/
    ├── auth/
    │   ├── auth_service.dart        # login(), register(), logout()
    │   ├── models/user_model.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       ├── seller_home_screen.dart   (bottom nav seller)
    │       └── courier_home_screen.dart  (di folder courier/)
    │
    ├── orders/
    │   ├── order_service.dart       # semua API orders
    │   └── screens/
    │       ├── seller_orders_screen.dart
    │       ├── create_order_screen.dart
    │       └── courier_orders_screen.dart
    │
    ├── wallet/
    │   ├── wallet_service.dart
    │   └── screens/
    │       ├── wallet_screen.dart
    │       └── withdrawal_screen.dart
    │
    ├── notifications/
    │   ├── notification_service.dart
    │   └── screens/notifications_screen.dart
    │
    ├── profile/
    │   ├── profile_service.dart     # Profile + Address + Review + Courier location
    │   └── screens/profile_screen.dart
    │
    ├── address/
    │   └── screens/address_list_screen.dart
    │
    ├── reviews/
    │   └── screens/my_reviews_screen.dart
    │
    └── courier/
        └── screens/courier_home_screen.dart
```

---

## Mapping API → Service

| Backend Endpoint | Flutter Service | Method |
|---|---|---|
| POST `/login` | `AuthService.login()` | - |
| POST `/register` | `AuthService.register()` | - |
| POST `/logout` | `AuthService.logout()` | - |
| GET `/profile` | `ProfileService.getProfile()` | - |
| PATCH `/profile` | `ProfileService.updateProfile()` | - |
| PATCH `/profile/password` | `ProfileService.changePassword()` | - |
| GET `/waste-categories` | `WasteCategoryService.getCategories()` | - |
| GET `/wallet` | `WalletService.getWallet()` | Seller |
| GET `/wallet/transactions` | `WalletService.getTransactions()` | Seller |
| GET `/wallet/summary` | `WalletService.getSummary()` | Seller |
| POST `/withdrawals` | `WalletService.requestWithdrawal()` | Seller |
| GET `/orders` | `OrderService.getMyOrders()` | Seller |
| POST `/orders` | `OrderService.createOrder()` | Seller |
| GET `/orders/:id` | `OrderService.getOrderDetail()` | Seller |
| PATCH `/orders/:id/cancel` | `OrderService.cancelOrder()` | Seller |
| GET `/seller-addresses` | `AddressService.getAddresses()` | Seller |
| POST `/seller-addresses` | `AddressService.createAddress()` | Seller |
| GET `/courier/orders/available` | `OrderService.getAvailableOrders()` | Courier |
| PATCH `/orders/:id/accept` | `OrderService.acceptOrder()` | Courier |
| POST `/orders/:id/pickup` | `OrderService.pickupOrder()` | Courier |
| PATCH `/orders/:id/deliver` | `OrderService.deliverOrder()` | Courier |
| PATCH `/orders/:id/complete` | `OrderService.completeOrder()` | Courier |
| PATCH `/courier/location` | `CourierLocationService.updateLocation()` | Courier |
| PATCH `/courier/toggle-online` | `CourierLocationService.toggleOnline()` | Courier |
| GET `/notifications` | `NotificationService.getNotifications()` | All |
| PATCH `/notifications/read-all` | `NotificationService.markAllAsRead()` | All |
| POST `/reviews` | `ReviewService.createReview()` | Seller |
| GET `/reviews/my-received` | `ReviewService.getMyReceivedReviews()` | Courier |

---

## Cara kerja Auth

1. User login → backend return `token` + `user.role`
2. Token disimpan di `FlutterSecureStorage` (encrypted)
3. `ApiClient` otomatis inject `Authorization: Bearer <token>` di setiap request via Dio interceptor
4. Route diarahkan berdasarkan role: `seller` → `/seller/home`, `courier` → `/courier/home`

---

## Cara kerja Error Handling

Semua service menggunakan Dio. Error bisa di-catch di UI layer:

```dart
try {
  final orders = await orderService.getMyOrders();
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // token expired, redirect ke login
  } else if (e.response?.statusCode == 422) {
    // validasi gagal, tampilkan e.response?.data['message']
  }
}
```

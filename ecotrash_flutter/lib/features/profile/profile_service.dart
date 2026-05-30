import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

// ============================================================
// PROFILE
// ============================================================
class ProfileService {
  final _client = ApiClient();

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _client.dio.get('/profile');
    return res.data['data'];
  }

  /// PATCH /api/profile — update nama/email/phone/foto
  /// [photoPath] opsional, path file gambar lokal
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? photoPath,
    // Courier fields
    String? vehicleType,
    String? vehiclePlate,
    String? address,
    String? city,
    String? province,
  }) async {
    final data = FormData.fromMap({
      'name': name, 'email': email, 'phone': phone,
      if (photoPath != null)
        'profile_photo': await MultipartFile.fromFile(photoPath, filename: 'photo.jpg'),
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
    });
    // PATCH tidak bisa multipart, pakai POST + _method override jika perlu.
    // Backend Laravel menerima PATCH dengan multipart via _method=PATCH.
    data.fields.add(MapEntry('_method', 'PATCH'));
    final res = await _client.dio.post('/profile', data: data);
    return res.data['data'];
  }

  /// PATCH /api/profile/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _client.dio.patch('/profile/password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
  }
}

// ============================================================
// SELLER ADDRESS
// ============================================================
class AddressService {
  final _client = ApiClient();

  Future<List<dynamic>> getAddresses() async {
    final res = await _client.dio.get('/seller-addresses');
    return res.data['data'] as List;
  }

  Future<Map<String, dynamic>> createAddress({
    required String label, required String address,
    required double latitude, required double longitude, bool isDefault = false,
  }) async {
    final res = await _client.dio.post('/seller-addresses', data: {
      'label': label, 'address': address,
      'latitude': latitude, 'longitude': longitude, 'is_default': isDefault,
    });
    return res.data['data'];
  }

  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/seller-addresses/$id', data: data);
    return res.data['data'];
  }

  Future<void> deleteAddress(int id) async {
    await _client.dio.delete('/seller-addresses/$id');
  }
}

// ============================================================
// WASTE CATEGORY
// ============================================================
class WasteCategoryService {
  final _client = ApiClient();

  Future<List<dynamic>> getCategories() async {
    final res = await _client.dio.get('/waste-categories');
    return res.data['data'] as List;
  }
}

// ============================================================
// REVIEW
// ============================================================
class ReviewService {
  final _client = ApiClient();

  /// POST /api/reviews — seller beri ulasan ke kurir
  Future<Map<String, dynamic>> createReview({
    required int orderId, required int rating, String? comment,
  }) async {
    final res = await _client.dio.post('/reviews', data: {
      'order_id': orderId, 'rating': rating,
      if (comment != null) 'comment': comment,
    });
    return res.data['data'];
  }

  /// GET /api/reviews/my-received — kurir lihat review yang diterima
  Future<List<dynamic>> getMyReceivedReviews() async {
    final res = await _client.dio.get('/reviews/my-received');
    return res.data['data'] as List;
  }
}

// ============================================================
// COURIER LOCATION
// ============================================================
class CourierLocationService {
  final _client = ApiClient();

  /// PATCH /api/courier/location
  Future<void> updateLocation(double lat, double lng) async {
    await _client.dio.patch('/courier/location', data: {
      'latitude': lat, 'longitude': lng,
    });
  }

  /// PATCH /api/courier/toggle-online
  Future<bool> toggleOnline() async {
    final res = await _client.dio.patch('/courier/toggle-online');
    return res.data['data']['is_online'] as bool;
  }
}

import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class OrderService {
  final _client = ApiClient();

  // =====================================================
  // SELLER
  // =====================================================

  /// GET /api/orders — daftar semua order milik seller
  Future<List<dynamic>> getMyOrders() async {
    final res = await _client.dio.get('/orders');
    return res.data['data'] as List;
  }

  /// GET /api/orders/:id — detail order
  Future<Map<String, dynamic>> getOrderDetail(int id) async {
    final res = await _client.dio.get('/orders/$id');
    return res.data['data'];
  }

  /// POST /api/orders — buat order baru
  /// items = [{ waste_category_id: int, estimated_weight: double }]
  Future<Map<String, dynamic>> createOrder({
    required int sellerAddressId,
    required double latitude,
    required double longitude,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final res = await _client.dio.post('/orders', data: {
      'seller_address_id': sellerAddressId,
      'latitude': latitude,
      'longitude': longitude,
      'items': items,
      if (notes != null) 'notes': notes,
    });
    return res.data['data'];
  }

  /// PATCH /api/orders/:id/cancel
  Future<void> cancelOrder(int id, {String? reason}) async {
    await _client.dio.patch('/orders/$id/cancel', data: {
      if (reason != null) 'cancel_reason': reason,
    });
  }

  // =====================================================
  // COURIER
  // =====================================================

  /// GET /api/courier/orders/available
  Future<List<dynamic>> getAvailableOrders() async {
    final res = await _client.dio.get('/courier/orders/available');
    return res.data['data'] as List;
  }

  /// PATCH /api/orders/:id/accept
  Future<void> acceptOrder(int id) async {
    await _client.dio.patch('/orders/$id/accept');
  }

  /// POST /api/orders/:id/pickup — upload foto pickup
  Future<void> pickupOrder(int id, {required String photoPath, String? notes}) async {
    final formData = FormData.fromMap({
      'pickup_photo': await MultipartFile.fromFile(photoPath, filename: 'pickup.jpg'),
      if (notes != null) 'pickup_notes': notes,
    });
    await _client.dio.post('/orders/$id/pickup', data: formData);
  }

  /// PATCH /api/orders/:id/deliver
  Future<void> deliverOrder(int id) async {
    await _client.dio.patch('/orders/$id/deliver');
  }

  /// PATCH /api/orders/:id/complete — input berat aktual tiap item
  /// items = [{ order_item_id: int, actual_weight: double }]
  Future<Map<String, dynamic>> completeOrder(int id, List<Map<String, dynamic>> items) async {
    final res = await _client.dio.patch('/orders/$id/complete', data: {'items': items});
    return res.data['data'];
  }

  /// GET /api/orders/:id/map — koordinat seller & kurir
  Future<Map<String, dynamic>> getOrderMap(int id) async {
    final res = await _client.dio.get('/orders/$id/map');
    return res.data['data'];
  }
}

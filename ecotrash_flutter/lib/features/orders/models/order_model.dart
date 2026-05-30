class WasteCategoryModel {
  final int id;
  final String name;
  final double pricePerKg;

  WasteCategoryModel({required this.id, required this.name, required this.pricePerKg});

  factory WasteCategoryModel.fromJson(Map<String, dynamic> j) => WasteCategoryModel(
    id: j['id'], name: j['name'],
    pricePerKg: (j['price_per_kg'] as num).toDouble(),
  );
}

class OrderItemModel {
  final int id;
  final WasteCategoryModel? wasteCategory;
  final double estimatedWeight;
  final double? actualWeight;
  final double? subtotal;

  OrderItemModel({
    required this.id, this.wasteCategory,
    required this.estimatedWeight, this.actualWeight, this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
    id: j['id'],
    wasteCategory: j['waste_category'] != null
        ? WasteCategoryModel.fromJson(j['waste_category'])
        : null,
    estimatedWeight: (j['estimated_weight'] as num).toDouble(),
    actualWeight: j['actual_weight'] != null ? (j['actual_weight'] as num).toDouble() : null,
    subtotal: j['subtotal'] != null ? (j['subtotal'] as num).toDouble() : null,
  );
}

class OrderModel {
  final int id;
  final String orderCode;
  final String status;
  final double? estimatedTotalPrice;
  final double? totalPrice;
  final double? estimatedTotalWeight;
  final double? actualTotalWeight;
  final List<OrderItemModel> items;
  final String? cancelReason;
  final DateTime createdAt;
  final String? pickupPhotoUrl;

  OrderModel({
    required this.id, required this.orderCode, required this.status,
    this.estimatedTotalPrice, this.totalPrice, this.estimatedTotalWeight,
    this.actualTotalWeight, required this.items, this.cancelReason,
    required this.createdAt, this.pickupPhotoUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id'],
    orderCode: j['order_code'] ?? '',
    status: j['status'] ?? 'PENDING',
    estimatedTotalPrice: j['estimated_total_price'] != null
        ? (j['estimated_total_price'] as num).toDouble() : null,
    totalPrice: j['total_price'] != null ? (j['total_price'] as num).toDouble() : null,
    estimatedTotalWeight: j['estimated_total_weight'] != null
        ? (j['estimated_total_weight'] as num).toDouble() : null,
    actualTotalWeight: j['actual_total_weight'] != null
        ? (j['actual_total_weight'] as num).toDouble() : null,
    items: (j['items'] as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList(),
    cancelReason: j['cancel_reason'],
    createdAt: DateTime.parse(j['created_at']),
    pickupPhotoUrl: j['pickup_photo_url'],
  );

  // Status display helpers
  String get statusLabel {
    switch (status) {
      case 'PENDING':    return 'Menunggu Kurir';
      case 'ACCEPTED':   return 'Diterima Kurir';
      case 'PICKED_UP':  return 'Sampah Dijemput';
      case 'DELIVERED':  return 'Dikirim ke TPS';
      case 'COMPLETED':  return 'Selesai';
      case 'CANCELLED':  return 'Dibatalkan';
      default:           return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'PENDING':    return const Color(0xFFFF9800);
      case 'ACCEPTED':   return const Color(0xFF2196F3);
      case 'PICKED_UP':  return const Color(0xFF9C27B0);
      case 'DELIVERED':  return const Color(0xFF00BCD4);
      case 'COMPLETED':  return const Color(0xFF4CAF50);
      case 'CANCELLED':  return const Color(0xFFF44336);
      default:           return const Color(0xFF9E9E9E);
    }
  }
}

// ignore: avoid_classes_with_only_static_members
class Color {
  final int value;
  const Color(this.value);
}

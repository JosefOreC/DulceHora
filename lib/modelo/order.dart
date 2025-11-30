import 'customization.dart';

/// Order model representing a customer's cake/pastry order
class Order {
  final String id;
  final String userId;
  final String productId;
  final String productName; // Denormalized for easier display
  final Customization customization;
  final DateTime deliveryDate;
  final String pickupTime; // e.g., "10:00 AM - 11:00 AM"
  final DeliveryType deliveryType;
  final double depositAmount;
  final double totalAmount;
  final OrderStatus status;
  final String? assignedDeliveryPerson;
  final String? deliveryAddress; // Required if deliveryType is delivery
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.customization,
    required this.deliveryDate,
    required this.pickupTime,
    required this.deliveryType,
    required this.depositAmount,
    required this.totalAmount,
    required this.status,
    this.assignedDeliveryPerson,
    this.deliveryAddress,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'customization': customization.toJson(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'pickupTime': pickupTime,
      'deliveryType': deliveryType.name,
      'depositAmount': depositAmount,
      'totalAmount': totalAmount,
      'status': status.name,
      'assignedDeliveryPerson': assignedDeliveryPerson,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (Firestore)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      customization: Customization.fromJson(
        json['customization'] as Map<String, dynamic>,
      ),
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      pickupTime: json['pickupTime'] as String,
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == json['deliveryType'],
      ),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      assignedDeliveryPerson: json['assignedDeliveryPerson'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  Order copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    Customization? customization,
    DateTime? deliveryDate,
    String? pickupTime,
    DeliveryType? deliveryType,
    double? depositAmount,
    double? totalAmount,
    OrderStatus? status,
    String? assignedDeliveryPerson,
    String? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customization: customization ?? this.customization,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryType: deliveryType ?? this.deliveryType,
      depositAmount: depositAmount ?? this.depositAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      assignedDeliveryPerson:
          assignedDeliveryPerson ?? this.assignedDeliveryPerson,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate remaining balance
  double get remainingBalance => totalAmount - depositAmount;

  /// Check if order is paid in full
  bool get isPaidInFull => depositAmount >= totalAmount;
}

/// Delivery type options
enum DeliveryType {
  pickup, // Customer picks up at store
  delivery, // Delivery to customer address
}

/// Extension for delivery type display names
extension DeliveryTypeExtension on DeliveryType {
  String get displayName {
    switch (this) {
      case DeliveryType.pickup:
        return 'Recoger en tienda';
      case DeliveryType.delivery:
        return 'Entrega a domicilio';
    }
  }
}

/// Order status workflow
enum OrderStatus {
  pending, // Order placed, payment received
  confirmed, // Order confirmed by staff
  inProduction, // Being prepared by pastry chef
  ready, // Ready for pickup/delivery
  outForDelivery, // Out for delivery (if delivery type)
  completed, // Order completed
  cancelled, // Order cancelled
}

/// Extension for order status display names
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.inProduction:
        return 'En producción';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.outForDelivery:
        return 'En camino';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}

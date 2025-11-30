import 'product.dart';
import 'customization.dart';

/// Represents an item in the shopping cart
class CartItem {
  final String id;
  final Product product;
  final String selectedSize;
  final String selectedFlavor;
  final int quantity;
  final Customization? customization;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedFlavor,
    this.quantity = 1,
    this.customization,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Calculate total price for this cart item
  double get totalPrice {
    final basePrice = product.calculatePrice(selectedSize, selectedFlavor);
    final customizationPrice = customization?.calculatePrice() ?? 0.0;
    return (basePrice + customizationPrice) * quantity;
  }

  /// Create a copy with updated fields
  CartItem copyWith({
    String? id,
    Product? product,
    String? selectedSize,
    String? selectedFlavor,
    int? quantity,
    Customization? customization,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedFlavor: selectedFlavor ?? this.selectedFlavor,
      quantity: quantity ?? this.quantity,
      customization: customization ?? this.customization,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedSize': selectedSize,
      'selectedFlavor': selectedFlavor,
      'quantity': quantity,
      'customization': customization?.toJson(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      selectedSize: json['selectedSize'] as String,
      selectedFlavor: json['selectedFlavor'] as String,
      quantity: json['quantity'] as int,
      customization: json['customization'] != null
          ? Customization.fromJson(
              json['customization'] as Map<String, dynamic>,
            )
          : null,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

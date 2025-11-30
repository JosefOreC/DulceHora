import 'package:flutter/foundation.dart';
import '../../modelo/cart_item.dart';
import '../../modelo/product.dart';
import '../../modelo/customization.dart';

/// Provider for managing shopping cart state
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.13; // 13% tax

  double get total => subtotal + tax;

  bool get isEmpty => _items.isEmpty;

  /// Add item to cart
  void addItem({
    required Product product,
    required String selectedSize,
    required String selectedFlavor,
    int quantity = 1,
    Customization? customization,
  }) {
    // Check if similar item already exists
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedFlavor == selectedFlavor &&
          _customizationsMatch(item.customization, customization),
    );

    if (existingIndex >= 0) {
      // Update quantity of existing item
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          selectedSize: selectedSize,
          selectedFlavor: selectedFlavor,
          quantity: quantity,
          customization: customization,
        ),
      );
    }

    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clear entire cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Check if two customizations are the same
  bool _customizationsMatch(Customization? c1, Customization? c2) {
    if (c1 == null && c2 == null) return true;
    if (c1 == null || c2 == null) return false;
    return c1.customText == c2.customText &&
        c1.adornmentType == c2.adornmentType &&
        c1.specialInstructions == c2.specialInstructions;
  }
}

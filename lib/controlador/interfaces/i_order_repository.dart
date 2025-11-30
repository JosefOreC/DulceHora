import 'package:dulcehora/modelo/order.dart';

/// Interface for order repository operations
/// This abstraction allows switching database implementations via dependency injection
abstract class IOrderRepository {
  /// Create a new order
  Future<String> createOrder(Order order);

  /// Get order by ID
  Future<Order?> getOrderById(String orderId);

  /// Get all orders for a specific user
  Future<List<Order>> getOrdersByUser(String userId);

  /// Get orders by date range (for production calendar)
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status);

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);

  /// Assign delivery person to an order
  Future<void> assignDeliveryPerson(String orderId, String deliveryPersonId);

  /// Update entire order
  Future<void> updateOrder(Order order);

  /// Get orders for a specific delivery date (production planning)
  Future<List<Order>> getOrdersByDeliveryDate(DateTime date);

  /// Get demand statistics for date range (for reports)
  Future<Map<String, dynamic>> getDemandStatistics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Cancel an order
  Future<void> cancelOrder(String orderId);
}

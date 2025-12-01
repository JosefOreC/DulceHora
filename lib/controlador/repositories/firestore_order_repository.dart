import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dulcehora/modelo/order.dart';
import 'package:dulcehora/controlador/interfaces/i_order_repository.dart';

/// Firestore implementation of IOrderRepository
class FirestoreOrderRepository implements IOrderRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'orders';

  FirestoreOrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection(_collectionName);

  @override
  Future<String> createOrder(Order order) async {
    try {
      // Create document and get Firestore-generated ID
      final docRef = await _collection.add(order.toJson());

      // Update the document with the correct ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _collection.doc(orderId).get();

      if (!doc.exists) {
        return null;
      }

      return Order.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders by user: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _collection
          .where(
            'deliveryDate',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('deliveryDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('deliveryDate')
          .get();

      return snapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders by date range: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: status.name)
          .orderBy('deliveryDate')
          .get();

      return snapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders by status: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _collection.doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  @override
  Future<void> assignDeliveryPerson(
    String orderId,
    String deliveryPersonId,
  ) async {
    try {
      await _collection.doc(orderId).update({
        'assignedDeliveryPerson': deliveryPersonId,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error assigning delivery person: $e');
    }
  }

  @override
  Future<void> updateOrder(Order order) async {
    try {
      final updatedOrder = order.copyWith(updatedAt: DateTime.now());
      await _collection.doc(order.id).update(updatedOrder.toJson());
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByDeliveryDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _collection
          .where(
            'deliveryDate',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where(
            'deliveryDate',
            isLessThanOrEqualTo: endOfDay.toIso8601String(),
          )
          .orderBy('deliveryDate')
          .get();

      return snapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders by delivery date: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDemandStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final orders = await getOrdersByDateRange(startDate, endDate);

      // Calculate statistics
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // Group by date
      final ordersByDate = <String, int>{};
      for (final order in orders) {
        final dateKey =
            '${order.deliveryDate.year}-${order.deliveryDate.month}-${order.deliveryDate.day}';
        ordersByDate[dateKey] = (ordersByDate[dateKey] ?? 0) + 1;
      }

      // Find peak demand day
      String? peakDay;
      int maxOrders = 0;
      ordersByDate.forEach((date, count) {
        if (count > maxOrders) {
          maxOrders = count;
          peakDay = date;
        }
      });

      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        'ordersByDate': ordersByDate,
        'peakDemandDay': peakDay,
        'peakDemandCount': maxOrders,
      };
    } catch (e) {
      throw Exception('Error calculating demand statistics: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }
}

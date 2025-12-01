import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../modelo/order.dart' as model;
import '../../modelo/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/employee_drawer.dart';
import 'receipt_screen.dart';

/// Detailed view of a single order
class OrderDetailScreen extends StatelessWidget {
  final model.Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case model.OrderStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case model.OrderStatus.confirmed:
        statusColor = AppColors.info;
        statusIcon = Icons.check_circle_outline;
        break;
      case model.OrderStatus.inProduction:
        statusColor = AppColors.primary;
        statusIcon = Icons.construction;
        break;
      case model.OrderStatus.ready:
        statusColor = AppColors.success;
        statusIcon = Icons.done_all;
        break;
      case model.OrderStatus.outForDelivery:
        statusColor = AppColors.primary;
        statusIcon = Icons.local_shipping;
        break;
      case model.OrderStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case model.OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isEmployee =
        authProvider.currentUser?.role != null &&
        authProvider.currentUser!.role != UserRole.customer;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Pedido')),
      drawer: isEmployee ? const EmployeeDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.8), statusColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    order.status.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pedido #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info Card
                  _buildCard(
                    title: 'Producto',
                    icon: Icons.cake,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.customization.customText != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Texto',
                            order.customization.customText!,
                          ),
                        ],
                        if (order.customization.adornmentType != null) ...[
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            'Adorno',
                            order.customization.adornmentType!,
                          ),
                        ],
                        if (order.customization.specialInstructions !=
                            null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Instrucciones especiales:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(order.customization.specialInstructions!),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Delivery Info Card
                  _buildCard(
                    title: 'Información de Entrega',
                    icon: Icons.local_shipping,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Fecha',
                          dateFormat.format(order.deliveryDate),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Horario', order.pickupTime),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Tipo',
                          order.deliveryType == model.DeliveryType.delivery
                              ? 'Delivery'
                              : 'Recojo en tienda',
                        ),
                        if (order.deliveryAddress != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Dirección:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(order.deliveryAddress!),
                        ],
                        if (order.assignedDeliveryPerson != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Repartidor',
                            order.assignedDeliveryPerson!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment Info Card
                  _buildCard(
                    title: 'Resumen de Pago',
                    icon: Icons.payment,
                    child: Column(
                      children: [
                        _buildPaymentRow(
                          'Subtotal',
                          currencyFormat.format(order.totalAmount / 1.18),
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentRow(
                          'IGV (18%)',
                          currencyFormat.format(
                            order.totalAmount - (order.totalAmount / 1.18),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildPaymentRow(
                          'Total',
                          currencyFormat.format(order.totalAmount),
                          isTotal: true,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentRow(
                          'Señal pagada (50%)',
                          currencyFormat.format(order.depositAmount),
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentRow(
                          'Saldo pendiente',
                          currencyFormat.format(
                            order.totalAmount - order.depositAmount,
                          ),
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Order Notes
                  if (order.notes != null) ...[
                    _buildCard(
                      title: 'Notas del Pedido',
                      icon: Icons.note,
                      child: Text(order.notes!),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // View Receipt Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReceiptScreen(
                              orderIds: [order.id],
                              deliveryDate: order.deliveryDate,
                              pickupTime: order.pickupTime,
                              deliveryType: order.deliveryType,
                              subtotal: order.totalAmount / 1.18,
                              igv:
                                  order.totalAmount -
                                  (order.totalAmount / 1.18),
                              totalAmount: order.totalAmount,
                              depositAmount: order.depositAmount,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Ver Boleta'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isTotal ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/service_locator.dart';
import '../../../modelo/order.dart' as model;
import '../../../modelo/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/employee_drawer.dart';

/// Detailed order screen for employees with role-based actions
class EmployeeOrderDetailScreen extends StatefulWidget {
  final model.Order order;
  final bool showStatusActions;

  const EmployeeOrderDetailScreen({
    super.key,
    required this.order,
    this.showStatusActions = true,
  });

  @override
  State<EmployeeOrderDetailScreen> createState() =>
      _EmployeeOrderDetailScreenState();
}

class _EmployeeOrderDetailScreenState extends State<EmployeeOrderDetailScreen> {
  late model.Order _order;
  bool _isUpdating = false;
  final TextEditingController _deliveryPersonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  void dispose() {
    _deliveryPersonController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(
    model.OrderStatus newStatus, {
    String? deliveryPerson,
  }) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await ServiceLocator().orderRepository.updateOrderStatus(
        _order.id,
        newStatus,
      );

      // If delivery person is assigned, update it
      if (deliveryPerson != null) {
        await ServiceLocator().orderRepository.updateOrder(
          _order.copyWith(
            status: newStatus,
            assignedDeliveryPerson: deliveryPerson,
          ),
        );
      }

      setState(() {
        _order = _order.copyWith(
          status: newStatus,
          assignedDeliveryPerson:
              deliveryPerson ?? _order.assignedDeliveryPerson,
        );
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a ${newStatus.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (_order.status) {
      case model.OrderStatus.pending:
        return AppColors.warning;
      case model.OrderStatus.confirmed:
        return AppColors.info;
      case model.OrderStatus.inProduction:
        return AppColors.primary;
      case model.OrderStatus.ready:
        return AppColors.success;
      case model.OrderStatus.outForDelivery:
        return AppColors.primary;
      case model.OrderStatus.completed:
        return AppColors.success;
      case model.OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (_order.status) {
      case model.OrderStatus.pending:
        return Icons.hourglass_empty;
      case model.OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case model.OrderStatus.inProduction:
        return Icons.construction;
      case model.OrderStatus.ready:
        return Icons.done_all;
      case model.OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case model.OrderStatus.completed:
        return Icons.check_circle;
      case model.OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      drawer: const EmployeeDrawer(),
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icon(_getStatusIcon(), size: 64, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          _order.status.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido #${_order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product Information
                  _buildSection('Información del Producto', Icons.cake, [
                    _buildInfoRow('Producto', _order.productName),
                    _buildInfoRow('Tamaño', _order.selectedSize),
                    _buildInfoRow('Sabor', _order.selectedFlavor),
                    _buildInfoRow('Cantidad', '${_order.quantity}'),
                  ]),

                  // Customization
                  if (_order.customization.customText != null ||
                      _order.customization.adornmentType != null ||
                      _order.customization.specialInstructions != null)
                    _buildSection('Personalización', Icons.edit, [
                      if (_order.customization.customText != null)
                        _buildInfoRow(
                          'Texto',
                          _order.customization.customText!,
                        ),
                      if (_order.customization.adornmentType != null)
                        _buildInfoRow(
                          'Adorno',
                          _order.customization.adornmentType!,
                        ),
                      if (_order.customization.specialInstructions != null)
                        _buildInfoRow(
                          'Instrucciones',
                          _order.customization.specialInstructions!,
                        ),
                    ]),

                  // Delivery Information
                  _buildSection(
                    'Información de Entrega',
                    Icons.local_shipping,
                    [
                      _buildInfoRow(
                        'Fecha',
                        dateFormat.format(_order.deliveryDate),
                      ),
                      _buildInfoRow('Horario', _order.pickupTime),
                      _buildInfoRow(
                        'Tipo',
                        _order.deliveryType == model.DeliveryType.delivery
                            ? '🚚 Delivery'
                            : '🏠 Recojo en tienda',
                      ),
                      if (_order.deliveryAddress != null)
                        _buildInfoRow('Dirección', _order.deliveryAddress!),
                      if (_order.assignedDeliveryPerson != null)
                        _buildInfoRow(
                          'Repartidor',
                          _order.assignedDeliveryPerson!,
                        ),
                    ],
                  ),

                  // Payment Information
                  _buildSection('Información de Pago', Icons.payment, [
                    _buildInfoRow(
                      'Total',
                      currencyFormat.format(_order.totalAmount),
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    _buildInfoRow(
                      'Señal pagada',
                      currencyFormat.format(_order.depositAmount),
                      valueStyle: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildInfoRow(
                      'Saldo pendiente',
                      currencyFormat.format(
                        _order.totalAmount - _order.depositAmount,
                      ),
                      valueStyle: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),

                  // Customer Notes
                  if (_order.notes != null && _order.notes!.isNotEmpty)
                    _buildSection('Notas del Cliente', Icons.note, [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _order.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ]),

                  // Status Actions
                  if (widget.showStatusActions)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusActions(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.currentUser?.role;
    final actions = <Widget>[];

    final isManager =
        userRole == UserRole.manager || userRole == UserRole.admin;
    final isBaker = userRole == UserRole.pastryChef;

    switch (_order.status) {
      case model.OrderStatus.pending:
        if (isManager) {
          actions.add(
            _buildActionButton(
              'Confirmar Pedido',
              Icons.check_circle,
              AppColors.success,
              () => _updateOrderStatus(model.OrderStatus.confirmed),
            ),
          );
          actions.add(const SizedBox(height: 12));
          actions.add(
            _buildActionButton(
              'Cancelar Pedido',
              Icons.cancel,
              AppColors.error,
              () => _showCancelDialog(),
            ),
          );
        } else {
          actions.add(
            _buildNoPermissionMessage(
              'Solo el encargado puede confirmar pedidos',
            ),
          );
        }
        break;

      case model.OrderStatus.confirmed:
        if (isBaker) {
          actions.add(
            _buildActionButton(
              'Iniciar Producción',
              Icons.construction,
              AppColors.primary,
              () => _updateOrderStatus(model.OrderStatus.inProduction),
            ),
          );
        } else {
          actions.add(
            _buildNoPermissionMessage(
              'Solo el pastelero puede iniciar producción',
            ),
          );
        }
        break;

      case model.OrderStatus.inProduction:
        if (isBaker) {
          actions.add(
            _buildActionButton(
              'Marcar como Listo',
              Icons.done_all,
              AppColors.success,
              () => _updateOrderStatus(model.OrderStatus.ready),
            ),
          );
        } else {
          actions.add(
            _buildNoPermissionMessage(
              'Solo el pastelero puede marcar como listo',
            ),
          );
        }
        break;

      case model.OrderStatus.ready:
        if (isManager) {
          if (_order.deliveryType == model.DeliveryType.delivery) {
            actions.add(
              _buildActionButton(
                'Asignar Repartidor',
                Icons.local_shipping,
                AppColors.info,
                () => _showAssignDeliveryPersonDialog(),
              ),
            );
          } else {
            actions.add(
              _buildActionButton(
                'Marcar como Completado',
                Icons.check_circle,
                AppColors.success,
                () => _updateOrderStatus(model.OrderStatus.completed),
              ),
            );
          }
        } else {
          actions.add(
            _buildNoPermissionMessage(
              'Solo el encargado puede completar entregas',
            ),
          );
        }
        break;

      case model.OrderStatus.outForDelivery:
        if (isManager) {
          actions.add(
            _buildActionButton(
              'Marcar como Completado',
              Icons.check_circle,
              AppColors.success,
              () => _updateOrderStatus(model.OrderStatus.completed),
            ),
          );
        } else {
          actions.add(
            _buildNoPermissionMessage(
              'Solo el encargado puede completar entregas',
            ),
          );
        }
        break;

      case model.OrderStatus.completed:
        actions.add(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este pedido ha sido completado',
                    style: TextStyle(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case model.OrderStatus.cancelled:
        actions.add(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.cancel, color: AppColors.error),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este pedido ha sido cancelado',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: actions,
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNoPermissionMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDeliveryPersonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Repartidor'),
        content: TextField(
          controller: _deliveryPersonController,
          decoration: const InputDecoration(
            labelText: 'Nombre del repartidor',
            hintText: 'Ingrese el nombre',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_deliveryPersonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _updateOrderStatus(
                  model.OrderStatus.outForDelivery,
                  deliveryPerson: _deliveryPersonController.text.trim(),
                );
                _deliveryPersonController.clear();
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este pedido? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateOrderStatus(model.OrderStatus.cancelled);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}

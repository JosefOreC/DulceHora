import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../config/service_locator.dart';
import '../../../modelo/order.dart' as model;
import '../../widgets/employee_drawer.dart';
import 'employee_order_detail_screen.dart';

/// Order management screen for managers (HU-E2)
class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<model.Order> _orders = [];
  List<model.Order> _filteredOrders = [];
  bool _isLoading = false;
  model.OrderStatus? _filterStatus;
  model.DeliveryType? _filterDeliveryType;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Default to last 30 days
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 90)), // Future orders too
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredOrders = _orders.where((order) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            order.productName.toLowerCase().contains(_searchQuery) ||
            order.id.toLowerCase().contains(_searchQuery) ||
            (order.deliveryAddress?.toLowerCase().contains(_searchQuery) ??
                false);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_filterStatus != null && order.status != _filterStatus) {
        return false;
      }

      // Delivery type filter
      if (_filterDeliveryType != null &&
          order.deliveryType != _filterDeliveryType) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<model.Order> orders;
      if (_filterStatus != null) {
        orders = await serviceLocator.orderRepository.getOrdersByStatus(
          _filterStatus!,
        );
        // If status filter is active, we might want to filter by date locally or fetch all
        // For now, let's keep status filter as primary if selected, but ideally we combine them.
        // However, the repository might not support complex combined queries easily without composite indexes.
        // Let's filter by date locally if status is selected.
        if (_selectedDateRange != null) {
          orders = orders.where((o) {
            return o.deliveryDate.isAfter(
                  _selectedDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                o.deliveryDate.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
        }
      } else {
        // If no status filter, use date range query
        if (_selectedDateRange != null) {
          orders = await serviceLocator.orderRepository.getOrdersByDateRange(
            _selectedDateRange!.start,
            _selectedDateRange!.end,
          );
        } else {
          // Fallback default
          final now = DateTime.now();
          orders = await serviceLocator.orderRepository.getOrdersByDateRange(
            now.subtract(const Duration(days: 30)),
            now.add(const Duration(days: 90)),
          );
        }
      }

      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar pedidos: $e')));
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadOrders();
    }
  }

  Color _getStatusColor(model.OrderStatus status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Recargar',
          ),
        ],
      ),
      drawer: const EmployeeDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por producto, ID o dirección...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Date Range Filter
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Filtrar por fecha'
                        : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}',
                  ),
                  onPressed: _selectDateRange,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                ),

                const SizedBox(width: 8),

                // Status Filter
                ...model.OrderStatus.values.map((status) {
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _filterStatus = selected ? status : null;
                          // Reload orders because status filter affects the query strategy
                          _loadOrders();
                        });
                      },
                    ),
                  );
                }).toList(),

                const SizedBox(width: 8),

                // Delivery Type Filter
                FilterChip(
                  label: const Text('🚚 Delivery'),
                  selected: _filterDeliveryType == model.DeliveryType.delivery,
                  onSelected: (selected) {
                    setState(() {
                      _filterDeliveryType = selected
                          ? model.DeliveryType.delivery
                          : null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('🏠 Recojo'),
                  selected: _filterDeliveryType == model.DeliveryType.pickup,
                  onSelected: (selected) {
                    setState(() {
                      _filterDeliveryType = selected
                          ? model.DeliveryType.pickup
                          : null;
                      _applyFilters();
                    });
                  },
                ),

                // Clear Filters
                if (_filterStatus != null ||
                    _filterDeliveryType != null ||
                    _searchQuery.isNotEmpty ||
                    _selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Limpiar'),
                      onPressed: () {
                        setState(() {
                          _filterStatus = null;
                          _filterDeliveryType = null;
                          _selectedDateRange = null; // Clear date range
                          _searchController.clear();
                          _loadOrders(); // Reload orders after clearing filters
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results Counter
          if (_filteredOrders.length != _orders.length)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Mostrando ${_filteredOrders.length} de ${_orders.length} pedidos',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron pedidos',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (_filterStatus != null ||
                            _filterDeliveryType != null ||
                            _searchQuery.isNotEmpty ||
                            _selectedDateRange != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _filterStatus = null;
                                _filterDeliveryType = null;
                                _selectedDateRange = null;
                                _searchController.clear();
                                _loadOrders();
                              });
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _getStatusColor(
                              order.status,
                            ).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmployeeOrderDetailScreen(order: order),
                              ),
                            );
                            if (result == true) {
                              _loadOrders();
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${order.id.substring(0, 8).toUpperCase()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          order.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getStatusColor(order.status),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        order.status.displayName,
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.cake,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      dateFormat.format(order.deliveryDate),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      order.deliveryType ==
                                              model.DeliveryType.delivery
                                          ? Icons.local_shipping
                                          : Icons.store,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.deliveryType ==
                                              model.DeliveryType.delivery
                                          ? 'Delivery'
                                          : 'Recojo',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.deliveryAddress != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          order.deliveryAddress!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

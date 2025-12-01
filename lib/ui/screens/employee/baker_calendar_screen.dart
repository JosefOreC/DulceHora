import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/app_colors.dart';
import '../../../config/service_locator.dart';
import '../../../modelo/order.dart' as model;
import '../../widgets/employee_drawer.dart';
import 'employee_order_detail_screen.dart';

/// Baker calendar screen for viewing production schedule (HU-E1)
class BakerCalendarScreen extends StatefulWidget {
  const BakerCalendarScreen({super.key});

  @override
  State<BakerCalendarScreen> createState() => _BakerCalendarScreenState();
}

class _BakerCalendarScreenState extends State<BakerCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<model.Order> _ordersForSelectedDay = [];
  List<model.Order> _filteredOrders = [];
  bool _isLoading = false;
  model.OrderStatus? _filterStatus;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _searchController.addListener(_onSearchChanged);
    _loadOrdersForDay(_selectedDay!);
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
    _filteredOrders = _ordersForSelectedDay.where((order) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            order.productName.toLowerCase().contains(_searchQuery) ||
            order.id.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_filterStatus != null && order.status != _filterStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _loadOrdersForDay(DateTime day) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await serviceLocator.orderRepository
          .getOrdersByDeliveryDate(day);

      // Filter to show only relevant statuses for bakers
      final relevantOrders = orders
          .where(
            (order) =>
                order.status == model.OrderStatus.confirmed ||
                order.status == model.OrderStatus.inProduction ||
                order.status == model.OrderStatus.ready,
          )
          .toList();

      setState(() {
        _ordersForSelectedDay = relevantOrders;
        _filteredOrders = relevantOrders;
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Producción')),
      drawer: const EmployeeDrawer(),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadOrdersForDay(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por producto o ID...',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Confirmado'),
                  selected: _filterStatus == model.OrderStatus.confirmed,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected
                          ? model.OrderStatus.confirmed
                          : null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('En Producción'),
                  selected: _filterStatus == model.OrderStatus.inProduction,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected
                          ? model.OrderStatus.inProduction
                          : null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Listo'),
                  selected: _filterStatus == model.OrderStatus.ready,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected ? model.OrderStatus.ready : null;
                      _applyFilters();
                    });
                  },
                ),
                if (_filterStatus != null || _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Limpiar'),
                      onPressed: () {
                        setState(() {
                          _filterStatus = null;
                          _searchController.clear();
                          _applyFilters();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Orders for selected day
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedidos para ${dateFormat.format(_selectedDay!)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_filteredOrders.isNotEmpty)
                  Chip(
                    label: Text('${_filteredOrders.length}'),
                    backgroundColor: AppColors.primary,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pedidos para este día',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];

                      Color statusColor;
                      switch (order.status) {
                        case model.OrderStatus.confirmed:
                          statusColor = AppColors.info;
                          break;
                        case model.OrderStatus.inProduction:
                          statusColor = AppColors.warning;
                          break;
                        case model.OrderStatus.ready:
                          statusColor = AppColors.success;
                          break;
                        default:
                          statusColor = AppColors.textSecondary;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EmployeeOrderDetailScreen(
                                  order: order,
                                  showStatusActions: true,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadOrdersForDay(_selectedDay!);
                            }
                          },
                          leading: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          title: Text(
                            order.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Horario: ${order.pickupTime}'),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.status.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../config/service_locator.dart';
import '../../../modelo/order.dart' as model;
import '../../widgets/employee_drawer.dart';

class DemandReportsScreen extends StatefulWidget {
  const DemandReportsScreen({super.key});

  @override
  State<DemandReportsScreen> createState() => _DemandReportsScreenState();
}

class _DemandReportsScreenState extends State<DemandReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 60));
  List<model.Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await ServiceLocator().orderRepository
          .getOrdersByDateRange(_startDate, _endDate);

      setState(() {
        _orders = orders;
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
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadOrders();
    }
  }

  Map<String, int> _getOrdersByStatus() {
    final Map<String, int> statusCount = {};
    for (var order in _orders) {
      final status = order.status.displayName;
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    return statusCount;
  }

  Map<String, int> _getOrdersByDate() {
    final Map<String, int> dateCount = {};
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var order in _orders) {
      final dateKey = dateFormat.format(order.deliveryDate);
      dateCount[dateKey] = (dateCount[dateKey] ?? 0) + 1;
    }

    // Sort by date
    final sortedEntries = dateCount.entries.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
        final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
        return dateA.compareTo(dateB);
      });

    return Map.fromEntries(sortedEntries);
  }

  List<Map<String, dynamic>> _getHighDemandDays(Map<String, int> dateCounts) {
    if (dateCounts.isEmpty) return [];

    final totalOrders = dateCounts.values.reduce((a, b) => a + b);
    final avgDemand = totalOrders / dateCounts.length;

    final highDemandDays = dateCounts.entries.map((entry) {
      final count = entry.value;
      String level;

      if (count >= avgDemand * 1.5) {
        level = 'Muy Alta';
      } else if (count >= avgDemand) {
        level = 'Alta';
      } else if (count >= avgDemand * 0.7) {
        level = 'Media';
      } else {
        level = 'Baja';
      }

      return {'date': entry.key, 'count': count, 'level': level};
    }).toList();

    highDemandDays.sort(
      (a, b) => (b['count'] as int).compareTo(a['count'] as int),
    );

    return highDemandDays.take(10).toList();
  }

  double _getTotalRevenue() {
    return _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    final statusCounts = _getOrdersByStatus();
    final dateCounts = _getOrdersByDate();
    final highDemandDays = _getHighDemandDays(dateCounts);
    final totalOrders = _orders.length;
    final totalRevenue = _getTotalRevenue();

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Demanda')),
      drawer: const EmployeeDrawer(),
      body: Column(
        children: [
          // Date range selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),

          // Statistics
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                ? const Center(
                    child: Text(
                      'No hay pedidos en este rango de fechas',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Pedidos',
                                  '$totalOrders',
                                  Icons.shopping_bag,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Ingresos Totales',
                                  currencyFormat.format(totalRevenue),
                                  Icons.attach_money,
                                  AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // High Demand Days
                          Text(
                            '🔥 Días de Alta Demanda',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Top ${highDemandDays.length} días con mayor cantidad de pedidos',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ...highDemandDays.map((entry) {
                            final date = DateFormat(
                              'dd/MM/yyyy',
                            ).parse(entry['date']);
                            final count = entry['count'] as int;
                            final level = entry['level'] as String;
                            final isFuture = date.isAfter(DateTime.now());

                            Color levelColor;
                            IconData levelIcon;

                            switch (level) {
                              case 'Muy Alta':
                                levelColor = AppColors.error;
                                levelIcon = Icons.warning;
                                break;
                              case 'Alta':
                                levelColor = AppColors.warning;
                                levelIcon = Icons.trending_up;
                                break;
                              case 'Media':
                                levelColor = AppColors.info;
                                levelIcon = Icons.show_chart;
                                break;
                              default:
                                levelColor = AppColors.success;
                                levelIcon = Icons.check_circle;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: levelColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: levelColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: levelColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      levelIcon,
                                      color: levelColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              entry['date'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: levelColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isFuture)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.info
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'PRÓXIMO',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.info,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Demanda: $level',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: levelColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 24),

                          // Order Status Distribution
                          Text(
                            'Distribución por Estado',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: statusCounts.entries.map((entry) {
                                  final percentage =
                                      (entry.value / totalOrders * 100)
                                          .toStringAsFixed(1);
                                  Color statusColor;

                                  switch (entry.key) {
                                    case 'Pendiente':
                                      statusColor = AppColors.warning;
                                      break;
                                    case 'Confirmado':
                                      statusColor = AppColors.info;
                                      break;
                                    case 'En Producción':
                                      statusColor = AppColors.primary;
                                      break;
                                    case 'Listo':
                                      statusColor = AppColors.success;
                                      break;
                                    case 'En Camino':
                                      statusColor = AppColors.primary;
                                      break;
                                    case 'Completado':
                                      statusColor = AppColors.success;
                                      break;
                                    case 'Cancelado':
                                      statusColor = AppColors.error;
                                      break;
                                    default:
                                      statusColor = AppColors.textSecondary;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: statusColor,
                                              ),
                                            ),
                                            Text(
                                              '${entry.value} ($percentage%)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: entry.value / totalOrders,
                                            minHeight: 12,
                                            backgroundColor: statusColor
                                                .withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  statusColor,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

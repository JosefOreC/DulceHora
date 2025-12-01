import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../modelo/user.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/employee/baker_calendar_screen.dart';
import '../screens/employee/order_management_screen.dart';
import '../screens/employee/price_management_screen.dart';
import '../screens/employee/demand_reports_screen.dart';

/// Navigation drawer for employee screens
class EmployeeDrawer extends StatelessWidget {
  const EmployeeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.role.displayName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Catalog option (for all roles)
          ListTile(
            leading: const Icon(Icons.storefront, color: AppColors.primary),
            title: const Text('Ver Catálogo'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
          ),

          const Divider(),

          // Role-specific navigation
          if (user.role == UserRole.pastryChef)
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: const Text('Calendario de Producción'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BakerCalendarScreen(),
                  ),
                );
              },
            ),

          if (user.role == UserRole.manager)
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.primary),
              title: const Text('Gestión de Pedidos'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OrderManagementScreen(),
                  ),
                );
              },
            ),

          if (user.role == UserRole.admin)
            ListTile(
              leading: const Icon(Icons.price_change, color: AppColors.primary),
              title: const Text('Gestión de Precios'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PriceManagementScreen(),
                  ),
                );
              },
            ),

          if (user.role == UserRole.analyst)
            ListTile(
              leading: const Icon(Icons.analytics, color: AppColors.primary),
              title: const Text('Reportes de Demanda'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DemandReportsScreen(),
                  ),
                );
              },
            ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

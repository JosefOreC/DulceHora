import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../modelo/user.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'employee/baker_calendar_screen.dart';
import 'employee/order_management_screen.dart';
import 'employee/price_management_screen.dart';
import 'employee/demand_reports_screen.dart';

/// Splash screen with branding and initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load products
    await context.read<ProductProvider>().loadProducts();

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      // Check authentication status and load user data
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus();

      final user = authProvider.currentUser;

      Widget destination;

      if (user != null) {
        // Navigate based on user role
        switch (user.role) {
          case UserRole.pastryChef:
            // HU-E1: Pastelero → Calendario de producción
            destination = const BakerCalendarScreen();
            break;
          case UserRole.manager:
            // HU-E2: Encargado → Gestión de pedidos
            destination = const OrderManagementScreen();
            break;
          case UserRole.admin:
            // HU-E3: Admin → Gestión de precios (con acceso a todo)
            destination = const PriceManagementScreen();
            break;
          case UserRole.analyst:
            // HU-E4: Gestor → Reportes de demanda
            destination = const DemandReportsScreen();
            break;
          default:
            // Customers and others → Home screen (catalog)
            destination = const HomeScreen();
        }
      } else {
        // Not logged in → Home screen (catalog)
        destination = const HomeScreen();
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cake,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DulceHora',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastelería y Postres',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

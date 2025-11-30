import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/service_locator.dart';
import 'data/seed_database.dart';
import 'ui/providers/cart_provider.dart';
import 'ui/providers/auth_provider.dart';
import 'ui/providers/product_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Disable App Check enforcement for development
    // This fixes the CONFIGURATION_NOT_FOUND error
    await firebase_auth.FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );

    // Initialize service locator (dependency injection)
    final _ = ServiceLocator();

    // Seed database if empty (only on first run)
    try {
      final seeder = SeedDatabase();
      await seeder.seedIfEmpty();
    } catch (e) {
      debugPrint('Error seeding database: $e');
      // Continue app initialization even if seeding fails
    }

    runApp(const DulceHoraApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(const ErrorApp());
  }
}

class DulceHoraApp extends StatelessWidget {
  const DulceHoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'DulceHora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

/// Error app shown if Firebase initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error al inicializar la aplicación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Por favor, verifica la configuración de Firebase'),
            ],
          ),
        ),
      ),
    );
  }
}

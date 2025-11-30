import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../controlador/interfaces/i_auth_service.dart';
import '../controlador/interfaces/i_order_repository.dart';
import '../controlador/interfaces/i_product_repository.dart';
import '../controlador/interfaces/i_user_repository.dart';
import '../controlador/repositories/firestore_order_repository.dart';
import '../controlador/repositories/firestore_product_repository.dart';
import '../controlador/repositories/firestore_user_repository.dart';
import '../controlador/services/firebase_auth_service.dart';

/// Service locator for dependency injection
/// Provides singleton instances of repositories and services
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // Lazy initialization of services
  IProductRepository? _productRepository;
  IUserRepository? _userRepository;
  IOrderRepository? _orderRepository;
  IAuthService? _authService;

  /// Get product repository instance
  IProductRepository get productRepository {
    _productRepository ??= FirestoreProductRepository(
      firestore: FirebaseFirestore.instance,
    );
    return _productRepository!;
  }

  /// Get user repository instance
  IUserRepository get userRepository {
    _userRepository ??= FirestoreUserRepository(
      firestore: FirebaseFirestore.instance,
    );
    return _userRepository!;
  }

  /// Get order repository instance
  IOrderRepository get orderRepository {
    _orderRepository ??= FirestoreOrderRepository(
      firestore: FirebaseFirestore.instance,
    );
    return _orderRepository!;
  }

  /// Get auth service instance
  IAuthService get authService {
    _authService ??= FirebaseAuthService(
      auth: firebase_auth.FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
      userRepository: userRepository,
    );
    return _authService!;
  }

  /// Reset all services (useful for testing)
  void reset() {
    _productRepository = null;
    _userRepository = null;
    _orderRepository = null;
    _authService = null;
  }

  /// Register custom implementations (for testing or switching databases)
  void registerProductRepository(IProductRepository repository) {
    _productRepository = repository;
  }

  void registerUserRepository(IUserRepository repository) {
    _userRepository = repository;
  }

  void registerOrderRepository(IOrderRepository repository) {
    _orderRepository = repository;
  }

  void registerAuthService(IAuthService service) {
    _authService = service;
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

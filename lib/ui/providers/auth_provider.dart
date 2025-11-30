import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../modelo/user.dart' as app_model;
import '../../controlador/interfaces/i_auth_service.dart';
import '../../controlador/interfaces/i_user_repository.dart';
import '../../config/service_locator.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final IAuthService _authService = ServiceLocator().authService;
  final IUserRepository _userRepository = ServiceLocator().userRepository;

  app_model.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  app_model.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmployee => _currentUser?.isEmployee ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _initAuthListener();
  }

  /// Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserData(user.id);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from repository
  Future<void> _loadUserData(String userId) async {
    try {
      _currentUser = await _userRepository.getUserById(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _errorMessage = 'Error al cargar datos del usuario';
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        await _loadUserData(user.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Error al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Error al iniciar sesión con Google';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if email already exists
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Este correo ya está registrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Error al registrar usuario';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este correo ya está en uso';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'Correo electrónico inválido';
        default:
          return 'Error de autenticación';
      }
    }
    return 'Error desconocido';
  }
}

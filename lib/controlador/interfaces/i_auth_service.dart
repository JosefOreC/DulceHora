import 'package:dulcehora/modelo/user.dart';

/// Interface for authentication service
/// This abstraction allows switching authentication providers via dependency injection
abstract class IAuthService {
  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password);

  /// Sign in with Google
  Future<User?> signInWithGoogle();

  /// Sign up with email and password (customers only)
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Get current user ID
  String? getCurrentUserId();

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user password
  Future<void> updatePassword(String newPassword);
}

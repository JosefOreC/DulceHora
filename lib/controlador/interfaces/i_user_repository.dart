import 'package:dulcehora/modelo/user.dart';

/// Interface for user repository operations
/// This abstraction allows switching database implementations via dependency injection
abstract class IUserRepository {
  /// Create a new user
  Future<void> createUser(User user);

  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Get user by email
  Future<User?> getUserByEmail(String email);

  /// Update user information
  Future<void> updateUser(User user);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Check if email already exists (for duplicate prevention)
  Future<bool> checkEmailExists(String email);

  /// Get all users by role (admin only)
  Future<List<User>> getUsersByRole(UserRole role);

  /// Get all delivery personnel (for order assignment)
  Future<List<User>> getDeliveryPersonnel();
}

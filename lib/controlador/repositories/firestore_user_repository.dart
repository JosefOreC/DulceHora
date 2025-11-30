import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/user.dart';
import '../interfaces/i_user_repository.dart';

/// Firestore implementation of IUserRepository
class FirestoreUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'users';

  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection(_collectionName);

  @override
  Future<void> createUser(User user) async {
    try {
      // Check for duplicate email before creating
      final emailExists = await checkEmailExists(user.email);
      if (emailExists) {
        throw Exception('Email already exists');
      }

      await _collection.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return User.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      final snapshot = await _collection
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return User.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user by email: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _collection.doc(user.id).update(updatedUser.toJson());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _collection.doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final snapshot = await _collection
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking email existence: $e');
    }
  }

  @override
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _collection
          .where('role', isEqualTo: role.name)
          .get();

      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching users by role: $e');
    }
  }

  @override
  Future<List<User>> getDeliveryPersonnel() async {
    try {
      // Assuming delivery personnel could be managers or specific role
      // Adjust based on your business logic
      final snapshot = await _collection
          .where('role', whereIn: [UserRole.manager.name])
          .get();

      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching delivery personnel: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../controlador/repositories/firestore_product_repository.dart';
import 'products_seed.dart';

/// Script to seed the Firestore database with initial product data
/// This should be run once during development/deployment
class SeedDatabase {
  final FirebaseFirestore _firestore;

  SeedDatabase({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Seed all products into Firestore
  Future<void> seedProducts() async {
    try {
      debugPrint('Starting product seeding...');

      final repository = FirestoreProductRepository(firestore: _firestore);
      final products = ProductsSeed.getProducts();

      int count = 0;
      for (final product in products) {
        await repository.createProduct(product);
        count++;
        debugPrint('Seeded product $count/${products.length}: ${product.name}');
      }

      debugPrint('Successfully seeded $count products!');
    } catch (e) {
      debugPrint('Error seeding products: $e');
      rethrow;
    }
  }

  /// Check if products already exist
  Future<bool> productsExist() async {
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking products: $e');
      return false;
    }
  }

  /// Seed products only if they don't exist
  Future<void> seedIfEmpty() async {
    try {
      final exists = await productsExist();

      if (exists) {
        debugPrint('Products already exist in database. Skipping seed.');
        return;
      }

      await seedProducts();
    } catch (e) {
      debugPrint('Error in seedIfEmpty: $e');
      rethrow;
    }
  }

  /// Clear all products (use with caution!)
  Future<void> clearProducts() async {
    try {
      debugPrint('Clearing all products...');

      final snapshot = await _firestore.collection('products').get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('Cleared ${snapshot.docs.length} products');
    } catch (e) {
      debugPrint('Error clearing products: $e');
      rethrow;
    }
  }

  /// Reseed: clear and seed fresh data
  Future<void> reseedProducts() async {
    try {
      await clearProducts();
      await seedProducts();
    } catch (e) {
      debugPrint('Error reseeding products: $e');
      rethrow;
    }
  }
}

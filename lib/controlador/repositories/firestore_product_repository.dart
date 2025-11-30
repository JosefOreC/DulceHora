import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/product.dart';
import '../interfaces/i_product_repository.dart';

/// Firestore implementation of IProductRepository
class FirestoreProductRepository implements IProductRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'products';

  FirestoreProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection(_collectionName);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _collection
          .where('isAvailable', isEqualTo: true)
          .get();

      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort in memory to avoid composite index requirement
      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _collection.doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      return Product.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByOccasion(String occasion) async {
    try {
      final snapshot = await _collection
          .where('occasions', arrayContains: occasion.toLowerCase())
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products by occasion: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _collection
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .get();

      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort in memory to avoid composite index requirement
      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _collection
          .where('isAvailable', isEqualTo: true)
          .get();

      final queryLower = query.toLowerCase();

      // Filter in memory for better search (Firestore has limited text search)
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .where(
            (product) =>
                product.name.toLowerCase().contains(queryLower) ||
                product.description.toLowerCase().contains(queryLower),
          )
          .toList();
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      await _collection.doc(product.id).set(product.toJson());
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      await _collection.doc(product.id).update(updatedProduct.toJson());
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _collection.doc(productId).delete();
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  @override
  Future<void> updateProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      await _collection.doc(productId).update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating product availability: $e');
    }
  }
}

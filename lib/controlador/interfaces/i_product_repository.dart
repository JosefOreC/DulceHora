import 'package:dulcehora/modelo/product.dart';

/// Interface for product repository operations
/// This abstraction allows switching database implementations via dependency injection
abstract class IProductRepository {
  /// Get all available products
  Future<List<Product>> getAllProducts();

  /// Get a specific product by ID
  Future<Product?> getProductById(String productId);

  /// Get products filtered by occasion (e.g., "birthday", "wedding")
  Future<List<Product>> getProductsByOccasion(String occasion);

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category);

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query);

  /// Create a new product (admin only)
  Future<void> createProduct(Product product);

  /// Update an existing product (admin only)
  Future<void> updateProduct(Product product);

  /// Delete a product (admin only)
  Future<void> deleteProduct(String productId);

  /// Update product availability
  Future<void> updateProductAvailability(String productId, bool isAvailable);
}

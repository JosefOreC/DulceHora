import 'package:flutter/foundation.dart';
import '../../modelo/product.dart';
import '../../controlador/interfaces/i_product_repository.dart';
import '../../config/service_locator.dart';

/// Provider for managing product catalog state
class ProductProvider with ChangeNotifier {
  final IProductRepository _productRepository =
      ServiceLocator().productRepository;

  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products; // All products without filters
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get filtered products based on category and search
  List<Product> get _filteredProducts {
    var filtered = _products.where((p) => p.isAvailable).toList();

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  /// Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('ProductProvider: Starting to load products...');
      _products = await _productRepository.getAllProducts();
      debugPrint('ProductProvider: Loaded ${_products.length} products');
      _extractCategories();
      debugPrint('ProductProvider: Extracted ${_categories.length} categories');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('ProductProvider: Error loading products: $e');
      debugPrint('ProductProvider: Stack trace: $stackTrace');
      _errorMessage = 'Error al cargar productos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Extract unique categories from products
  void _extractCategories() {
    final categorySet = <String>{};
    for (var product in _products) {
      categorySet.add(product.category);
    }
    _categories = categorySet.toList()..sort();
  }

  /// Set selected category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get products by occasion
  List<Product> getProductsByOccasion(String occasion) {
    return _products
        .where((p) => p.isAvailable && p.occasions.contains(occasion))
        .toList();
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts();
  }
}

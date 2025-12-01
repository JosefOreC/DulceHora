import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/service_locator.dart';
import '../../../modelo/product.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_display.dart';
import '../../widgets/employee_drawer.dart';
import '../../providers/product_provider.dart';

/// Price management screen for admins (HU-E3)
/// Allows editing base prices, size multipliers, and flavor prices
class PriceManagementScreen extends StatefulWidget {
  const PriceManagementScreen({super.key});

  @override
  State<PriceManagementScreen> createState() => _PriceManagementScreenState();
}

class _PriceManagementScreenState extends State<PriceManagementScreen> {
  final _productRepository = ServiceLocator().productRepository;
  final _currencyFormat = NumberFormat.currency(symbol: 'S/', decimalDigits: 2);

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final query = _searchController.text.toLowerCase();
        final matchesSearch =
            query.isEmpty ||
            product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);

        final matchesCategory =
            _selectedCategory == null || product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productRepository.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar productos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => ProductPriceEditor(product: product)),
    );

    if (result != null) {
      try {
        await _productRepository.updateProduct(result);
        await _loadProducts();

        // Refresh ProductProvider to update catalog
        if (mounted) {
          final productProvider = context.read<ProductProvider>();
          await productProvider.loadProducts();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Precios actualizados correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Precios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Recargar',
          ),
        ],
      ),
      drawer: const EmployeeDrawer(),
      body: _isLoading
          ? const LoadingIndicator(message: 'Cargando productos...')
          : _errorMessage != null
          ? ErrorDisplay(message: _errorMessage!, onRetry: _loadProducts)
          : _products.isEmpty
          ? const Center(child: Text('No hay productos disponibles'))
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...['Tortas', 'Cupcakes', 'Postres'].map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                                _applyFilters();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Product List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _filteredProducts.isEmpty
                        ? const Center(
                            child: Text('No se encontraron productos'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      product.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text('Categoría: ${product.category}'),
                                      Text(
                                        'Precio base: ${_currencyFormat.format(product.basePrice)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editProduct(product),
                                    tooltip: 'Editar precios',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Product price editor screen
class ProductPriceEditor extends StatefulWidget {
  final Product product;

  const ProductPriceEditor({super.key, required this.product});

  @override
  State<ProductPriceEditor> createState() => _ProductPriceEditorState();
}

class _ProductPriceEditorState extends State<ProductPriceEditor> {
  late TextEditingController _basePriceController;
  late Map<String, TextEditingController> _sizeControllers;
  late Map<String, TextEditingController> _flavorControllers;

  @override
  void initState() {
    super.initState();
    _basePriceController = TextEditingController(
      text: widget.product.basePrice.toStringAsFixed(2),
    );

    _sizeControllers = {};
    for (var entry in widget.product.sizeMultipliers.entries) {
      _sizeControllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(2),
      );
    }

    _flavorControllers = {};
    for (var entry in widget.product.flavorPrices.entries) {
      _flavorControllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    for (var controller in _sizeControllers.values) {
      controller.dispose();
    }
    for (var controller in _flavorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    try {
      final basePrice = double.parse(_basePriceController.text);

      final sizeMultipliers = <String, double>{};
      for (var entry in _sizeControllers.entries) {
        sizeMultipliers[entry.key] = double.parse(entry.value.text);
      }

      final flavorPrices = <String, double>{};
      for (var entry in _flavorControllers.entries) {
        flavorPrices[entry.key] = double.parse(entry.value.text);
      }

      final updatedProduct = widget.product.copyWith(
        basePrice: basePrice,
        sizeMultipliers: sizeMultipliers,
        flavorPrices: flavorPrices,
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(updatedProduct);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: Verifica que todos los valores sean números válidos',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.product.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base Price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Precio Base',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _basePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Base (S/)',
                        border: OutlineInputBorder(),
                        prefixText: 'S/ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Size Multipliers
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.straighten, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Multiplicadores por Tamaño',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El precio final se calcula como: Precio Base × Multiplicador',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._sizeControllers.entries.map((entry) {
                      final basePrice =
                          double.tryParse(_basePriceController.text) ??
                          widget.product.basePrice;
                      final multiplier =
                          double.tryParse(entry.value.text) ?? 1.0;
                      final finalPrice = basePrice * multiplier;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: entry.key,
                                border: const OutlineInputBorder(),
                                suffixText: 'x',
                                helperText:
                                    'Precio: ${currencyFormat.format(finalPrice)}',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Flavor Prices
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cake, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Precios Adicionales por Sabor',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estos precios se suman al precio calculado (Base × Tamaño)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._flavorControllers.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: entry.key,
                            border: const OutlineInputBorder(),
                            prefixText: '+ S/ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

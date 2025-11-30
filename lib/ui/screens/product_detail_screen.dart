import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../modelo/product.dart';
import '../../modelo/customization.dart';
import '../../config/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Product detail screen with customization options
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedFlavor;
  int _quantity = 1;

  // Customization fields
  bool _showCustomization = false;
  final TextEditingController _customTextController = TextEditingController();
  String? _selectedAdornment;
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default selections
    _selectedSize = widget.product.sizeMultipliers.keys.first;
    _selectedFlavor = widget.product.flavorPrices.keys.first;
  }

  @override
  void dispose() {
    _customTextController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  double get _currentPrice {
    final basePrice = widget.product.calculatePrice(
      _selectedSize!,
      _selectedFlavor!,
    );
    double customizationPrice = 0.0;

    if (_showCustomization) {
      if (_customTextController.text.isNotEmpty) {
        customizationPrice += 5.0; // Base text price
      }
      if (_selectedAdornment != null) {
        customizationPrice += 10.0; // Adornment price
      }
    }

    return (basePrice + customizationPrice) * _quantity;
  }

  void _addToCart() {
    Customization? customization;

    if (_showCustomization &&
        (_customTextController.text.isNotEmpty || _selectedAdornment != null)) {
      customization = Customization(
        customText: _customTextController.text.isNotEmpty
            ? _customTextController.text
            : null,
        adornmentType: _selectedAdornment,
        specialInstructions: _specialInstructionsController.text.isNotEmpty
            ? _specialInstructionsController.text
            : null,
      );
    }

    context.read<CartProvider>().addItem(
      product: widget.product,
      selectedSize: _selectedSize!,
      selectedFlavor: _selectedFlavor!,
      quantity: _quantity,
      customization: customization,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto agregado al carrito'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.cake, size: 64),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.product.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Size Selection
                  Text(
                    'Tamaño',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.product.sizeMultipliers.keys.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Flavor Selection
                  Text(
                    'Sabor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.product.flavorPrices.keys.map((flavor) {
                      final extraPrice = widget.product.flavorPrices[flavor]!;
                      return ChoiceChip(
                        label: Text(
                          extraPrice > 0
                              ? '$flavor (+\$${extraPrice.toStringAsFixed(2)})'
                              : flavor,
                        ),
                        selected: _selectedFlavor == flavor,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFlavor = flavor;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Customization Toggle
                  if (widget.product.allowsCustomization)
                    SwitchListTile(
                      title: const Text('Personalizar'),
                      subtitle: const Text('Agregar texto o adornos'),
                      value: _showCustomization,
                      onChanged: (value) {
                        setState(() {
                          _showCustomization = value;
                        });
                      },
                    ),

                  // Customization Options
                  if (_showCustomization &&
                      widget.product.allowsCustomization) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Texto personalizado',
                      hint: 'Ej: Feliz Cumpleaños',
                      controller: _customTextController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Adornos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Flores', 'Frutas', 'Chocolate', 'Ninguno']
                          .map((adornment) {
                            return ChoiceChip(
                              label: Text(adornment),
                              selected: _selectedAdornment == adornment,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedAdornment = selected
                                      ? adornment
                                      : null;
                                });
                              },
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Instrucciones especiales',
                      hint: 'Detalles adicionales...',
                      controller: _specialInstructionsController,
                      maxLines: 3,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Cantidad',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar with Price and Add to Cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '\$${_currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Agregar al Carrito',
                  icon: Icons.shopping_cart,
                  onPressed: _addToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

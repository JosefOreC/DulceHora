import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_colors.dart';
import '../../config/service_locator.dart';
import '../../modelo/order.dart' as model;
import '../../modelo/customization.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/location_picker_widget.dart';
import 'receipt_screen.dart';

/// Complete checkout screen with map location selector
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  model.DeliveryType _deliveryType = model.DeliveryType.pickup;
  bool _isProcessing = false;
  LatLng? _selectedLocation;

  // Available time slots
  final List<String> _timeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 1)); // Tomorrow
    final lastDate = now.add(const Duration(days: 90)); // 3 months ahead

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerWidget(
          onLocationSelected: (location, address) {
            setState(() {
              _selectedLocation = location;
              _addressController.text = address;
            });
          },
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha de entrega'),
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un horario')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cart = context.read<CartProvider>();
      final authProvider = context.read<AuthProvider>();
      final orderRepository = serviceLocator.orderRepository;

      // Create orders for each cart item
      final List<String> orderIds = [];

      // Save cart totals BEFORE clearing
      final savedSubtotal = cart.subtotal;
      final savedIgv = cart.igv;
      final savedTotal = cart.total;

      for (final item in cart.items) {
        final order = model.Order(
          id: '',
          userId: authProvider.currentUser!.id,
          productId: item.product.id,
          productName: item.product.name,
          selectedSize: item.selectedSize,
          selectedFlavor: item.selectedFlavor,
          quantity: item.quantity,
          customization: item.customization ?? Customization(),
          deliveryDate: _selectedDate!,
          pickupTime: _selectedTimeSlot!,
          deliveryType: _deliveryType,
          depositAmount: item.totalPrice * 0.5,
          totalAmount: item.totalPrice,
          status: model.OrderStatus.pending,
          deliveryAddress: _deliveryType == model.DeliveryType.delivery
              ? _addressController.text.trim()
              : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        final orderId = await orderRepository.createOrder(order);
        orderIds.add(orderId);
      }

      cart.clear();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              orderIds: orderIds,
              deliveryDate: _selectedDate!,
              pickupTime: _selectedTimeSlot!,
              deliveryType: _deliveryType,
              subtotal: savedSubtotal,
              igv: savedIgv,
              totalAmount: savedTotal,
              depositAmount: savedTotal * 0.5,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el pedido: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Pedido',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...cart.items.map(
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surfaceVariant,
                                      child: const Icon(Icons.cake),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    Text(
                                      '${item.selectedSize} • ${item.selectedFlavor}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    if (item.customization != null) ...[
                                      if (item.customization!.customText !=
                                          null)
                                        Text(
                                          'Texto: ${item.customization!.customText}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                      if (item.customization!.adornmentType !=
                                          null)
                                        Text(
                                          'Adorno: ${item.customization!.adornmentType}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Delivery Date
                    Text(
                      'Fecha de Entrega',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Seleccionar fecha'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Slot
                    Text(
                      'Horario de Entrega',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Delivery Type
                    Text(
                      'Tipo de Entrega',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<model.DeliveryType>(
                            title: const Text('Recoger en tienda'),
                            value: model.DeliveryType.pickup,
                            groupValue: _deliveryType,
                            onChanged: (value) {
                              setState(() {
                                _deliveryType = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<model.DeliveryType>(
                            title: const Text('Entrega a domicilio'),
                            value: model.DeliveryType.delivery,
                            groupValue: _deliveryType,
                            onChanged: (value) {
                              setState(() {
                                _deliveryType = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Delivery Address (if delivery selected)
                    if (_deliveryType == model.DeliveryType.delivery) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Dirección de Entrega',
                              hint: 'Ingresa tu dirección completa',
                              controller: _addressController,
                              prefixIcon: Icons.location_on,
                              maxLines: 2,
                              validator: (value) {
                                if (_deliveryType ==
                                        model.DeliveryType.delivery &&
                                    (value == null || value.isEmpty)) {
                                  return 'La dirección es requerida para entrega a domicilio';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _selectLocationOnMap,
                            icon: const Icon(Icons.map),
                            tooltip: 'Seleccionar en mapa',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Ubicación seleccionada: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.success),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],

                    // Order Notes
                    CustomTextField(
                      label: 'Notas del Pedido (Opcional)',
                      hint: 'Instrucciones especiales...',
                      controller: _notesController,
                      prefixIcon: Icons.note,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Payment Summary
            Container(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text(currencyFormat.format(cart.subtotal)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('IGV (18%):'),
                        Text(currencyFormat.format(cart.igv)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text(currencyFormat.format(cart.total)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Señal (50%):',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currencyFormat.format(cart.total * 0.5),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo restante:'),
                        Text(currencyFormat.format(cart.total * 0.5)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Pagar Señal',
                        icon: Icons.payment,
                        onPressed: _isProcessing ? null : _submitOrder,
                        isLoading: _isProcessing,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

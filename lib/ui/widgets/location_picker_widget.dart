import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/app_colors.dart';

/// Map location picker widget for delivery address
class LocationPickerWidget extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  const LocationPickerWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    -12.0464,
    -77.0428,
  ); // Lima, Peru default
  final TextEditingController _addressController = TextEditingController();

  // Store location (example coordinates)
  static const LatLng storeLocation = LatLng(-12.0464, -77.0428);

  @override
  void dispose() {
    _mapController?.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  void _goToStoreLocation() {
    setState(() {
      _selectedLocation = storeLocation;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(storeLocation, 15),
    );
  }

  void _confirmLocation() {
    widget.onLocationSelected(_selectedLocation, _addressController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmLocation,
            tooltip: 'Confirmar ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (position) {
              setState(() {
                _selectedLocation = position;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                },
              ),
              Marker(
                markerId: const MarkerId('store'),
                position: storeLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: const InfoWindow(
                  title: 'DulceHora',
                  snippet: 'Nuestra tienda',
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // Address input
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Ingresa la dirección completa',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ),

          // Action buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'store',
                  onPressed: _goToStoreLocation,
                  backgroundColor: AppColors.info,
                  child: const Icon(Icons.store),
                  tooltip: 'Ver ubicación de la tienda',
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: _getCurrentLocation,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location),
                  tooltip: 'Mi ubicación',
                ),
              ],
            ),
          ),

          // Coordinates display
          Positioned(
            bottom: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}\n'
                  'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

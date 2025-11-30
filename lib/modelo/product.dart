/// Product model representing a pastry/cake product in the catalog
class Product {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "Cakes", "Cupcakes", "Cookies", "Pastries"
  final double basePrice;
  final Map<String, double>
  sizeMultipliers; // e.g., {"Small": 1.0, "Medium": 1.5, "Large": 2.0}
  final Map<String, double>
  flavorPrices; // e.g., {"Vanilla": 0, "Chocolate": 5, "Red Velvet": 10}
  final String imageUrl;
  final List<String> occasions; // e.g., ["birthday", "wedding", "anniversary"]
  final bool isAvailable;
  final bool allowsCustomization;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.sizeMultipliers,
    required this.flavorPrices,
    required this.imageUrl,
    required this.occasions,
    this.isAvailable = true,
    this.allowsCustomization = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calculate price based on size and flavor
  double calculatePrice(String size, String flavor) {
    final sizeMultiplier = sizeMultipliers[size] ?? 1.0;
    final flavorPrice = flavorPrices[flavor] ?? 0.0;
    return (basePrice * sizeMultiplier) + flavorPrice;
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'basePrice': basePrice,
      'sizeMultipliers': sizeMultipliers,
      'flavorPrices': flavorPrices,
      'imageUrl': imageUrl,
      'occasions': occasions,
      'isAvailable': isAvailable,
      'allowsCustomization': allowsCustomization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (Firestore)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      sizeMultipliers: Map<String, double>.from(
        (json['sizeMultipliers'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      flavorPrices: Map<String, double>.from(
        (json['flavorPrices'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      imageUrl: json['imageUrl'] as String,
      occasions: List<String>.from(json['occasions'] as List),
      isAvailable: json['isAvailable'] as bool? ?? true,
      allowsCustomization: json['allowsCustomization'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? basePrice,
    Map<String, double>? sizeMultipliers,
    Map<String, double>? flavorPrices,
    String? imageUrl,
    List<String>? occasions,
    bool? isAvailable,
    bool? allowsCustomization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      sizeMultipliers: sizeMultipliers ?? this.sizeMultipliers,
      flavorPrices: flavorPrices ?? this.flavorPrices,
      imageUrl: imageUrl ?? this.imageUrl,
      occasions: occasions ?? this.occasions,
      isAvailable: isAvailable ?? this.isAvailable,
      allowsCustomization: allowsCustomization ?? this.allowsCustomization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Price configuration model for admin to manage pricing by size and flavor
class PriceConfig {
  final String id;
  final String productId;
  final Map<String, double>
  sizeMultipliers; // e.g., {"Pequeño": 1.0, "Mediano": 1.5, "Grande": 2.0}
  final Map<String, double> flavorPrices; // Additional cost for flavors
  final DateTime updatedAt;
  final String updatedBy; // User ID who made the change

  PriceConfig({
    required this.id,
    required this.productId,
    required this.sizeMultipliers,
    required this.flavorPrices,
    DateTime? updatedAt,
    required this.updatedBy,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sizeMultipliers': sizeMultipliers,
      'flavorPrices': flavorPrices,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  /// Create from JSON (Firestore)
  factory PriceConfig.fromJson(Map<String, dynamic> json) {
    return PriceConfig(
      id: json['id'] as String,
      productId: json['productId'] as String,
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
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );
  }

  /// Create a copy with updated fields
  PriceConfig copyWith({
    String? id,
    String? productId,
    Map<String, double>? sizeMultipliers,
    Map<String, double>? flavorPrices,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return PriceConfig(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sizeMultipliers: sizeMultipliers ?? this.sizeMultipliers,
      flavorPrices: flavorPrices ?? this.flavorPrices,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

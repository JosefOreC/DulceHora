/// Customization details for a cake/pastry order
class Customization {
  final String? customText;
  final String? adornmentType; // Changed from decorationType
  final String? specialInstructions;

  Customization({
    this.customText,
    this.adornmentType,
    this.specialInstructions,
  });

  /// Calculate customization price
  double calculatePrice() {
    double price = 0.0;
    if (customText != null && customText!.isNotEmpty) {
      price += 5.0; // Base text price
    }
    if (adornmentType != null && adornmentType!.isNotEmpty) {
      price += 10.0; // Adornment price
    }
    return price;
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'customText': customText,
      'adornmentType': adornmentType,
      'specialInstructions': specialInstructions,
    };
  }

  /// Create from JSON (Firestore)
  factory Customization.fromJson(Map<String, dynamic> json) {
    return Customization(
      customText: json['customText'] as String?,
      adornmentType: json['adornmentType'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  /// Create a copy with updated fields
  Customization copyWith({
    String? customText,
    String? adornmentType,
    String? specialInstructions,
  }) {
    return Customization(
      customText: customText ?? this.customText,
      adornmentType: adornmentType ?? this.adornmentType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

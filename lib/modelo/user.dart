/// User model representing customers and employees
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (Firestore)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is an employee
  bool get isEmployee => role != UserRole.customer;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;
}

/// User roles in the system
enum UserRole {
  customer, // Regular customers who place orders
  pastryChef, // Pastelero - views production calendar
  manager, // Encargado - marks orders ready, assigns delivery
  admin, // Admin - manages prices
  analyst, // Gestor - views reports
}

/// Extension for user-friendly role names
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Cliente';
      case UserRole.pastryChef:
        return 'Pastelero';
      case UserRole.manager:
        return 'Encargado';
      case UserRole.admin:
        return 'Administrador';
      case UserRole.analyst:
        return 'Gestor';
    }
  }
}

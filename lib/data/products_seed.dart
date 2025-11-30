import '../modelo/product.dart';

/// Seed data for products in the DulceHora catalog
/// Contains 15+ products with complete information
class ProductsSeed {
  static List<Product> getProducts() {
    return [
      // CAKES - Pasteles
      Product(
        id: 'prod_001',
        name: 'Pastel de Chocolate Clásico',
        description:
            'Delicioso pastel de chocolate con frosting de chocolate y decoración de virutas de chocolate. Perfecto para celebraciones.',
        category: 'Pasteles',
        basePrice: 350.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {
          'Chocolate': 0.0,
          'Chocolate Belga': 50.0,
          'Chocolate con Menta': 40.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
        occasions: ['cumpleaños', 'aniversario', 'celebración'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_002',
        name: 'Pastel de Vainilla Elegante',
        description:
            'Pastel de vainilla suave con frosting de crema de mantequilla. Ideal para bodas y eventos especiales.',
        category: 'Pasteles',
        basePrice: 380.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
          'Extra Grande (25-30 personas)': 2.5,
        },
        flavorPrices: {
          'Vainilla': 0.0,
          'Vainilla Francesa': 40.0,
          'Vainilla con Almendra': 45.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1535141192574-5d4897c12636?w=800',
        occasions: ['boda', 'aniversario', 'quinceañera'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_003',
        name: 'Red Velvet Premium',
        description:
            'Pastel red velvet con frosting de queso crema. Un clásico americano con un toque especial.',
        category: 'Pasteles',
        basePrice: 420.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {
          'Red Velvet Clásico': 0.0,
          'Red Velvet con Chocolate Blanco': 60.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=800',
        occasions: ['cumpleaños', 'san valentín', 'aniversario'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_004',
        name: 'Pastel de Zanahoria',
        description:
            'Pastel de zanahoria con nueces y frosting de queso crema. Decorado con zanahorias de mazapán.',
        category: 'Pasteles',
        basePrice: 390.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {
          'Zanahoria Clásica': 0.0,
          'Zanahoria con Piña': 35.0,
          'Zanahoria con Pasas': 30.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=800',
        occasions: ['cumpleaños', 'celebración', 'día de la madre'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_005',
        name: 'Pastel de Tres Leches',
        description:
            'Tradicional pastel tres leches, suave y húmedo, cubierto con merengue italiano.',
        category: 'Pasteles',
        basePrice: 360.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {
          'Tres Leches Clásico': 0.0,
          'Tres Leches con Coco': 40.0,
          'Tres Leches con Café': 45.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1588195538326-c5b1e5b4e0b5?w=800',
        occasions: ['cumpleaños', 'celebración', 'día del padre'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_006',
        name: 'Pastel de Fresa con Crema',
        description:
            'Pastel de vainilla relleno de fresas frescas y crema batida. Decorado con fresas naturales.',
        category: 'Pasteles',
        basePrice: 400.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {
          'Fresa Natural': 0.0,
          'Fresa con Chocolate Blanco': 55.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=800',
        occasions: ['cumpleaños', 'día de la madre', 'baby shower'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      // CUPCAKES
      Product(
        id: 'prod_007',
        name: 'Cupcakes Gourmet Surtidos',
        description:
            'Docena de cupcakes gourmet en sabores variados: chocolate, vainilla, red velvet y limón.',
        category: 'Cupcakes',
        basePrice: 180.00,
        sizeMultipliers: {
          '6 unidades': 0.6,
          '12 unidades': 1.0,
          '24 unidades': 1.8,
        },
        flavorPrices: {
          'Surtido Clásico': 0.0,
          'Surtido Premium': 40.0,
          'Sabores Especiales': 60.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7?w=800',
        occasions: ['cumpleaños', 'baby shower', 'corporativo'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_008',
        name: 'Cupcakes de Chocolate Intenso',
        description:
            'Cupcakes de chocolate con frosting de ganache de chocolate. Para los amantes del chocolate.',
        category: 'Cupcakes',
        basePrice: 200.00,
        sizeMultipliers: {
          '6 unidades': 0.6,
          '12 unidades': 1.0,
          '24 unidades': 1.8,
        },
        flavorPrices: {'Chocolate': 0.0, 'Chocolate Belga': 50.0},
        imageUrl:
            'https://images.unsplash.com/photo-1603532648955-039310d9ed75?w=800',
        occasions: ['cumpleaños', 'celebración', 'corporativo'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      // GALLETAS - Cookies
      Product(
        id: 'prod_009',
        name: 'Galletas Decoradas Personalizadas',
        description:
            'Galletas de mantequilla decoradas con glaseado real. Diseños personalizados según ocasión.',
        category: 'Galletas',
        basePrice: 250.00,
        sizeMultipliers: {
          '12 unidades': 1.0,
          '24 unidades': 1.8,
          '36 unidades': 2.5,
        },
        flavorPrices: {'Vainilla': 0.0, 'Chocolate': 30.0, 'Limón': 25.0},
        imageUrl:
            'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800',
        occasions: ['baby shower', 'boda', 'cumpleaños', 'corporativo'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_010',
        name: 'Galletas Chispas de Chocolate',
        description:
            'Clásicas galletas con chispas de chocolate. Suaves por dentro, crujientes por fuera.',
        category: 'Galletas',
        basePrice: 150.00,
        sizeMultipliers: {'12 unidades': 1.0, '24 unidades': 1.8},
        flavorPrices: {'Chispas de Chocolate': 0.0, 'Doble Chocolate': 30.0},
        imageUrl:
            'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=800',
        occasions: ['celebración', 'regalo', 'corporativo'],
        isAvailable: true,
        allowsCustomization: false,
      ),

      // POSTRES ESPECIALES
      Product(
        id: 'prod_011',
        name: 'Cheesecake de Frutos Rojos',
        description:
            'Cheesecake cremoso con base de galleta y topping de frutos rojos frescos.',
        category: 'Postres Especiales',
        basePrice: 380.00,
        sizeMultipliers: {
          'Individual': 0.3,
          'Pequeño (6-8 porciones)': 1.0,
          'Grande (12-15 porciones)': 1.6,
        },
        flavorPrices: {'Frutos Rojos': 0.0, 'Fresa': 30.0, 'Arándano': 40.0},
        imageUrl:
            'https://images.unsplash.com/photo-1533134242116-8e9b8f6a0e8e?w=800',
        occasions: ['aniversario', 'celebración', 'día de la madre'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_012',
        name: 'Tiramisú Artesanal',
        description:
            'Tiramisú italiano tradicional con café espresso y mascarpone. Un clásico irresistible.',
        category: 'Postres Especiales',
        basePrice: 350.00,
        sizeMultipliers: {
          'Individual': 0.3,
          'Pequeño (6 porciones)': 1.0,
          'Grande (12 porciones)': 1.7,
        },
        flavorPrices: {'Clásico': 0.0, 'Con Amaretto': 50.0},
        imageUrl:
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800',
        occasions: ['aniversario', 'celebración', 'corporativo'],
        isAvailable: true,
        allowsCustomization: false,
      ),

      // PANES DULCES
      Product(
        id: 'prod_013',
        name: 'Roscón de Reyes',
        description:
            'Tradicional roscón decorado con frutas confitadas. Disponible relleno de crema o nata.',
        category: 'Panes Dulces',
        basePrice: 280.00,
        sizeMultipliers: {
          'Pequeño (4-6 personas)': 1.0,
          'Mediano (8-10 personas)': 1.4,
          'Grande (12-15 personas)': 1.8,
        },
        flavorPrices: {
          'Sin Relleno': 0.0,
          'Relleno de Crema': 40.0,
          'Relleno de Nata': 45.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=800',
        occasions: ['día de reyes', 'navidad', 'celebración'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_014',
        name: 'Pan de Elote',
        description:
            'Pan de elote casero, húmedo y esponjoso. Sabor tradicional mexicano.',
        category: 'Panes Dulces',
        basePrice: 180.00,
        sizeMultipliers: {'Pequeño': 1.0, 'Mediano': 1.3, 'Grande': 1.6},
        flavorPrices: {'Natural': 0.0, 'Con Queso Crema': 35.0},
        imageUrl:
            'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=800',
        occasions: ['celebración', 'regalo', 'día de la madre'],
        isAvailable: true,
        allowsCustomization: false,
      ),

      Product(
        id: 'prod_015',
        name: 'Brownies Gourmet',
        description:
            'Brownies de chocolate densos y fudgy. Disponibles con nueces o chocolate blanco.',
        category: 'Postres Especiales',
        basePrice: 200.00,
        sizeMultipliers: {
          '6 unidades': 1.0,
          '12 unidades': 1.8,
          '24 unidades': 3.2,
        },
        flavorPrices: {
          'Chocolate Clásico': 0.0,
          'Con Nueces': 30.0,
          'Chocolate Blanco': 40.0,
          'Triple Chocolate': 50.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800',
        occasions: ['cumpleaños', 'celebración', 'corporativo', 'regalo'],
        isAvailable: true,
        allowsCustomization: false,
      ),

      // BONUS PRODUCTS
      Product(
        id: 'prod_016',
        name: 'Pastel de Limón',
        description:
            'Pastel de limón fresco con frosting de crema de limón. Ligero y refrescante.',
        category: 'Pasteles',
        basePrice: 370.00,
        sizeMultipliers: {
          'Pequeño (6-8 personas)': 1.0,
          'Mediano (10-12 personas)': 1.5,
          'Grande (15-20 personas)': 2.0,
        },
        flavorPrices: {'Limón': 0.0, 'Limón con Merengue': 45.0},
        imageUrl:
            'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=800',
        occasions: ['cumpleaños', 'baby shower', 'celebración'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_017',
        name: 'Macarons Franceses',
        description:
            'Delicados macarons franceses en sabores variados. Perfectos para eventos elegantes.',
        category: 'Postres Especiales',
        basePrice: 280.00,
        sizeMultipliers: {
          '12 unidades': 1.0,
          '24 unidades': 1.9,
          '36 unidades': 2.7,
        },
        flavorPrices: {'Surtido Clásico': 0.0, 'Sabores Premium': 60.0},
        imageUrl:
            'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=800',
        occasions: ['boda', 'quinceañera', 'baby shower', 'corporativo'],
        isAvailable: true,
        allowsCustomization: true,
      ),

      Product(
        id: 'prod_018',
        name: 'Pastel de Boda Personalizado',
        description:
            'Pastel de boda de múltiples pisos, completamente personalizable. Consultar diseño.',
        category: 'Pasteles',
        basePrice: 1200.00,
        sizeMultipliers: {
          '2 pisos (30-40 personas)': 1.0,
          '3 pisos (50-70 personas)': 1.6,
          '4 pisos (80-100 personas)': 2.2,
        },
        flavorPrices: {
          'Vainilla': 0.0,
          'Chocolate': 100.0,
          'Red Velvet': 150.0,
          'Combinado': 120.0,
        },
        imageUrl:
            'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=800',
        occasions: ['boda'],
        isAvailable: true,
        allowsCustomization: true,
      ),
    ];
  }

  /// Get products by category
  static List<Product> getProductsByCategory(String category) {
    return getProducts().where((p) => p.category == category).toList();
  }

  /// Get all available categories
  static List<String> getCategories() {
    return getProducts().map((p) => p.category).toSet().toList()..sort();
  }

  /// Get products by occasion
  static List<Product> getProductsByOccasion(String occasion) {
    return getProducts()
        .where((p) => p.occasions.contains(occasion.toLowerCase()))
        .toList();
  }
}

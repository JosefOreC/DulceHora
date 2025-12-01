import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../modelo/product.dart';
import '../screens/product_detail_screen.dart';

/// Widget that shows product recommendations based on upcoming occasions
class OccasionRecommendations extends StatelessWidget {
  final List<Product> products;

  const OccasionRecommendations({super.key, required this.products});

  List<Map<String, dynamic>> _getUpcomingOccasions() {
    final now = DateTime.now();
    final occasions = <Map<String, dynamic>>[];

    // Check for occasions in the next 60 days
    for (int i = 0; i < 60; i++) {
      final date = now.add(Duration(days: i));
      final occasion = _getOccasionForDate(date);

      if (occasion != null) {
        // Avoid duplicate occasions (e.g. if an occasion spans multiple days)
        if (!occasions.any((o) => o['name'] == occasion['name'])) {
          occasions.add({
            'name': occasion['name'],
            'date': date,
            'icon': occasion['icon'],
            'color': occasion['color'],
            'tags': occasion['tags'], // Changed from categories to tags
            'daysUntil': i,
            'description': occasion['description'],
          });
        }
      }
    }

    return occasions.take(3).toList(); // Show top 3 upcoming occasions
  }

  Map<String, dynamic>? _getOccasionForDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    // Valentine's Day
    if (month == 2 && day == 14) {
      return {
        'name': 'Día de San Valentín',
        'description': '¡Celebra el amor con nuestros dulces especiales!',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'tags': ['san valentin', 'amor', 'romantico', 'corazon'],
      };
    }

    // Mother's Day (second Sunday of May)
    if (month == 5 && _isSecondSunday(date)) {
      return {
        'name': 'Día de la Madre',
        'description': 'El regalo perfecto para mamá',
        'icon': Icons.volunteer_activism,
        'color': Colors.purple,
        'tags': ['dia de la madre', 'mama', 'mujer'],
      };
    }

    // Father's Day (third Sunday of June)
    if (month == 6 && _isThirdSunday(date)) {
      return {
        'name': 'Día del Padre',
        'description': 'Sorprende a papá en su día',
        'icon': Icons.workspace_premium,
        'color': Colors.blue,
        'tags': ['dia del padre', 'papa', 'hombre'],
      };
    }

    // Independence Day (Peru)
    if (month == 7 && (day == 28 || day == 29)) {
      return {
        'name': 'Fiestas Patrias',
        'description': '¡Celebra el orgullo de ser peruano!',
        'icon': Icons.flag,
        'color': Colors.red,
        'tags': ['fiestas patrias', 'peru', 'blanquirroja'],
      };
    }

    // Halloween
    if (month == 10 && day == 31) {
      return {
        'name': 'Halloween',
        'description': 'Dulces terroríficamente deliciosos',
        'icon': Icons.nightlight_round,
        'color': Colors.orange,
        'tags': ['halloween', 'terror', 'calabaza'],
      };
    }

    // Christmas
    if (month == 12 && day >= 20 && day <= 25) {
      return {
        'name': 'Navidad',
        'description': 'Comparte la dulzura de la Navidad',
        'icon': Icons.ac_unit,
        'color': Colors.green,
        'tags': ['navidad', 'fiestas', 'regalo'],
      };
    }

    // New Year
    if ((month == 12 && day >= 28) || (month == 1 && day == 1)) {
      return {
        'name': 'Año Nuevo',
        'description': 'Recibe el año nuevo con dulzura',
        'icon': Icons.celebration,
        'color': Colors.amber,
        'tags': ['año nuevo', 'fiesta', 'celebracion'],
      };
    }

    return null;
  }

  bool _isSecondSunday(DateTime date) {
    if (date.weekday != DateTime.sunday) return false;
    final firstDay = DateTime(date.year, date.month, 1);
    final firstSunday = firstDay.weekday == DateTime.sunday
        ? firstDay
        : firstDay.add(Duration(days: (7 - firstDay.weekday) % 7));
    final secondSunday = firstSunday.add(const Duration(days: 7));
    return date.day == secondSunday.day;
  }

  bool _isThirdSunday(DateTime date) {
    if (date.weekday != DateTime.sunday) return false;
    final firstDay = DateTime(date.year, date.month, 1);
    final firstSunday = firstDay.weekday == DateTime.sunday
        ? firstDay
        : firstDay.add(Duration(days: (7 - firstDay.weekday) % 7));
    final thirdSunday = firstSunday.add(const Duration(days: 14));
    return date.day == thirdSunday.day;
  }

  List<Product> _getRecommendedProducts(List<String> tags) {
    // Filter products that match ANY of the occasion tags
    // The check is case-insensitive
    return products
        .where((p) {
          if (p.occasions.isEmpty) return false;

          return p.occasions.any((productTag) {
            return tags.any(
              (occasionTag) =>
                  productTag.toLowerCase().contains(
                    occasionTag.toLowerCase(),
                  ) ||
                  occasionTag.toLowerCase().contains(productTag.toLowerCase()),
            );
          });
        })
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingOccasions = _getUpcomingOccasions();

    if (upcomingOccasions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: upcomingOccasions.map((occasion) {
        final recommendedProducts = _getRecommendedProducts(
          List<String>.from(occasion['tags']),
        );

        if (recommendedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        final daysUntil = occasion['daysUntil'] as int;
        final occasionColor = occasion['color'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Occasion Header with improved design
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      occasionColor.withOpacity(0.9),
                      occasionColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: occasionColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        occasion['icon'],
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            occasion['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            occasion['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              daysUntil == 0
                                  ? '¡Es hoy!'
                                  : daysUntil == 1
                                  ? '¡Es mañana!'
                                  : 'Faltan $daysUntil días',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Products List
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Recomendados para ti',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 150, // Increased height for better card layout
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedProducts.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = recommendedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        width: 140, // Fixed width
                        margin: const EdgeInsets.only(right: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: occasionColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: occasionColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image placeholder or actual image
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: occasionColor.withOpacity(0.1),
                                  ),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.cake,
                                                  color: occasionColor
                                                      .withOpacity(0.5),
                                                  size: 40,
                                                );
                                              },
                                        )
                                      : Icon(
                                          Icons.cake,
                                          color: occasionColor.withOpacity(0.5),
                                          size: 40,
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'S/${product.basePrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: occasionColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

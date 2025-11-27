import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getCategoryIcon(),
      size: size,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
      case 'groceries':
        return Icons.restaurant;
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'utilities':
      case 'electricity':
      case 'water':
      case 'gas':
        return Icons.lightbulb;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
      case 'income':
        return Icons.account_balance_wallet;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'internet':
      case 'phone':
      case 'mobile':
        return Icons.wifi;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.category;
    }
  }
}

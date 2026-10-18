import 'package:flutter/material.dart';

class CategoryIconHelper {
  static Widget getIcon(String? iconName, {Color? color, double size = 24}) {
    if (iconName == null || iconName.isEmpty) {
      return Icon(Icons.category, color: color, size: size);
    }

    final icon = _getIconData(iconName);
    return Icon(icon, color: color, size: size);
  }

  /// Get icon based on category name (for fallback when icon field is not available)
  static Widget getIconByName(String? categoryName,
      {Color? color, double size = 24}) {
    if (categoryName == null || categoryName.isEmpty) {
      return Icon(Icons.category, color: color, size: size);
    }

    final icon = _getIconDataByName(categoryName);
    return Icon(icon, color: color, size: size);
  }

  static IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'shirt':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'car':
        return Icons.directions_car;
      case 'sparkles':
        return Icons.auto_awesome;
      case 'gem':
        return Icons.diamond;
      case 'wrench':
        return Icons.build;
      case 'smartphone':
        return Icons.smartphone;
      case 'heartpulse':
        return Icons.favorite;
      case 'utensils':
        return Icons.restaurant;
      case 'tractor':
        return Icons.agriculture;
      case 'palette':
        return Icons.palette;
      case 'briefcase':
        return Icons.business_center;
      case 'dog':
        return Icons.pets;
      case 'heart':
        return Icons.favorite;
      case 'key':
        return Icons.vpn_key;
      case 'bookopen':
        return Icons.menu_book;
      case 'building2':
        return Icons.business;
      case 'shield':
        return Icons.shield;
      case 'plane':
        return Icons.flight;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.category;
    }
  }

  static IconData _getIconDataByName(String categoryName) {
    final lowerName = categoryName.toLowerCase();

    // Check if name contains keywords
    if (lowerName.contains('fashion') ||
        lowerName.contains('clothing') ||
        lowerName.contains('clothes')) {
      return Icons.checkroom; // shirt icon
    } else if (lowerName.contains('real estate') ||
        lowerName.contains('estate') ||
        lowerName.contains('property')) {
      return Icons.home;
    } else if (lowerName.contains('vehicle') ||
        lowerName.contains('car') ||
        lowerName.contains('auto')) {
      return Icons.directions_car;
    } else if (lowerName.contains('perfume') ||
        lowerName.contains('cosmetic') ||
        lowerName.contains('beauty')) {
      return Icons.diamond; // sparkles/diamond for cosmetics
    } else if (lowerName.contains('jewelry') ||
        lowerName.contains('jewellery') ||
        lowerName.contains('watch')) {
      return Icons.diamond; // gem icon
    } else if (lowerName.contains('spare') ||
        lowerName.contains('part') ||
        lowerName.contains('accessor') ||
        lowerName.contains('tool')) {
      return Icons.build; // wrench icon
    } else if (lowerName.contains('electronic') ||
        lowerName.contains('phone') ||
        lowerName.contains('second hand')) {
      return Icons.smartphone;
    } else if (lowerName.contains('health') ||
        lowerName.contains('personal care') ||
        lowerName.contains('medical')) {
      return Icons.favorite; // heart icon
    } else if (lowerName.contains('food') ||
        lowerName.contains('restaurant') ||
        lowerName.contains('dining')) {
      return Icons.restaurant;
    } else if (lowerName.contains('farm') ||
        lowerName.contains('agriculture') ||
        lowerName.contains('tractor')) {
      return Icons.agriculture;
    } else if (lowerName.contains('art') ||
        lowerName.contains('paint') ||
        lowerName.contains('design')) {
      return Icons.palette;
    } else if (lowerName.contains('business') ||
        lowerName.contains('office') ||
        lowerName.contains('work')) {
      return Icons.business_center;
    } else if (lowerName.contains('pet') || lowerName.contains('animal')) {
      return Icons.pets;
    } else if (lowerName.contains('book') ||
        lowerName.contains('education') ||
        lowerName.contains('study')) {
      return Icons.menu_book;
    } else if (lowerName.contains('building') ||
        lowerName.contains('construction')) {
      return Icons.business;
    } else if (lowerName.contains('security') ||
        lowerName.contains('safety') ||
        lowerName.contains('insurance')) {
      return Icons.shield;
    } else if (lowerName.contains('travel') ||
        lowerName.contains('flight') ||
        lowerName.contains('tourism')) {
      return Icons.flight;
    } else {
      return Icons.category; // default
    }
  }

  static Color getCategoryColor(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return const Color(0xFFF39200); // Default orange
    }

    switch (iconName.toLowerCase()) {
      case 'shirt':
        return const Color(0xFFFF6B35); // Orange
      case 'home':
        return const Color(0xFF4A90E2); // Blue
      case 'sparkles':
        return const Color(0xFF9B59B6); // Purple
      case 'car':
        return const Color(0xFF2ECC71); // Green
      case 'gem':
        return const Color(0xFFE74C3C); // Red
      case 'wrench':
        return const Color(0xFF3498DB); // Blue
      case 'smartphone':
        return const Color(0xFFFF6B35); // Orange
      case 'heartpulse':
        return const Color(0xFF2ECC71); // Green
      case 'utensils':
        return const Color(0xFFF39C12); // Orange
      case 'tractor':
        return const Color(0xFF16A085); // Teal
      case 'palette':
        return const Color(0xFFE67E22); // Orange
      case 'briefcase':
        return const Color(0xFF34495E); // Dark Blue
      case 'dog':
        return const Color(0xFF95A5A6); // Gray
      case 'heart':
        return const Color(0xFFE91E63); // Pink
      case 'key':
        return const Color(0xFF9B59B6); // Purple
      case 'bookopen':
        return const Color(0xFF3498DB); // Blue
      case 'building2':
        return const Color(0xFF7F8C8D); // Gray
      case 'shield':
        return const Color(0xFF27AE60); // Green
      case 'plane':
        return const Color(0xFF1ABC9C); // Teal
      case 'settings':
        return const Color(0xFF95A5A6); // Gray
      default:
        return const Color(0xFFF39200); // Default orange
    }
  }

  /// Get color based on category name (for fallback)
  static Color getColorByName(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      return const Color(0xFFF39200); // Default orange
    }

    final lowerName = categoryName.toLowerCase();

    if (lowerName.contains('fashion') || lowerName.contains('clothing')) {
      return const Color(0xFFFF6B35); // Orange
    } else if (lowerName.contains('real estate') ||
        lowerName.contains('estate')) {
      return const Color(0xFF4A90E2); // Blue
    } else if (lowerName.contains('vehicle') || lowerName.contains('car')) {
      return const Color(0xFF2ECC71); // Green
    } else if (lowerName.contains('perfume') ||
        lowerName.contains('cosmetic')) {
      return const Color(0xFF9B59B6); // Purple
    } else if (lowerName.contains('jewelry') || lowerName.contains('watch')) {
      return const Color(0xFFE74C3C); // Red
    } else if (lowerName.contains('spare') || lowerName.contains('accessor')) {
      return const Color(0xFF3498DB); // Blue
    } else if (lowerName.contains('electronic') ||
        lowerName.contains('second hand')) {
      return const Color(0xFFFF6B35); // Orange
    } else if (lowerName.contains('health') ||
        lowerName.contains('personal care')) {
      return const Color(0xFF2ECC71); // Green
    } else {
      return const Color(0xFFF39200); // Default orange
    }
  }
}

// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5FDF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryGreen,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class AppConstants {
  static const String appName = 'AgriLink';
  static const String appTagline = 'Connecting Farmers to Markets';
  static const String firebaseUsersCollection = 'users';
  static const String firebaseProduceCollection = 'produce';
  static const String firebaseBookingsCollection = 'bookings';
  static const String firebaseChatsCollection = 'chats';
  
  // Kenyan counties
  static const List<String> kenyanCounties = [
    // 'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Meru',
    // 'Thika', 'Kitale', 'Malindi', 'Garissa', 'Kakamega', 'Nyeri',
    // 'Machakos', 'Kitui', 'Embu', 'Nanyuki', 'Naivasha', 'Kericho'
    'Uasin Gishu', 'Trans Nzoia',
  ];
  
  // Crop types
  static const List<Map<String, dynamic>> cropTypes = [
    {'name': 'Maize', 'icon': '🌽', 'shelfLife': 180},
    {'name': 'Tomatoes', 'icon': '🍅', 'shelfLife': 14},
    {'name': 'Bananas', 'icon': '🍌', 'shelfLife': 7},
    {'name': 'Beans', 'icon': '🫘', 'shelfLife': 365},
    {'name': 'Potatoes', 'icon': '🥔', 'shelfLife': 90},
    {'name': 'Coffee', 'icon': '☕', 'shelfLife': 365},
    {'name': 'Tea', 'icon': '🍃', 'shelfLife': 365},
    {'name': 'Avocado', 'icon': '🥑', 'shelfLife': 10},
  ];
}
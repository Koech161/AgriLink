// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import './constants.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Future<void> showLoadingDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  static String getCropIcon(String cropName) {
    final crop = AppConstants.cropTypes.firstWhere(
      (crop) => crop['name'] == cropName,
      orElse: () => {'icon': '🌱'},
    );
    return crop['icon'];
  }

  static int getCropShelfLife(String cropName) {
    final crop = AppConstants.cropTypes.firstWhere(
      (crop) => crop['name'] == cropName,
      orElse: () => {'shelfLife': 30},
    );
    return crop['shelfLife'];
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'booked':
        return AppColors.warning;
      case 'sold':
        return AppColors.primaryGreen;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
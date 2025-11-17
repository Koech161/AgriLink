// lib/utils/extensions.dart
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String formatPhone() {
    if (startsWith('0')) {
      return '+254${substring(1)}';
    }
    return this;
  }
}

extension DateTimeExtensions on DateTime {
  String formatDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String formatDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

extension DoubleExtensions on double {
  String formatCurrency() {
    return NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 2,
    ).format(this);
  }

  String formatWeight() {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)} tonnes';
    }
    return '${toStringAsFixed(0)} kgs';
  }
}


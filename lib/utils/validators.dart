// lib/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    final phoneRegex = RegExp(r'^[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-+]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }
    final quantity = double.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Please enter a valid quantity';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter price';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Please enter a valid price';
    }
    return null;
  }
}
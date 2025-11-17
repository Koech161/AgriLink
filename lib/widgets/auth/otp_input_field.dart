// lib/widgets/auth/otp_input_field.dart
import 'package:flutter/material.dart';


class OTPInputField extends StatelessWidget {
  final TextEditingController controller;

  const OTPInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: '000000',
        hintStyle: TextStyle(
          fontSize: 24,
          letterSpacing: 8,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
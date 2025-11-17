// lib/widgets/auth/phone_input_field.dart
import 'package:flutter/material.dart';


class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '07XX XXX XXX',
        prefixIcon: Icon(Icons.phone),
        prefixText: '+254 ',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length < 9) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }
}
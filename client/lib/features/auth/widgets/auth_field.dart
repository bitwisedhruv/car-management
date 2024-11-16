import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isObscure;
  final TextInputType keyboardType;
  // final Function validator;
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: label,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Secure text field for password input with show/hide toggle
class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;

  const SecureTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
    );
  }

  @override
  void dispose() {
    // Clear password from memory
    widget.controller.clear();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

/// Text widget that handles text scaling gracefully
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // If text scaling is large, adjust overflow behavior
    if (textScaleFactor > 1.5) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
        softWrap: softWrap,
      );
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Text field that handles large text scaling
class ScalableTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;

  const ScalableTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Adjust vertical padding for large text
    final verticalPadding = textScaleFactor > 1.5 ? 16.0 : 12.0;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: verticalPadding,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
    );
  }
}

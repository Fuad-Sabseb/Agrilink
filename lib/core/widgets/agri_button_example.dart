import 'package:flutter/material.dart';
import 'agri_button.dart';

/// Example usage of the AgriButton widget.
///
/// This file demonstrates how to use the different variants of AgriButton
/// in a Flutter application.
class AgriButtonExample extends StatefulWidget {
  const AgriButtonExample({super.key});

  @override
  State<AgriButtonExample> createState() => _AgriButtonExampleState();
}

class _AgriButtonExampleState extends State<AgriButtonExample> {
  bool _isLoading = false;

  void _handlePress() {
    setState(() {
      _isLoading = true;
    });

    // Simulate an async operation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriButton Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Primary Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AgriButton.primary(
              text: 'Primary Button',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.primary(
              text: 'Primary with Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.primary(
              text: 'Loading Button',
              isLoading: _isLoading,
              onPressed: _handlePress,
            ),
            const SizedBox(height: 8),
            const AgriButton.primary(
              text: 'Disabled Button',
              onPressed: null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Secondary Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AgriButton.secondary(
              text: 'Secondary Button',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.secondary(
              text: 'Secondary with Icon',
              icon: Icons.edit,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            const AgriButton.secondary(
              text: 'Disabled Secondary',
              onPressed: null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Text Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AgriButton.text(
              text: 'Text Button',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.text(
              text: 'Text with Icon',
              icon: Icons.info_outline,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            const AgriButton.text(
              text: 'Disabled Text',
              onPressed: null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Custom Color Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AgriButton.primary(
              text: 'Custom Green',
              customColor: Colors.green,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.secondary(
              text: 'Custom Blue',
              customColor: Colors.blue,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AgriButton.text(
              text: 'Custom Orange',
              customColor: Colors.orange,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

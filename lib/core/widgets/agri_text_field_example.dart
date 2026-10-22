import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agri_text_field.dart';
import '../theme/tokens.dart';

/// Example usage of AgriTextField widget
/// 
/// This file demonstrates various ways to use the AgriTextField widget
/// in forms and input scenarios across the AgriLink app.
class AgriTextFieldExample extends StatefulWidget {
  const AgriTextFieldExample({super.key});

  @override
  State<AgriTextFieldExample> createState() => _AgriTextFieldExampleState();
}

class _AgriTextFieldExampleState extends State<AgriTextFieldExample> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedLocation;

  @override
  void dispose() {
    _farmNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form validated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriTextField Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Basic Text Fields
              Text(
                'Basic Text Fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Farm Name',
                hint: 'Enter your farm name',
                controller: _farmNameController,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Simple Field',
                hint: 'Type something...',
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 2: Text Fields with Validation
              Text(
                'Text Fields with Validation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Email Address',
                hint: 'farmer@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Phone Number',
                hint: '+251 123 456 789',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefix: const Icon(Icons.phone_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 3: Number Input Fields
              Text(
                'Number Input Fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Price per Kg',
                hint: '0.00',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefix: const Text(
                  'ETB  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Quantity (Kg)',
                hint: '0',
                keyboardType: TextInputType.number,
                prefix: const Icon(Icons.inventory_2_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 4: Password Fields
              Text(
                'Password Fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                prefix: const Icon(Icons.lock_outlined),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 5: Multiline Text Fields
              Text(
                'Multiline Text Fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Description',
                hint: 'Describe your produce in detail',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Notes',
                hint: 'Add any additional notes here',
                maxLines: 3,
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 6: Read-Only Fields (Pickers)
              Text(
                'Read-Only Fields (Pickers)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Location',
                hint: 'Select location',
                readOnly: true,
                initialValue: _selectedLocation,
                suffix: const Icon(Icons.location_on),
                onTap: () {
                  // Open location picker
                  setState(() {
                    _selectedLocation = 'Jimma, Ethiopia';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location picker would open here'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriTextField(
                label: 'Date',
                hint: 'Select date',
                readOnly: true,
                suffix: const Icon(Icons.calendar_today),
                onTap: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 7: Fields with Character Limits
              Text(
                'Fields with Character Limits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Short Title',
                hint: 'Max 50 characters',
                maxLength: 50,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Tweet',
                hint: 'Max 280 characters',
                maxLines: 3,
                maxLength: 280,
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 8: Disabled Fields
              Text(
                'Disabled Fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'User ID',
                initialValue: 'USR-12345',
                enabled: false,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Region',
                initialValue: 'Oromia Region',
                enabled: false,
                prefix: Icon(Icons.location_city),
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 9: Fields with Different Capitalizations
              Text(
                'Fields with Capitalization',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              const AgriTextField(
                label: 'Comment',
                hint: 'Write a comment',
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Validate Form'),
              ),
              const SizedBox(height: AppTokens.spaceM),
            ],
          ),
        ),
      ),
    );
  }
}

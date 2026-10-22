import 'package:flutter/material.dart';
import 'agri_dropdown.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// Example usage of AgriDropdown widget
/// 
/// This file demonstrates various ways to use the AgriDropdown widget
/// in forms and selection scenarios across the AgriLink app.
class AgriDropdownExample extends StatefulWidget {
  const AgriDropdownExample({super.key});

  @override
  State<AgriDropdownExample> createState() => _AgriDropdownExampleState();
}

class _AgriDropdownExampleState extends State<AgriDropdownExample> {
  final _formKey = GlobalKey<FormState>();
  
  // Simple dropdowns
  String? _selectedCrop;
  String? _selectedMarket;
  String? _selectedPayment;
  
  // Dropdown with validation
  String? _selectedRegion;
  
  // Dropdown with prefix icon
  String? _selectedTransport;
  
  // Role-specific dropdown
  String? _selectedRole;

  // Crop types for farmer
  final List<DropdownMenuItem<String>> _cropItems = const [
    DropdownMenuItem(value: 'maize', child: Text('Maize')),
    DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
    DropdownMenuItem(value: 'teff', child: Text('Teff')),
    DropdownMenuItem(value: 'barley', child: Text('Barley')),
    DropdownMenuItem(value: 'sorghum', child: Text('Sorghum')),
    DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
  ];

  // Markets in Jimma Zone
  final List<DropdownMenuItem<String>> _marketItems = const [
    DropdownMenuItem(value: 'jimma', child: Text('Jimma Town Market')),
    DropdownMenuItem(value: 'agaro', child: Text('Agaro Market')),
    DropdownMenuItem(value: 'limmu', child: Text('Limmu Genet Market')),
    DropdownMenuItem(value: 'seka', child: Text('Seka Chokorsa Market')),
  ];

  // Payment methods
  final List<DropdownMenuItem<String>> _paymentItems = const [
    DropdownMenuItem(value: 'cash', child: Text('Cash on Delivery')),
    DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
    DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
  ];

  // Ethiopian regions
  final List<DropdownMenuItem<String>> _regionItems = const [
    DropdownMenuItem(value: 'oromia', child: Text('Oromia')),
    DropdownMenuItem(value: 'amhara', child: Text('Amhara')),
    DropdownMenuItem(value: 'tigray', child: Text('Tigray')),
    DropdownMenuItem(value: 'snnpr', child: Text('SNNPR')),
  ];

  // Transport types
  final List<DropdownMenuItem<String>> _transportItems = const [
    DropdownMenuItem(value: 'truck', child: Text('Truck')),
    DropdownMenuItem(value: 'van', child: Text('Van')),
    DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
  ];

  // User roles
  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(
      value: 'farmer',
      child: Row(
        children: [
          Icon(Icons.agriculture_outlined, color: AppColors.roleFarmer, size: 20),
          SizedBox(width: 8),
          Text('Farmer'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'buyer',
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, color: AppColors.roleBuyer, size: 20),
          SizedBox(width: 8),
          Text('Buyer'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'transporter',
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: AppColors.roleTransporter, size: 20),
          SizedBox(width: 8),
          Text('Transporter'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'bureau',
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.roleBureau, size: 20),
          SizedBox(width: 8),
          Text('Bureau Officer'),
        ],
      ),
    ),
  ];

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
        title: const Text('AgriDropdown Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Simple Dropdowns
              Text(
                'Simple Dropdowns',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Select Crop Type',
                value: _selectedCrop,
                items: _cropItems,
                onChanged: (value) {
                  setState(() {
                    _selectedCrop = value;
                  });
                },
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Select Market',
                hint: 'Choose your preferred market',
                value: _selectedMarket,
                items: _marketItems,
                onChanged: (value) {
                  setState(() {
                    _selectedMarket = value;
                  });
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 2: Dropdown with Validation
              Text(
                'Dropdown with Validation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Select Region',
                hint: 'Region is required',
                value: _selectedRegion,
                items: _regionItems,
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a region';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 3: Dropdown with Prefix Icon
              Text(
                'Dropdown with Prefix Icon',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Transport Type',
                value: _selectedTransport,
                items: _transportItems,
                onChanged: (value) {
                  setState(() {
                    _selectedTransport = value;
                  });
                },
                prefixIcon: const Icon(Icons.local_shipping_outlined),
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Payment Method',
                value: _selectedPayment,
                items: _paymentItems,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value;
                  });
                },
                prefixIcon: const Icon(Icons.payment_outlined),
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 4: Role-Specific Dropdown
              Text(
                'Role-Specific Dropdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Select Your Role',
                hint: 'Choose user role',
                value: _selectedRole,
                items: _roleItems,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected role: $value'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 5: Disabled Dropdown
              Text(
                'Disabled Dropdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              AgriDropdown<String>(
                label: 'Country',
                value: 'ethiopia',
                items: const [
                  DropdownMenuItem(value: 'ethiopia', child: Text('Ethiopia')),
                ],
                onChanged: null,
                enabled: false,
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 6: Use Case - Farmer Produce Listing
              Text(
                'Use Case: Farmer Produce Listing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceM),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppTokens.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'List Your Produce',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'Crop Type',
                      hint: 'Select crop',
                      value: null,
                      items: _cropItems,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null) return 'Crop type required';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'Target Market',
                      hint: 'Where to sell',
                      value: null,
                      items: _marketItems,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null) return 'Market required';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'Preferred Payment',
                      hint: 'Payment method',
                      value: null,
                      items: _paymentItems,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.spaceXL),

              // Section 7: Use Case - Transport Request
              Text(
                'Use Case: Transport Request',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.spaceM),
              
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceM),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppTokens.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Request Transport',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'From Market',
                      hint: 'Pickup location',
                      value: null,
                      items: _marketItems,
                      onChanged: (value) {},
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'To Market',
                      hint: 'Delivery location',
                      value: null,
                      items: _marketItems,
                      onChanged: (value) {},
                      prefixIcon: const Icon(Icons.place_outlined),
                    ),
                    const SizedBox(height: AppTokens.spaceM),
                    
                    AgriDropdown<String>(
                      label: 'Vehicle Type',
                      hint: 'Select transport',
                      value: null,
                      items: _transportItems,
                      onChanged: (value) {},
                      prefixIcon: const Icon(Icons.local_shipping_outlined),
                    ),
                  ],
                ),
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

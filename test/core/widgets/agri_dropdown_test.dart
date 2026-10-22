import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/widgets/agri_dropdown.dart';

void main() {
  group('AgriDropdown Widget Tests', () {
    testWidgets('AgriDropdown renders with label and items', (WidgetTester tester) async {
      String? selectedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Select Crop',
              value: selectedValue,
              items: const [
                DropdownMenuItem(value: 'maize', child: Text('Maize')),
                DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                DropdownMenuItem(value: 'teff', child: Text('Teff')),
              ],
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      // Verify label is displayed
      expect(find.text('Select Crop'), findsOneWidget);
      
      // Verify dropdown button is present
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('AgriDropdown displays hint when no value selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Select Market',
              hint: 'Choose a market',
              value: null,
              items: const [
                DropdownMenuItem(value: 'jimma', child: Text('Jimma')),
                DropdownMenuItem(value: 'addis', child: Text('Addis Ababa')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Verify hint is displayed
      expect(find.text('Choose a market'), findsOneWidget);
    });

    testWidgets('AgriDropdown shows validation error', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AgriDropdown<String>(
                label: 'Select Crop Type',
                value: null,
                items: const [
                  DropdownMenuItem(value: 'maize', child: Text('Maize')),
                ],
                onChanged: (value) {},
                validator: (value) {
                  if (value == null) {
                    return 'Please select a crop type';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pump();

      // Verify error message is displayed
      expect(find.text('Please select a crop type'), findsOneWidget);
    });

    testWidgets('AgriDropdown can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Region',
              value: 'oromia',
              items: const [
                DropdownMenuItem(value: 'oromia', child: Text('Oromia')),
                DropdownMenuItem(value: 'amhara', child: Text('Amhara')),
              ],
              onChanged: null, // Setting to null disables the dropdown
              enabled: false,
            ),
          ),
        ),
      );

      // Verify dropdown is present
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      
      // Verify it's disabled (cannot tap to open)
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('AgriDropdown displays selected value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Crop Type',
              value: 'wheat',
              items: const [
                DropdownMenuItem(value: 'maize', child: Text('Maize')),
                DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                DropdownMenuItem(value: 'teff', child: Text('Teff')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Verify the selected value is displayed
      expect(find.text('Wheat'), findsOneWidget);
    });

    testWidgets('AgriDropdown opens menu on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Select Crop',
              value: null,
              items: const [
                DropdownMenuItem(value: 'maize', child: Text('Maize')),
                DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                DropdownMenuItem(value: 'teff', child: Text('Teff')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Tap the dropdown to open the menu
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Verify all menu items are displayed
      expect(find.text('Maize'), findsWidgets);
      expect(find.text('Wheat'), findsWidgets);
      expect(find.text('Teff'), findsWidgets);
    });

    testWidgets('AgriDropdown with prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Payment Method',
              value: null,
              prefixIcon: const Icon(Icons.payment),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Verify prefix icon is displayed
      expect(find.byIcon(Icons.payment), findsOneWidget);
    });

    testWidgets('AgriDropdown meets minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriDropdown<String>(
              label: 'Select Crop',
              value: null,
              items: const [
                DropdownMenuItem(value: 'maize', child: Text('Maize')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Find the dropdown field
      final dropdown = tester.getSize(find.byType(DropdownButtonFormField<String>));
      
      // Verify minimum height meets touch target (48dp)
      expect(dropdown.height, greaterThanOrEqualTo(48.0));
    });
  });
}

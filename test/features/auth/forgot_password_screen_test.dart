import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/screens/auth/forgot_password_screen.dart';

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      home: ForgotPasswordScreen(),
    );
  }

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('should render step 0 (phone input) initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Forgot Your Password?'), findsOneWidget);
      expect(
        find.text('Enter your registered phone number. We will send a verification OTP to reset your password.'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send Verification OTP'), findsOneWidget);
    });

    testWidgets('should validate phone input when submitting empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Send Verification OTP without entering phone
      await tester.tap(find.text('Send Verification OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your phone number'), findsOneWidget);
    });

    testWidgets('should validate phone format for invalid numbers', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '1234');
      await tester.tap(find.text('Send Verification OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('should advance to OTP step upon entering valid phone number', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '+251911234567');
      await tester.tap(find.text('Send Verification OTP'));
      
      // Pump past request delayed timer (500ms in PasswordService mock)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Should now be on step 1 (Verify OTP)
      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.text('Change Phone Number'), findsOneWidget);
    });

    testWidgets('should advance from OTP step to New Password step upon entering valid OTP', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Step 0: Phone
      await tester.enterText(find.byType(TextFormField), '0911234567');
      await tester.tap(find.text('Send Verification OTP'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Step 1: OTP
      expect(find.text('Enter Verification Code'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Step 2: New Password
      expect(find.text('Create New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Save & Reset Password'), findsOneWidget);
    });

    testWidgets('should validate password mismatch in Step 2', (tester) async {
      // Set larger screen surface to avoid overflow
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Step 0 -> Step 1
      await tester.enterText(find.byType(TextFormField), '0911234567');
      await tester.tap(find.text('Send Verification OTP'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Step 1 -> Step 2
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // In Step 2: Enter mismatched passwords
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.first, 'Password123!');
      await tester.enterText(textFields.last, 'Password999!');
      
      await tester.ensureVisible(find.text('Save & Reset Password'));
      await tester.tap(find.text('Save & Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}

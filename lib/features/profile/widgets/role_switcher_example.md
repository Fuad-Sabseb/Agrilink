# RoleSwitcher Widget Integration Guide

## Overview
The `RoleSwitcher` widget provides backend-validated role switching for users with multiple authorized roles. It displays a dropdown menu with available roles and handles the role switch flow including loading states, error handling, and navigation to role-specific dashboards.

## Features
- ✅ Only displays when user has multiple roles (`hasMultipleRoles` is true)
- ✅ Backend validation via `AuthProvider.switchRole()`
- ✅ Loading indicator during role switch
- ✅ Error handling for 403 (unauthorized) and network failures
- ✅ Automatic navigation to role-specific dashboard on success
- ✅ Consumer pattern for reactive UI updates

## Requirements Satisfied
- 4.2: Display only available roles from backend
- 4.5: Show in profile screen for multi-role users
- 4.6: Handle 403 errors with appropriate message
- 4.7: Handle network failures with user-friendly error
- 4.9: Navigate to role-specific dashboard after switch

## Usage

### Basic Integration

Add the widget to your profile screen or settings screen:

```dart
import 'package:flutter/material.dart';
import 'package:agrolink/features/profile/widgets/role_switcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // Other profile widgets
          const SizedBox(height: 16),
          
          // Role Switcher - only shows if user has multiple roles
          const RoleSwitcher(),
          
          // More profile widgets
        ],
      ),
    );
  }
}
```

### In App Drawer

```dart
Drawer(
  child: ListView(
    children: [
      // User header
      const UserAccountsDrawerHeader(/* ... */),
      
      // Navigation items
      ListTile(/* ... */),
      
      const Divider(),
      
      // Role switcher at the bottom
      const RoleSwitcher(),
    ],
  ),
)
```

## Authentication Setup

Ensure `AuthProvider` is properly initialized with role data:

```dart
// After successful login
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.fetchAvailableRoles();
```

## Dashboard Navigation

The widget automatically navigates to the appropriate dashboard based on role:

- `farmer` → `FarmerDashboardScreen()`
- `buyer` → `BuyerDashboardScreen()`
- `transporter` → `TransporterDashboardScreen()`
- `bureau_officer` → `BureauDashboardScreen(officerId: userId)`

Navigation uses `pushAndRemoveUntil` to prevent back navigation issues after role switch.

## Error Handling

The widget handles three types of errors:

### 1. Unauthorized (403)
```
"You are not authorized for this role"
```
Displayed when backend rejects the role switch.

### 2. Network Failure
```
"Cannot switch role offline. Please check your connection."
```
Displayed when network is unavailable or request times out.

### 3. Generic Errors
Any other error from the backend is displayed with the error message from `AuthProvider`.

## UI States

### Hidden State
Widget is hidden (returns `SizedBox.shrink()`) when:
- User has only one role
- No roles are available
- `hasMultipleRoles` returns false

### Normal State
Displays a Card with:
- "Switch Role" title
- Dropdown with current role selected
- Role icons for visual identification
- All available roles in the dropdown

### Loading State
During role switch:
- Dropdown is replaced with `CircularProgressIndicator`
- "Switching role..." message displayed
- User cannot interact with the widget

## Testing

The widget includes comprehensive unit tests covering:
- Conditional rendering based on role count
- Dropdown display with multiple roles
- Role names and icons
- Error handling for 403 and network errors
- State management and reactivity

Run tests with:
```bash
flutter test test/features/profile/widgets/role_switcher_test.dart
```

## Role Icons

The widget displays appropriate icons for each role:
- 🌾 Farmer: `Icons.agriculture`
- 🛒 Buyer: `Icons.shopping_cart`
- 🚚 Transporter: `Icons.local_shipping`
- 🏢 Bureau Officer: `Icons.business`

## Dependencies

Required providers:
- `AuthProvider` - Must be available in widget tree via Provider

Required screens:
- `FarmerDashboardScreen`
- `BuyerDashboardScreen`
- `TransporterDashboardScreen`
- `BureauDashboardScreen`

## Backend API Integration

The widget relies on `AuthService` methods:
- `GET /users/available-roles` - Fetch user's authorized roles
- `POST /users/switch-role` - Validate and perform role switch

These are called through `AuthProvider`:
- `authProvider.fetchAvailableRoles()`
- `authProvider.switchRole(role)`

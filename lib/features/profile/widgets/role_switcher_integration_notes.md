# RoleSwitcher Integration - Implementation Notes

## Task 6.4: Integrate RoleSwitcher into app navigation

### Implementation Summary

The RoleSwitcher widget has been successfully integrated into the ProfileScreen. The integration satisfies all requirements for task 6.4.

### Changes Made

1. **ProfileScreen Integration** (`lib/features/profile/screens/profile_screen.dart`)
   - Added import for `role_switcher.dart`
   - Inserted `RoleSwitcher()` widget into the profile screen layout
   - Positioned between profile header and personal information card
   - Widget automatically handles visibility based on `hasMultipleRoles`

### Requirements Coverage

#### ✅ Requirement 4.5: Role Switcher Display
- RoleSwitcher is added to the profile screen
- Only shows if user has multiple roles (handled internally by widget using `hasMultipleRoles` getter)
- Widget returns `SizedBox.shrink()` when user has single role or no roles

#### ✅ Requirement 4.8: Navigation Refresh
- After successful role switch, the RoleSwitcher navigates to the role-specific dashboard
- Uses `Navigator.pushAndRemoveUntil()` with `(route) => false` to clear navigation stack
- This ensures proper navigation state and prevents back navigation issues
- Role-specific dashboards:
  - `farmer` → FarmerDashboardScreen
  - `buyer` → BuyerDashboardScreen
  - `transporter` → TransporterDashboardScreen
  - `bureau_officer` → BureauDashboardScreen

#### ✅ Requirement 4.10: Role Verification from Token
- AuthProvider's `switchRole()` method calls `authService.switchRole(role)`
- Backend validates role and returns new JWT token
- Token is updated in ApiClient for all subsequent requests
- Role is verified server-side before granting access
- Client-side validation ensures role is in `availableRoles` before attempting switch

### Implementation Details

#### RoleSwitcher Widget Features
1. **Conditional Display**: Only renders when `hasMultipleRoles` is true
2. **Loading State**: Shows `CircularProgressIndicator` during role switch
3. **Error Handling**:
   - 403 Unauthorized: "You are not authorized for this role"
   - Network errors: "Cannot switch role offline. Please check your connection."
   - Generic errors: Displays the error message
4. **Success Feedback**: Shows SnackBar with success message
5. **Navigation**: Automatically navigates to role-specific dashboard on success

#### AuthProvider Role Management
1. **Available Roles**: Fetched from backend via `GET /users/available-roles`
2. **Role Switching**: Validated via `POST /users/switch-role`
3. **Token Management**: New JWT token received and stored on successful switch
4. **State Management**: Updates `currentRole` and user model on success

### Testing

#### Unit Tests
- `test/features/profile/widgets/role_switcher_test.dart`: Comprehensive widget tests
  - Conditional rendering based on `hasMultipleRoles`
  - Role display and icons
  - State management with Consumer
  - Layout and styling

#### Integration Tests
- `test/features/profile/screens/profile_screen_integration_test.dart`: Integration tests
  - RoleSwitcher visibility with multiple/single roles
  - Proper positioning in layout
  - Profile screen rendering

### App Drawer Consideration

Task 6.4 mentions "Add RoleSwitcher to profile screen or app drawer". Currently:
- ✅ **Profile Screen**: RoleSwitcher is integrated into ProfileScreen
- ❌ **App Drawer**: The app does not have a navigation drawer implemented

If a navigation drawer is added in the future, the RoleSwitcher can be easily added there by:
1. Importing the widget: `import 'package:agrolink/features/profile/widgets/role_switcher.dart';`
2. Adding it to the drawer's ListView: `const RoleSwitcher()`

The widget is designed to be reusable and will work in any context where AuthProvider is available.

### Navigation Flow

```
User Selects Role
      ↓
RoleSwitcher._handleRoleSwitch()
      ↓
AuthProvider.switchRole(newRole)
      ↓
AuthService.switchRole() → POST /users/switch-role
      ↓
Backend validates & returns new JWT
      ↓
ApiClient updates token
      ↓
AuthProvider updates currentRole & user model
      ↓
RoleSwitcher._navigateToDashboard()
      ↓
Navigator.pushAndRemoveUntil() to role-specific dashboard
      ↓
Dashboard loads with new role context
```

### Security Considerations

1. **Backend Validation**: All role switches are validated by the backend
2. **Token-Based Access**: New JWT token ensures proper authorization
3. **No Client-Side Override**: Cannot switch to unauthorized roles
4. **Network Security**: Role switch fails offline, preventing stale state

### Future Enhancements

1. **Optimistic Updates**: Could cache role-specific data to reduce loading time
2. **Role History**: Track recent role switches for analytics
3. **Quick Switch**: Add quick switch button to app bar for frequent switchers
4. **Role Permissions**: Display what features are available for each role

## Completion Status

✅ Task 6.4 is **COMPLETE**
- RoleSwitcher integrated into ProfileScreen
- Only shows if user has multiple roles
- Navigation refreshes after successful switch (navigates to role-specific dashboard)
- Role verified from token before granting access (backend validation)

import 'package:flutter/material.dart';

/// Navigation Service for programmatic navigation
/// 
/// Provides a global navigation key and helper methods for navigation
/// without requiring BuildContext.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Get the current state
  NavigatorState? get state => navigatorKey.currentState;

  /// Navigate to a named route
  Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return state?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  Future<T?>? navigateToAndClearStack<T>(String routeName, {Object? arguments}) {
    return state?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace the current route with a new route
  Future<T?>? replaceTo<T>(String routeName, {Object? arguments}) {
    return state?.pushReplacementNamed<T, T>(routeName, arguments: arguments);
  }

  /// Go back to the previous screen
  void goBack<T>([T? result]) {
    if (state?.canPop() ?? false) {
      state?.pop<T>(result);
    }
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    state?.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if we can go back
  bool canGoBack() {
    return state?.canPop() ?? false;
  }

  /// Show a snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context!);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show a dialog
  Future<T?> showDialogBox<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  /// Show a bottom sheet
  Future<T?> showBottomSheetModal<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

class SessionService {
  Box? get _sessionBox => Hive.isBoxOpen('session') ? Hive.box('session') : null;
  Box<UserModel>? get _userBox => Hive.isBoxOpen('users') ? Hive.box<UserModel>('users') : null;

  static const String _currentUserKey = 'current_user_id';

  // Check if a user is logged in
  bool get isLoggedIn => _sessionBox?.containsKey(_currentUserKey) ?? false;

  // Get current user ID
  String? get currentUserId => _sessionBox?.get(_currentUserKey);

  // Get current user object
  UserModel? get currentUser {
    final id = currentUserId;
    if (id != null) {
      return _userBox?.get(id);
    }
    return null;
  }

  // Login a user
  Future<void> login(String userId) async {
    final box = _sessionBox ?? await Hive.openBox('session');
    await box.put(_currentUserKey, userId);
  }

  // Logout
  Future<void> logout() async {
    final box = _sessionBox ?? await Hive.openBox('session');
    await box.delete(_currentUserKey);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _userNameKey = 'user_name';
  static const String _isFirstTimeKey = 'is_first_time';

  // Save user name with verification
  static Future<bool> saveUserName(String name) async {
    try {
      print('SharedPreferencesHelper: Attempting to save user name: $name');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_userNameKey, name);

      // Verify the save worked
      final verification = prefs.getString(_userNameKey);
      print('SharedPreferencesHelper: Save result: $result, Verification: $verification');

      return result && verification == name;
    } catch (e) {
      print('SharedPreferencesHelper: Error saving name: $e');
      return false;
    }
  }

  // Get user name with debugging
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_userNameKey);
      print('SharedPreferencesHelper: Retrieved user name: $name');
      return name;
    } catch (e) {
      print('SharedPreferencesHelper: Error getting name: $e');
      return null;
    }
  }

  // Check if it's first time opening app
  static Future<bool> isFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool(_isFirstTimeKey) ?? true;
      print('SharedPreferencesHelper: Is first time: $isFirst');
      return isFirst;
    } catch (e) {
      print('SharedPreferencesHelper: Error checking first time: $e');
      return true;
    }
  }

  // Set first time to false
  static Future<bool> setNotFirstTime() async {
    try {
      print('SharedPreferencesHelper: Setting not first time');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(_isFirstTimeKey, false);
      print('SharedPreferencesHelper: Set not first time result: $result');
      return result;
    } catch (e) {
      print('SharedPreferencesHelper: Error setting not first time: $e');
      return false;
    }
  }

  // Clear all data (for testing or logout)
  static Future<bool> clearAll() async {
    try {
      print('SharedPreferencesHelper: Clearing all data');
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('SharedPreferencesHelper: Error clearing data: $e');
      return false;
    }
  }

  // Debug method to check all stored values
  static Future<void> debugPrintAllValues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('=== SharedPreferences Debug ===');
      print('User Name: ${prefs.getString(_userNameKey)}');
      print('Is First Time: ${prefs.getBool(_isFirstTimeKey)}');
      print('All Keys: ${prefs.getKeys()}');
      print('===============================');
    } catch (e) {
      print('SharedPreferencesHelper: Error in debug: $e');
    }
  }
}
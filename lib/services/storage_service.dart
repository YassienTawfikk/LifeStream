import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_stream/constants/index.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Methods
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(AppConstants.userTokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(AppConstants.userTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(AppConstants.userTokenKey);
  }

  // User Data Methods
  Future<void> setUserData(String userData) async {
    await _prefs.setString(AppConstants.userDataKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(AppConstants.userDataKey);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.userDataKey);
  }

  // Auth Status Methods
  Future<void> setIsAuthenticated(bool value) async {
    await _prefs.setBool(AppConstants.isAuthenticatedKey, value);
  }

  bool getIsAuthenticated() {
    return _prefs.getBool(AppConstants.isAuthenticatedKey) ?? false;
  }

  // Theme Methods
  Future<void> setThemeMode(String theme) async {
    await _prefs.setString(AppConstants.themeKey, theme);
  }

  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeKey);
  }

  // Logout (Clear All)
  Future<void> logout() async {
    await _prefs.clear();
  }
}

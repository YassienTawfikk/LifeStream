import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_stream/constants/index.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class StorageService {
  late SharedPreferences _prefs;

  // Simple hardcoded key for "easiest" encryption as requested.
  // In a real app, use SecureStorage to store the key.
  static final _key = encrypt.Key.fromUtf8(
    'LifeStreamSecureKey1234567890123',
  ); // 32 chars
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Methods
  Future<void> setAuthToken(String token) async {
    try {
      final encrypted = _encrypter.encrypt(token, iv: _iv);
      await _prefs.setString(AppConstants.userTokenKey, encrypted.base64);
    } catch (e) {
      // Fallback to plain text if encryption fails (shouldn't happen)
      await _prefs.setString(AppConstants.userTokenKey, token);
    }
  }

  String? getAuthToken() {
    final storedValue = _prefs.getString(AppConstants.userTokenKey);
    if (storedValue == null) return null;

    try {
      return _encrypter.decrypt64(storedValue, iv: _iv);
    } catch (e) {
      // If decryption fails, it might be old plain-text data. Return as is.
      return storedValue;
    }
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(AppConstants.userTokenKey);
  }

  // User Data Methods
  Future<void> setUserData(String userData) async {
    try {
      final encrypted = _encrypter.encrypt(userData, iv: _iv);
      await _prefs.setString(AppConstants.userDataKey, encrypted.base64);
    } catch (e) {
      await _prefs.setString(AppConstants.userDataKey, userData);
    }
  }

  String? getUserData() {
    final storedValue = _prefs.getString(AppConstants.userDataKey);
    if (storedValue == null) return null;

    try {
      return _encrypter.decrypt64(storedValue, iv: _iv);
    } catch (e) {
      return storedValue;
    }
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
  Future<void> setThemeMode(String theme, {String? userId}) async {
    final key = userId != null
        ? '${AppConstants.themeKey}_$userId'
        : AppConstants.themeKey;
    await _prefs.setString(key, theme);
  }

  String? getThemeMode({String? userId}) {
    final key = userId != null
        ? '${AppConstants.themeKey}_$userId'
        : AppConstants.themeKey;
    return _prefs.getString(key);
  }

  // Logout (Clear All)
  Future<void> logout() async {
    await _prefs.clear();
  }
}

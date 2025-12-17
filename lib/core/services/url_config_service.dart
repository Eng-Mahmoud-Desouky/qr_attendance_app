import 'package:shared_preferences/shared_preferences.dart';

class UrlConfigService {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'http://192.168.1.238:8083';

  final SharedPreferences _prefs;

  UrlConfigService(this._prefs);

  /// Get the current base URL
  String getBaseUrl() {
    return _prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  /// Save a new base URL
  Future<bool> saveBaseUrl(String url) async {
    // Remove trailing slash if present
    final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    return await _prefs.setString(_baseUrlKey, cleanUrl);
  }

  /// Reset to default base URL
  Future<bool> resetToDefault() async {
    return await _prefs.setString(_baseUrlKey, _defaultBaseUrl);
  }

  /// Check if URL is using default value
  bool isUsingDefault() {
    return getBaseUrl() == _defaultBaseUrl;
  }
}

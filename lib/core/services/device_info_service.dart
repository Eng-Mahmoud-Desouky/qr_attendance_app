import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

/// Service for collecting device information required for attendance marking
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo;
  final NetworkInfo _networkInfo;
  final SharedPreferences _prefs;

  static const String _deviceIdKey = 'device_id';
  static const String _publicIpServiceUrl = 'https://api.ipify.org';

  DeviceInfoService({
    DeviceInfoPlugin? deviceInfo,
    NetworkInfo? networkInfo,
    required SharedPreferences preferences,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _networkInfo = networkInfo ?? NetworkInfo(),
       _prefs = preferences;

  /// Get or create a unique device identifier that persists across app sessions
  /// This ID is generated once on first login and stored permanently
  Future<String> getOrCreateDeviceId() async {
    try {
      // Check if we already have a stored device ID
      String? storedDeviceId = _prefs.getString(_deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        print('[DeviceInfoService] Using existing Device ID: $storedDeviceId');
        return storedDeviceId;
      }

      // Generate new UUID-based device ID
      const uuid = Uuid();
      final newDeviceId = uuid.v4();

      // Store it permanently
      await _prefs.setString(_deviceIdKey, newDeviceId);

      print('[DeviceInfoService] Generated new Device ID: $newDeviceId');
      return newDeviceId;
    } catch (e) {
      print('[DeviceInfoService] Error getting/creating device ID: $e');
      // Return a fallback ID based on platform-specific identifier
      return _getPlatformDeviceId();
    }
  }

  /// Fallback method to get platform-specific device identifier
  Future<String> _getPlatformDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-ios-device';
      }
      return 'unknown-platform';
    } catch (e) {
      print('[DeviceInfoService] Error getting platform device ID: $e');
      return 'unknown-device';
    }
  }

  /// DEPRECATED: Use getOrCreateDeviceId() instead
  /// Get unique device identifier from platform
  @Deprecated('Use getOrCreateDeviceId() for persistent device ID')
  Future<String> getDeviceId() async {
    return getOrCreateDeviceId();
  }

  /// Get device's public IP address
  /// Falls back to local WiFi IP if public IP is unavailable
  Future<String> getIpAddress() async {
    // Try to get public IP first
    final publicIp = await getPublicIpAddress();
    if (publicIp != null && publicIp.isNotEmpty && publicIp != '0.0.0.0') {
      return publicIp;
    }

    // Fallback to local WiFi IP
    print(
      '[DeviceInfoService] Public IP unavailable, using local WiFi IP as fallback',
    );
    return _getLocalIpAddress();
  }

  /// Get device's public IP address from external service
  /// Returns null if unable to retrieve
  Future<String?> getPublicIpAddress() async {
    // Try multiple times with increasing timeouts
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print(
          '[DeviceInfoService] Attempt $attempt: Fetching public IP from $_publicIpServiceUrl...',
        );

        final timeout = Duration(seconds: 5 + (attempt * 5)); // 10s, 15s, 20s
        final response = await http
            .get(Uri.parse(_publicIpServiceUrl))
            .timeout(timeout);

        if (response.statusCode == 200) {
          final publicIp = response.body.trim();
          print('[DeviceInfoService] ✅ Public IP retrieved: $publicIp');
          return publicIp;
        } else {
          print(
            '[DeviceInfoService] ❌ Failed to get public IP. Status: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('[DeviceInfoService] ❌ Attempt $attempt failed: $e');
        if (attempt == 3) {
          print('[DeviceInfoService] All attempts to get public IP failed');
          return null;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return null;
  }

  /// Get device's local IP address (WiFi or Mobile Data)
  /// Returns "0.0.0.0" as fallback if unable to retrieve
  Future<String> _getLocalIpAddress() async {
    try {
      // Try WiFi IP first
      final wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != '0.0.0.0') {
        print('[DeviceInfoService] Local WiFi IP: $wifiIP');
        return wifiIP;
      }

      // Try to get IP from mobile data (using network interfaces)
      try {
        final interfaces = await NetworkInterface.list(
          includeLinkLocal: false,
          type: InternetAddressType.IPv4,
        );

        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            final ip = addr.address;
            // Skip loopback and invalid IPs
            if (ip != '127.0.0.1' && ip != '0.0.0.0' && ip.isNotEmpty) {
              print(
                '[DeviceInfoService] Mobile/Network IP: $ip (${interface.name})',
              );
              return ip;
            }
          }
        }
      } catch (e) {
        print('[DeviceInfoService] Error getting network interface IP: $e');
      }

      print('[DeviceInfoService] No valid local IP found, using fallback');
      return '0.0.0.0';
    } catch (e) {
      print('[DeviceInfoService] Error getting local IP address: $e');
      return '0.0.0.0';
    }
  }
}

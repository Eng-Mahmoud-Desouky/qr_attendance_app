import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

/// Service for collecting device information required for attendance marking
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo;
  final NetworkInfo _networkInfo;

  DeviceInfoService({DeviceInfoPlugin? deviceInfo, NetworkInfo? networkInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
      _networkInfo = networkInfo ?? NetworkInfo();

  /// Get unique device identifier
  /// Returns Android ID for Android devices, identifierForVendor for iOS
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-ios-device';
      }
      return 'unknown-platform';
    } catch (e) {
      print('[DeviceInfoService] Error getting device ID: $e');
      return 'unknown-device';
    }
  }

  /// Get device's WiFi IP address
  /// Returns "0.0.0.0" as fallback if unable to retrieve
  Future<String> getIpAddress() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP ?? '0.0.0.0';
    } catch (e) {
      print('[DeviceInfoService] Error getting IP address: $e');
      return '0.0.0.0';
    }
  }
}

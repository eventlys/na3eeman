import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'logger.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();

  factory NetworkHelper() => _instance;

  NetworkHelper._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  bool _isMonitoring = false;

  Stream<NetworkStatus> get networkStatus => _networkStatusController.stream;
  NetworkStatus get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus == NetworkStatus.connected;

  Future<void> initialize() async {
    if (_isMonitoring) return;

    try {
      // Get initial status
      await _checkNetworkStatus();

      // Start monitoring
      _startMonitoring();

      _isMonitoring = true;
      AppLogger.debug('Network helper initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize network helper', error: e);
    }
  }

  void _startMonitoring() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      await _checkNetworkStatus();
    });

    // Periodic status checks (every 30 seconds)
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkNetworkStatus();
    });
  }

  Future<void> _checkNetworkStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final newStatus = await _getNetworkStatus(connectivityResults);

      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _networkStatusController.add(newStatus);

        AppLogger.debug('Network status changed: $newStatus');

        // Log network transition
        _logNetworkTransition(newStatus);
      }
    } catch (e) {
      AppLogger.error('Failed to check network status', error: e);
    }
  }

  Future<NetworkStatus> _getNetworkStatus(
    List<ConnectivityResult> connectivityResults,
  ) async {
    // Check if none of the connectivity results indicate connection
    if (connectivityResults.isEmpty ||
        connectivityResults.every(
          (result) => result == ConnectivityResult.none,
        )) {
      return NetworkStatus.disconnected;
    }

    // Check if we actually have internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkStatus.connected;
      }
    } catch (_) {
      return NetworkStatus.disconnected;
    }

    return NetworkStatus.connected;
  }

  void _logNetworkTransition(NetworkStatus newStatus) {
    final eventData = {
      'previous_status': _currentStatus.toString(),
      'new_status': newStatus.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    AppLogger.debug('Network transition', extra: eventData);
  }

  Future<bool> checkInternetAccess() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty ||
          results.every((result) => result == ConnectivityResult.none)) {
        return false;
      }

      // Try to reach a reliable server
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      AppLogger.debug('No internet access: ${e.toString()}');
      return false;
    }
  }

  Future<NetworkType> getNetworkType() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isEmpty) {
        return NetworkType.none;
      }

      // Return the first available connection type (prioritizing certain types)
      // You might want to adjust this logic based on your needs
      final result = connectivityResults.first;

      switch (result) {
        case ConnectivityResult.wifi:
          return NetworkType.wifi;
        case ConnectivityResult.mobile:
          return NetworkType.mobile;
        case ConnectivityResult.ethernet:
          return NetworkType.ethernet;
        case ConnectivityResult.vpn:
          return NetworkType.vpn;
        case ConnectivityResult.bluetooth:
          return NetworkType.bluetooth;
        case ConnectivityResult.other:
        case ConnectivityResult.satellite:
          return NetworkType.other;
        case ConnectivityResult.none:
          return NetworkType.none;
      }
    } catch (e) {
      AppLogger.error('Failed to get network type', error: e);
      return NetworkType.unknown;
    }
  }

  Future<double?> getNetworkSpeed() async {
    // This is a simplified network speed test
    // In production, you might want to use a proper speed test library
    try {
      final stopwatch = Stopwatch()..start();

      // Download a small file or make a request to measure speed
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://httpbin.org/bytes/1024'),
      );
      final response = await request.close();
      await response.drain();

      stopwatch.stop();
      client.close();

      // Calculate speed in KB/s
      final speed = 1024 / (stopwatch.elapsedMilliseconds / 1000);
      return speed;
    } catch (e) {
      AppLogger.error('Failed to measure network speed', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> getNetworkInfo() async {
    final type = await getNetworkType();
    final speed = await getNetworkSpeed();

    return {
      'status': _currentStatus.toString(),
      'type': type.toString(),
      'speed_kbps': speed,
      'is_connected': isConnected,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Wait for network connection with timeout
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isConnected) return true;

    final completer = Completer<bool>();
    final timer = Timer(timeout, () => completer.complete(false));

    final subscription = networkStatus.listen((status) {
      if (status == NetworkStatus.connected) {
        timer.cancel();
        completer.complete(true);
      }
    });

    final result = await completer.future;
    subscription.cancel();

    return result;
  }

  // Check if network is stable (for large uploads/downloads)
  Future<bool> isNetworkStable() async {
    if (!isConnected) return false;

    final type = await getNetworkType();

    // Consider WiFi and Ethernet as stable
    return type == NetworkType.wifi || type == NetworkType.ethernet;
  }

  void dispose() {
    _networkStatusController.close();
    _isMonitoring = false;
  }
}

enum NetworkStatus { connected, disconnected, unknown }

enum NetworkType {
  wifi,
  mobile,
  ethernet,
  vpn,
  bluetooth,
  other,
  none,
  unknown,
}

extension NetworkStatusExtension on NetworkStatus {
  String get displayName {
    switch (this) {
      case NetworkStatus.connected:
        return 'Connected';
      case NetworkStatus.disconnected:
        return 'Disconnected';
      case NetworkStatus.unknown:
        return 'Unknown';
    }
  }
}

extension NetworkTypeExtension on NetworkType {
  String get displayName {
    switch (this) {
      case NetworkType.wifi:
        return 'WiFi';
      case NetworkType.mobile:
        return 'Mobile Data';
      case NetworkType.ethernet:
        return 'Ethernet';
      case NetworkType.vpn:
        return 'VPN';
      case NetworkType.bluetooth:
        return 'Bluetooth';
      case NetworkType.other:
        return 'Other';
      case NetworkType.none:
        return 'No Connection';
      case NetworkType.unknown:
        return 'Unknown';
    }
  }
}

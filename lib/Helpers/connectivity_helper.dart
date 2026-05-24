import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'logger.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();

  factory ConnectivityHelper() => _instance;

  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<List<ConnectivityResult>> _connectionStatusController =
      StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _currentStatus = [ConnectivityResult.none];
  bool _isInitialized = false;

  Stream<List<ConnectivityResult>> get connectionStatus =>
      _connectionStatusController.stream;
  List<ConnectivityResult> get currentStatus => _currentStatus;

  // Check if there's any connectivity (not none)
  bool get isConnected =>
      !_currentStatus.contains(ConnectivityResult.none) &&
      _currentStatus.isNotEmpty;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get initial connectivity status
      _currentStatus = await _connectivity.checkConnectivity();
      _connectionStatusController.add(_currentStatus);

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> result,
      ) {
        _currentStatus = result;
        _connectionStatusController.add(result);

        AppLogger.debug('Connectivity changed: $result');
      });

      _isInitialized = true;
      AppLogger.info('Connectivity helper initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize connectivity helper', error: e);
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _currentStatus = result;
      return !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    } catch (e) {
      AppLogger.error('Failed to check connection', error: e);
      return false;
    }
  }

  Future<bool> hasInternetAccess() async {
    if (!isConnected) return false;

    try {
      // You might want to implement a actual network request test here
      // For now, we'll assume that having connectivity means having internet
      return true;
    } catch (e) {
      return false;
    }
  }

  String getConnectionType() {
    // Return the most relevant connection type
    if (_currentStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_currentStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_currentStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_currentStatus.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (_currentStatus.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (_currentStatus.contains(ConnectivityResult.other)) {
      return 'Other';
    } else {
      return 'No Connection';
    }
  }

  // Helper methods to check for specific connection types
  bool get isOnWifi => _currentStatus.contains(ConnectivityResult.wifi);
  bool get isOnMobile => _currentStatus.contains(ConnectivityResult.mobile);
  bool get isOnCellular => _currentStatus.contains(ConnectivityResult.mobile);
  bool get isOnEthernet => _currentStatus.contains(ConnectivityResult.ethernet);
  bool get isOnVpn => _currentStatus.contains(ConnectivityResult.vpn);
  bool get isOnBluetooth =>
      _currentStatus.contains(ConnectivityResult.bluetooth);

  // Method to wait for connection with timeout
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isConnected) return true;

    final completer = Completer<bool>();
    final timer = Timer(timeout, () => completer.complete(false));

    final subscription = connectionStatus.listen((
      List<ConnectivityResult> status,
    ) {
      if (!status.contains(ConnectivityResult.none) && status.isNotEmpty) {
        timer.cancel();
        completer.complete(true);
      }
    });

    final result = await completer.future;
    subscription.cancel();

    return result;
  }

  // Method to check if connection is stable (for large uploads/downloads)
  Future<bool> isConnectionStable() async {
    if (!isConnected) return false;

    // For now, consider WiFi and Ethernet as stable
    return _currentStatus.contains(ConnectivityResult.wifi) ||
        _currentStatus.contains(ConnectivityResult.ethernet);
  }

  // Get connection quality (simplified)
  String getConnectionQuality() {
    if (!isConnected) return 'None';

    if (_currentStatus.contains(ConnectivityResult.wifi) ||
        _currentStatus.contains(ConnectivityResult.ethernet)) {
      return 'Excellent';
    } else if (_currentStatus.contains(ConnectivityResult.mobile)) {
      return 'Good';
    } else if (_currentStatus.contains(ConnectivityResult.vpn)) {
      return 'Variable';
    } else if (_currentStatus.contains(ConnectivityResult.bluetooth) ||
        _currentStatus.contains(ConnectivityResult.other)) {
      return 'Poor';
    } else {
      return 'Unknown';
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}

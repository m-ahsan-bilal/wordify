import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to check and monitor internet connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  final ValueNotifier<ConnectivityResult> _connectivityResult =
      ValueNotifier<ConnectivityResult>(ConnectivityResult.none);

  /// Current connectivity status
  ValueNotifier<bool> get isConnected => _isConnected;

  /// Current connectivity result
  ValueNotifier<ConnectivityResult> get connectivityResult =>
      _connectivityResult;

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint(
            '------------------->>> Connectivity check timeout - assuming connected',
          );
          return [ConnectivityResult.other];
        },
      );
      final hasConnection = _hasInternetConnection(result);

      _connectivityResult.value = result.isNotEmpty
          ? result.first
          : ConnectivityResult.none;
      _isConnected.value = hasConnection;

      return hasConnection;
    } catch (e) {
      // Handle MissingPluginException gracefully
      if (e.toString().contains(
        '------------------->>>MissingPluginException',
      )) {
        debugPrint(
          '------------------->>> Connectivity plugin not available - app will work normally',
        );
      } else {
        debugPrint(' ------------------->>> Error checking connectivity: $e');
      }
      // Default to connected if check fails (to avoid blocking app)
      // This allows the app to work even if connectivity plugin isn't available
      _isConnected.value = true;
      _connectivityResult.value = ConnectivityResult.other;
      return true;
    }
  }

  /// Check if any connectivity result indicates internet access
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    // WiFi, mobile data, ethernet, and other types indicate internet
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.other,
    );
  }

  /// Start monitoring connectivity changes
  void startMonitoring() {
    try {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          try {
            final hasConnection = _hasInternetConnection(results);
            _connectivityResult.value = results.isNotEmpty
                ? results.first
                : ConnectivityResult.none;
            _isConnected.value = hasConnection;
            debugPrint(
              ' ------------------->>>Connectivity changed: ${results.toString()} - Connected: $hasConnection',
            );
          } catch (e) {
            debugPrint(
              ' ------------------->>>Error processing connectivity change: $e',
            );
          }
        },
        onError: (error) {
          // Handle MissingPluginException gracefully
          if (error.toString().contains(
            ' ------------------->>> MissingPluginException',
          )) {
            debugPrint(
              ' ------------------->>>Connectivity plugin not available - monitoring disabled',
            );
          } else {
            debugPrint('Connectivity monitoring error: $error');
          }
          // Don't update state on error, keep current state
        },
        cancelOnError: false, // Keep listening even on errors
      );
    } catch (e) {
      // Handle MissingPluginException gracefully
      if (e.toString().contains('MissingPluginException')) {
        debugPrint(
          'Connectivity plugin not available - app will work normally',
        );
      } else {
        debugPrint('Error starting connectivity monitoring: $e');
      }
      // If monitoring fails, assume connected to not block app
      _isConnected.value = true;
    }
  }

  /// Stop monitoring connectivity changes
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _isConnected.dispose();
    _connectivityResult.dispose();
  }
}

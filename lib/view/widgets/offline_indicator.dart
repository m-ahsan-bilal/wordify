import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/safe_fonts.dart';

/// Widget that shows an offline indicator banner when internet is unavailable
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.isConnected.addListener(_onConnectivityChanged);
    _checkInitialStatus();
  }

  void _checkInitialStatus() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  void _onConnectivityChanged() {
    if (mounted) {
      setState(() {
        _isConnected = _connectivityService.isConnected.value;
      });
    }
  }

  @override
  void dispose() {
    _connectivityService.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'No Internet Connection',
            style: safeGoogleFonts(
              fontFamily: 'inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that wraps content and shows offline message when needed
class OfflineAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? offlineMessage;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.offlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    
    return ValueListenableBuilder<bool>(
      valueListenable: connectivityService.isConnected,
      builder: (context, isConnected, _) {
        if (!isConnected && offlineMessage != null) {
          return offlineMessage!;
        }
        return child;
      },
    );
  }
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service - Handles Google Mobile Ads initialization and banner management
/// Singleton pattern for global access
/// Follows clean architecture pattern
/// Note: Each AdBannerWidget creates its own BannerAd instance (required by Google Mobile Ads)
class AdMobService {
  // Singleton
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _initialized = false;
  bool _isTestMode = true; // Set to false for production

  // AdMob App ID (from AdMob Console)
  static const String appId = 'ca-app-pub-1747226374277218~5023099680';

  // Test Ad Unit IDs (using test IDs for testing, even with real App ID)
  // These are Google's test ad unit IDs - safe to use during development
  // Android: ca-app-pub-3940256099942544/6300978111
  // iOS: ca-app-pub-3940256099942544/2934735716
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  // static const String _bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716'; // Reserved for future iOS support

  /// Get banner ad unit ID based on platform
  String get bannerAdUnitId {
    // In production, use your actual Ad Unit IDs
    // For now, using test IDs
    return _isTestMode
        ? (_bannerAdUnitIdAndroid) // Test ID
        : (_bannerAdUnitIdAndroid); // Replace with your production ID
  }

  /// Initialize AdMob service
  Future<void> init() async {
    if (_initialized) {
      debugPrint('AdMob service already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing AdMob service with App ID: $appId');
      // Initialize with app ID and timeout to prevent hanging
      final initResponse = await MobileAds.instance.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⚠️ AdMob initialization timeout');
          throw TimeoutException('AdMob initialization timeout');
        },
      );
      
      // Check initialization status
      debugPrint('📊 AdMob initialization response: ${initResponse.adapterStatuses}');
      
      _initialized = true;
      debugPrint('✅ AdMob service initialized successfully');
      debugPrint('📱 Using ${_isTestMode ? "test" : "production"} ad unit IDs for banner ads');
      debugPrint('📝 Banner Ad Unit ID: $bannerAdUnitId');
      debugPrint('📝 Note: Each AdBannerWidget creates its own BannerAd instance');
      debugPrint('   (Google Mobile Ads requires separate instances per AdWidget)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing AdMob: $e');
      debugPrint('Stack trace: $stackTrace');
      _initialized = false;
      // Don't throw - allow app to continue without ads
    }
  }

  /// Check if AdMob is initialized
  bool get isInitialized => _initialized;

  /// Set test mode (for development)
  void setTestMode(bool enabled) {
    _isTestMode = enabled;
  }
}

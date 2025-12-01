import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/admob_service.dart';

/// Reusable Ad Banner Widget
/// Handles loading states and errors gracefully
/// Follows app's clean architecture pattern
class AdBannerWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;

  const AdBannerWidget({super.key, this.adSize, this.margin});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Delay ad loading to avoid blocking UI initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadAd();
        }
      });
    });
  }

  void _loadAd() {
    final adMobService = AdMobService();
    
    if (!adMobService.isInitialized) {
      debugPrint('⚠️ AdMob not initialized, retrying initialization...');
      // Try to initialize if not already initialized
      adMobService.init().then((_) {
        if (mounted && adMobService.isInitialized) {
          debugPrint('✅ AdMob initialized, loading ad...');
          _loadAd();
        } else {
          debugPrint('❌ AdMob initialization failed, cannot load ad');
        }
      }).catchError((e) {
        debugPrint('❌ Failed to initialize AdMob: $e');
      });
      return;
    }

    if (_isLoading || _isAdLoaded) {
      debugPrint('⏸️ Ad already loading or loaded, skipping');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isAdError = false;
    });

    final adSize = widget.adSize ?? AdSize.banner;
    final adUnitId = adMobService.bannerAdUnitId;
    
    debugPrint('📱 Loading banner ad with unit ID: $adUnitId');
    debugPrint('📏 Ad size: ${adSize.width}x${adSize.height}');

    try {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isAdError = false;
                _isLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Banner ad failed to load: ${error.code} - ${error.message}');
            debugPrint('   Domain: ${error.domain}');
            debugPrint('   Response info: ${error.responseInfo}');
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isAdError = true;
                _isLoading = false;
              });
            }
            ad.dispose();
            
            // Retry after delay if error is recoverable (not invalid request or invalid ad size)
            // Error codes: 0=INTERNAL_ERROR, 1=INVALID_REQUEST, 2=NETWORK_ERROR, 3=NO_FILL, 4=APP_ID_MISSING, etc.
            // Only retry for network errors or no fill, not for invalid requests
            final errorCode = error.code;
            if (errorCode != 1 && errorCode != 4) { // Not INVALID_REQUEST or APP_ID_MISSING
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted && !_isAdLoaded && !_isLoading) {
                  debugPrint('🔄 Retrying ad load after error (code: $errorCode)...');
                  _loadAd();
                }
              });
            } else {
              debugPrint('⚠️ Non-recoverable error (code: $errorCode), not retrying');
            }
          },
          onAdOpened: (_) {
            debugPrint('👆 Banner ad opened');
          },
          onAdClosed: (_) {
            debugPrint('👋 Banner ad closed');
          },
          onAdImpression: (_) {
            debugPrint('👁️ Banner ad impression recorded');
          },
        ),
      );

      _bannerAd?.load();

      // Timeout after 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && !_isAdLoaded && !_isAdError) {
          debugPrint('⏱️ Ad load timeout after 15 seconds');
          setState(() {
            _isLoading = false;
            _isAdError = true;
          });
          _bannerAd?.dispose();
          _bannerAd = null;
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating banner ad: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAdError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final adMobService = AdMobService();
      
      // If AdMob is not initialized, try to initialize and show loading
      if (!adMobService.isInitialized) {
        debugPrint('⚠️ AdMob not initialized in build, attempting initialization...');
        // Trigger initialization if not already done
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!adMobService.isInitialized && mounted) {
            adMobService.init().then((_) {
              if (mounted && adMobService.isInitialized) {
                _loadAd();
              }
            });
          }
        });
        // Show loading state while initializing
        return Container(
          margin: widget.margin ?? EdgeInsets.zero,
          height: widget.adSize?.height.toDouble() ?? 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      // If ad failed to load, show nothing (but log for debugging)
      if (_isAdError) {
        debugPrint('⚠️ Ad failed to load, showing empty space');
        return const SizedBox.shrink();
      }

      // If ad is not loaded yet, show a minimal loading indicator
      if (!_isAdLoaded && _isLoading) {
        return Container(
          margin: widget.margin ?? EdgeInsets.zero,
          height: widget.adSize?.height.toDouble() ?? 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      // Show the ad with proper constraints
      if (_bannerAd != null && _isAdLoaded) {
        final adHeight = widget.adSize?.height.toDouble() ?? 50;
        debugPrint('✅ Rendering banner ad (${adHeight.toInt()}px height)');
        return Container(
          margin: widget.margin ?? EdgeInsets.zero,
          height: adHeight,
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: double.infinity,
            height: adHeight,
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      }

      // If we reach here, ad might not have started loading yet
      // Trigger load if needed
      if (!_isLoading && !_isAdLoaded && !_isAdError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadAd();
          }
        });
      }

      return const SizedBox.shrink();
    } catch (e, stackTrace) {
      debugPrint('❌ Error building AdBannerWidget: $e');
      debugPrint('Stack trace: $stackTrace');
      return const SizedBox.shrink();
    }
  }
}

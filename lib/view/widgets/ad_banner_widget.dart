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
    if (!AdMobService().isInitialized) {
      debugPrint('AdMob not initialized, skipping ad load');
      return;
    }

    if (_isLoading || _isAdLoaded) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final adSize = widget.adSize ?? AdSize.banner;
    final adUnitId = AdMobService().bannerAdUnitId;

    try {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isAdError = false;
                _isLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isAdError = true;
                _isLoading = false;
              });
            }
            ad.dispose();
          },
          onAdOpened: (_) {
            debugPrint('Banner ad opened');
          },
          onAdClosed: (_) {
            debugPrint('Banner ad closed');
          },
        ),
      );

      _bannerAd?.load();

      // Timeout after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && !_isAdLoaded && !_isAdError) {
          setState(() {
            _isLoading = false;
            _isAdError = true;
          });
          _bannerAd?.dispose();
          _bannerAd = null;
        }
      });
    } catch (e) {
      debugPrint('❌ Error creating banner ad: $e');
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
      // If AdMob is not initialized, don't show anything
      if (!AdMobService().isInitialized) {
        return const SizedBox.shrink();
      }

      // If ad failed to load, show nothing
      if (_isAdError) {
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

      return const SizedBox.shrink();
    } catch (e) {
      debugPrint('Error building AdBannerWidget: $e');
      return const SizedBox.shrink();
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// widget بيعرض Banner ad تحت الشاشة.
/// بيستخدم test ID دلوقتي (وقت التطوير) — نغيّره للحقيقي قبل النشر.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  /// ⚠️ Test ad unit ID من جوجل — للتطوير بس.
  /// قبل النشر نغيّره للـ ID الحقيقي: ca-app-pub-9699523022325558/9675503941
  static final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-9699523022325558/9675503941' // Android test banner
      : 'ca-app-pub-3940256099942544/2435281174'; // iOS test banner

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner, // الحجم القياسي (320x50)
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // لو فشل التحميل، منعرضش حاجة (الشاشة تفضل نضيفة)
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // نحرّر الإعلان لما الشاشة تتقفل
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لو مش متحمّل، منعرضش حاجة (مفيش مساحة فاضية)
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../data/data_manager.dart'; // VIP kontrolü için

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // ÖNEMLİ: Uygulamayı yayınlarken kReleaseMode kısmındaki yere KENDİ BANNER ID'ni yazmalısın!
  // Şu an test reklamları (Google Test ID) çalışacak.
  final String adUnitId = kReleaseMode
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY' // KENDİ GERÇEK ID'N BURAYA
      : 'ca-app-pub-3940256099942544/6300978111'; // GOOGLE TEST ID'Sİ

  @override
  void initState() {
    super.initState();
    // Oyuncu reklam kaldırma satın aldıysa veya Web'deysek reklam yükleme!
    if (!kIsWeb && !DataManager.isAdsRemoved) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd Yüklenemedi: ${err.message}');
          ad.dispose(); // Hata verirse RAM'den at, oyunu dondurmaz!
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. VIP oyuncu kontrolü (Reklamsız)
    if (DataManager.isAdsRemoved) return const SizedBox.shrink();

    // 2. Reklam yüklendiyse göster
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Colors.black, // Oyun temasıyla bütünleşir
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(), // Genelde 50px
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // Yüklenene kadar ekranda yer kaplamaz
    return const SizedBox.shrink();
  }
}
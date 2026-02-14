import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // <--- EKSİK OLAN BUYDU!
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // --- REKLAM KİMLİKLERİ (TEST ID'LERİ) ---
  // Yayınlarken bunları gerçek AdMob ID'lerinle değiştireceksin.
  final String _bannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  final String _rewardedIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  final String _bannerIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  final String _interstitialIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  final String _rewardedIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  // --- DEĞİŞKENLER ---
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  // --- BAŞLATMA ---
  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadBanner();
    _loadInterstitial();
    _loadRewarded();
  }

  // --- PLATFORM KONTROLÜ ---
  String get bannerAdUnitId {
    if (kIsWeb) return ''; // Web desteklenmiyor
    return Platform.isAndroid ? _bannerIdAndroid : _bannerIdIOS;
  }

  String get interstitialAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid ? _interstitialIdAndroid : _interstitialIdIOS;
  }

  String get rewardedAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid ? _rewardedIdAndroid : _rewardedIdIOS;
  }

  // ============================================================
  // 1. BANNER REKLAM (Alt Kısım)
  // ============================================================
  void _loadBanner() {
    if (kIsWeb) return;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint("AdManager: Banner yüklendi.");
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("AdManager: Banner hatası: $error");
          ad.dispose();
          _isBannerLoaded = false;
        },
      ),
    )..load();
  }

  // Oyun içinde Banner Widget'ı göstermek için bu fonksiyonu çağıracağız
  Widget getBannerWidget() {
    if (_isBannerLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink(); // Yüklü değilse boşluk döndür
  }

  // ============================================================
  // 2. GEÇİŞ REKLAMI (Oyun Sonu / Level Sonu)
  // ============================================================
  void _loadInterstitial() {
    if (kIsWeb) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("AdManager: Geçiş reklamı hazır.");
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint("AdManager: Geçiş reklamı yüklenemedi: $error");
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialLoaded = false;
          _loadInterstitial(); // Bir sonraki için yenisini yükle
          if (onAdDismissed != null) onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialLoaded = false;
          _loadInterstitial();
          if (onAdDismissed != null) onAdDismissed();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint("AdManager: Geçiş reklamı hazır değil, pas geçiliyor.");
      if (onAdDismissed != null) onAdDismissed();
      _loadInterstitial(); // Tekrar yüklemeyi dene
    }
  }

  // ============================================================
  // 3. ÖDÜLLÜ REKLAM (Canlanma / Ekstra Kristal)
  // ============================================================
  void _loadRewarded() {
    if (kIsWeb) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("AdManager: Ödüllü reklam hazır.");
          _rewardedAd = ad;
          _isRewardedLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint("AdManager: Ödüllü reklam yüklenemedi: $error");
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd(
      {required Function(int) onReward, VoidCallback? onAdFailed}) {
    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedLoaded = false;
          _loadRewarded(); // Yenisini hazırla
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedLoaded = false;
          _loadRewarded();
          if (onAdFailed != null) onAdFailed();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // Kullanıcı ödülü hak etti
          debugPrint("AdManager: Ödül kazanıldı! Miktar: ${reward.amount}");
          onReward(reward.amount.toInt());
        },
      );
    } else {
      debugPrint("AdManager: Ödüllü reklam hazır değil.");
      if (onAdFailed != null) onAdFailed();
      _loadRewarded();
    }
  }

  // --- TEMİZLİK ---
  void disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

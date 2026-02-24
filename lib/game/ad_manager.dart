import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/data_manager.dart'; // <--- OYUNCUNUN VERİLERİ (VIP KONTROLÜ İÇİN)

class AdManager {
  // --- GERÇEK REKLAM KİMLİKLERİ (TÜMÜ TAMAMLANDI) ---
  final String _bannerIdAndroid = 'ca-app-pub-6419457007009038/1001101068';
  final String _interstitialIdAndroid = 'ca-app-pub-6419457007009038/7255518226';
  final String _rewardedIdAndroid = 'ca-app-pub-6419457007009038/1560013078';

  // iOS Tarafı: Şimdilik Android (Google Play) çıkışı yaptığımız için buralar test kalabilir.
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
    if (kIsWeb) return;
    await MobileAds.instance.initialize();

    // YENİ: Oyuncu VIP ise (reklamları kaldırdıysa) Banner ve Geçiş yükleme!
    if (!DataManager.isAdsRemoved) {
      _loadBanner();
      _loadInterstitial();
    }

    // Ödüllü reklam her zaman yüklenir, VIP'ler reklam izlemeden anında alır.
    _loadRewarded();
  }

  // --- PLATFORM KONTROLÜ ---
  String get bannerAdUnitId {
    if (kIsWeb) return '';
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
    if (kIsWeb || DataManager.isAdsRemoved) return; // VIP Kontrolü

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

  Widget getBannerWidget() {
    // VIP'ler için veya yüklenmediyse doğrudan görünmez bir kutu döndür
    if (DataManager.isAdsRemoved) return const SizedBox.shrink();

    if (_isBannerLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  // ============================================================
  // 2. GEÇİŞ REKLAMI (Oyun Sonu / Level Sonu)
  // ============================================================
  void _loadInterstitial() {
    if (kIsWeb || DataManager.isAdsRemoved) return; // VIP Kontrolü

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
    // VIP KONTROLÜ: Adam para verdiyse reklamı atla ve hayatına devam et!
    if (DataManager.isAdsRemoved) {
      if (onAdDismissed != null) onAdDismissed();
      return;
    }

    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialLoaded = false;
          _loadInterstitial();
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
      _loadInterstitial();
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
    // VIP KONTROLÜ: Oyuncu VIP ise reklam izletmeden ödülü anında ver!
    if (DataManager.isAdsRemoved) {
      debugPrint("AdManager: VIP Kullanıcı! Reklam izlenmeden ödül verildi.");
      onReward(1);
      return;
    }

    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedLoaded = false;
          _loadRewarded();
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

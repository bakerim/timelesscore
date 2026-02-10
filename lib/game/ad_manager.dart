import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  RewardedAd? _rewardedAd;

  // ReviveMenu'nün reklamın hazır olup olmadığını anlaması için getter
  bool get isRewardedAdReady => _rewardedAd != null;

  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // TEST ID'leri (Yayınlarken Kendi ID'lerinle Değiştir!)
  // Android Test ID: ca-app-pub-3940256099942544/5224354917
  final String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'SENIN_GERCEK_REKLAM_KODUN_BURAYA';

  // --- BAŞLATMA ---
  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  // --- ÖDÜLLÜ REKLAM YÜKLE ---
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  // --- REKLAM GÖSTER ---
  void showRewardedAd(
      {required Function(int) onReward, required Function() onAdFailed}) {
    if (_rewardedAd == null) {
      debugPrint('Warning: Ad not loaded yet.');
      onAdFailed();
      loadRewardedAd(); // Bir dahaki sefere hazır olsun diye yüklemeyi dene
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        loadRewardedAd(); // Reklam kapatılınca yenisini yükle (Sirkülasyon)
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadRewardedAd();
        onAdFailed();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        // Google genelde reward.amount'u 1 döndürür, ama biz kendi mantığımızı uygularız.
        onReward(reward.amount.toInt());
      },
    );
    _rewardedAd = null; // Kullanılan reklamı boşa çıkar
  }

  // --- KARE REKLAM (MREC - PAUSE MENÜSÜ İÇİN) ---
  BannerAd? pauseBannerAd;
  bool isPauseBannerLoaded = false;

  void loadMrecAd() {
    pauseBannerAd = BannerAd(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Google Test ID (MREC)
          : 'SENIN_GERCEK_MREC_ID_BURAYA',
      size: AdSize.mediumRectangle, // 300x250 Boyutunda
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('MREC Reklam yüklendi: $ad');
          isPauseBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('MREC Reklam yüklenemedi: $error');
          isPauseBannerLoaded = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  // Temizlik (Memory Leak Önlemek İçin)
  void disposeAds() {
    _rewardedAd?.dispose();
    pauseBannerAd?.dispose(); // Banner reklamı da bellekten siliyoruz
  }
}

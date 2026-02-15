import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'data_manager.dart';

class PurchaseManager {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static late StreamSubscription<List<PurchaseDetails>> _subscription;

  static bool isAvailable = false;
  static List<ProductDetails> products = [];

  // ==========================================
  // 1. MAĞAZA ÜRÜN KODLARI
  // (Google Play Console'a gireceğin ID'ler)
  // ==========================================
  static const String idRemoveAds = 'remove_ads_premium'; // Kalıcı ürün
  static const String idBuyCrystals = '100_time_crystals'; // Tüketilebilir ürün

  // ==========================================
  // 2. MOTORU BAŞLAT VE MAĞAZAYA BAĞLAN
  // ==========================================
  static Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint("Mağaza bağlantısı kurulamadı (Emülatörde olabilirsin).");
      return;
    }

    // Oyuncu bir şey satın aldığında faturayı anında yakalayacak dinleyici
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Satın alma dinleyicisi hatası: $error");
    });

    // Mağazadaki ürünleri çek (Fiyatlarını ve isimlerini getirmek için)
    await loadProducts();
  }

  // ==========================================
  // 3. ÜRÜNLERİ GOOGLE PLAY'DEN GETİR
  // ==========================================
  static Future<void> loadProducts() async {
    const Set<String> kIds = <String>{idRemoveAds, idBuyCrystals};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          "Google Play'de bulunamayan Ürün ID'leri: ${response.notFoundIDs}");
    }
    products = response.productDetails;
  }

  // ==========================================
  // 4. SATIN ALMA İŞLEMİNİ BAŞLAT (Market Butonu Tetikler)
  // ==========================================
  static void buyProduct(String productId) {
    if (!isAvailable) {
      debugPrint("Mağaza şu an kullanılamıyor.");
      return;
    }

    try {
      final ProductDetails productDetails =
          products.firstWhere((p) => p.id == productId);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      // Tüketilmeyen (Kalıcı VIP) ürün: Reklam kaldırma
      if (productId == idRemoveAds) {
        _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
      // Tüketilebilir (Defalarca alınabilen) ürün: Kristal
      else {
        _iap.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint("Ürün bulunamadı veya satın alma ekranı açılamadı: $e");
    }
  }

  // ==========================================
  // 5. SATIN ALIMLARI GERİ YÜKLE (Telefon değiştirenler için)
  // ==========================================
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // ==========================================
  // 6. KASİYER (Faturayı kontrol et ve malı teslim et)
  // ==========================================
  static void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint("Satın alma onaylanıyor, lütfen bekleyin...");
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint(
            "Satın alma başarısız veya iptal edildi: ${purchaseDetails.error}");
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // --- ADIM A: ÜRÜNÜ TESLİM ET ---
        if (purchaseDetails.productID == idRemoveAds) {
          DataManager.setAdsRemoved(true); // VIP Yaptık!
          debugPrint("TEBRİKLER! Reklamlar kalıcı olarak kaldırıldı!");
        } else if (purchaseDetails.productID == idBuyCrystals) {
          DataManager.totalCoins += 100;
          DataManager.saveData();
          debugPrint("TEBRİKLER! 100 Zaman Kristali hesaba eklendi!");
        }

        // --- ADIM B: GOOGLE'A 'PARAYI ALDIM' MESAJI GÖNDER ---
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Motoru kapatırken dinleyiciyi öldür (Hafıza sızıntısını engeller)
  static void dispose() {
    _subscription.cancel();
  }
}

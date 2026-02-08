import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'data_manager.dart';

class PurchaseManager {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static bool available = true;

  // Google Play Console'da oluşturacağın ürün ID'leri:
  static const String idRemoveAds = 'remove_ads';
  static const String idCoinPack1 = 'coin_pack_1000';

  static List<ProductDetails> products = [];
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static void init() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint("IAP Hatası: $error");
    });

    _loadProducts();
  }

  static Future<void> _loadProducts() async {
    try {
      available = await _iap.isAvailable();
      if (!available) return;

      const Set<String> kIds = {idRemoveAds, idCoinPack1};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(kIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("Bulunamayan Ürünler: ${response.notFoundIDs}");
      }

      products = response.productDetails;
      debugPrint("Yüklenen Ürün Sayısı: ${products.length}");
    } catch (e) {
      debugPrint("Ürünleri yüklerken hata: $e");
    }
  }

  // --- DÜZELTİLEN METOD BURASI ---
  static void buyProduct(String productId) {
    // 1. Ürün listesi boşsa işlem yapma
    if (products.isEmpty) {
      debugPrint("Ürün listesi henüz yüklenmedi.");
      return;
    }

    try {
      // 2. Ürünü bulmaya çalış (Hata veren yer burasıydı)
      final ProductDetails product =
          products.firstWhere((element) => element.id == productId);

      // 3. Bulunursa satın alma sürecini başlat
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // 4. Bulunamazsa (StateError) buraya düşer
      debugPrint("Ürün bulunamadı veya ID hatalı: $productId");
    }
  }

  static void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // İşlem bekleniyor...
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Satın alma hatası: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static void _deliverProduct(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == idRemoveAds) {
      DataManager.removeAds();
      debugPrint("REKLAMLAR KALDIRILDI!");
    } else if (purchaseDetails.productID == idCoinPack1) {
      // DataManager.addCoins(1000);
      debugPrint("1000 COIN EKLENDİ!");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static late SharedPreferences _prefs;

  // Anahtarlar
  static const String keyHighScore = 'highScore';
  static const String keyTotalCoins = 'totalCoins';
  static const String keyRemoveAds = 'removeAds';
  static const String keyOwnedSkins = 'ownedSkins';
  static const String keySelectedSkin = 'selectedSkin';

  // YENİ: Günlük Ödül Anahtarları
  static const String keyLastLogin = 'lastLogin';
  static const String keyStreak = 'dailyStreak';

  // Veriler
  static int highScore = 0;
  static int totalCoins = 0;
  static bool isAdsRemoved = false;
  static List<String> ownedSkins = ['0'];
  static int selectedSkinId = 0;

  // YENİ: Günlük Ödül Verileri
  static String lastLoginDate = "";
  static int dailyStreak = 0;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Mevcut verileri çek
    highScore = _prefs.getInt(keyHighScore) ?? 0;
    totalCoins = _prefs.getInt(keyTotalCoins) ?? 0;
    isAdsRemoved = _prefs.getBool(keyRemoveAds) ?? false;
    ownedSkins = _prefs.getStringList(keyOwnedSkins) ?? ['0'];
    selectedSkinId = _prefs.getInt(keySelectedSkin) ?? 0;

    // YENİ: Tarih verilerini çek
    lastLoginDate = _prefs.getString(keyLastLogin) ?? "";
    dailyStreak = _prefs.getInt(keyStreak) ?? 0;
  }

  static Future<void> saveScore(int score) async {
    int earnedCoins = (score / 10).floor();
    if (earnedCoins > 0) {
      totalCoins += earnedCoins;
      await _prefs.setInt(keyTotalCoins, totalCoins);
    }

    if (score > highScore) {
      highScore = score;
      await _prefs.setInt(keyHighScore, highScore);
    }
  }

  static Future<void> removeAds() async {
    isAdsRemoved = true;
    await _prefs.setBool(keyRemoveAds, true);
  }

  static Future<bool> buySkin(int skinId, int price) async {
    if (totalCoins >= price && !ownedSkins.contains(skinId.toString())) {
      totalCoins -= price;
      ownedSkins.add(skinId.toString());
      await _prefs.setInt(keyTotalCoins, totalCoins);
      await _prefs.setStringList(keyOwnedSkins, ownedSkins);
      return true;
    }
    return false;
  }

  static Future<void> selectSkin(int skinId) async {
    if (ownedSkins.contains(skinId.toString())) {
      selectedSkinId = skinId;
      await _prefs.setInt(keySelectedSkin, selectedSkinId);
    }
  }

  // YENİ: Günlük Ödül Kontrol Mekanizması
  static Future<Map<String, dynamic>> checkDailyReward() async {
    DateTime now = DateTime.now();
    // Tarihi YYYY-MM-DD formatına çeviriyoruz
    String todayStr = "${now.year}-${now.month}-${now.day}";

    // Eğer bugün zaten girdiyse ödül yok
    if (lastLoginDate == todayStr) {
      return {'canClaim': false, 'streak': dailyStreak};
    }

    // Dünü bul
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String yesterdayStr =
        "${yesterday.year}-${yesterday.month}-${yesterday.day}";

    // Eğer son giriş dün ise zinciri artır, yoksa sıfırla
    if (lastLoginDate == yesterdayStr) {
      dailyStreak++;
    } else {
      dailyStreak = 1;
    }

    // Tarihi güncelle ve kaydet
    lastLoginDate = todayStr;
    await _prefs.setString(keyLastLogin, lastLoginDate);
    await _prefs.setInt(keyStreak, dailyStreak);

    // Ödül Miktarı: Temel 50 + (Gün * 10). Max 500.
    int rewardAmount = 50 + (dailyStreak * 10);
    if (rewardAmount > 500) rewardAmount = 500;

    // Parayı ekle
    totalCoins += rewardAmount;
    await _prefs.setInt(keyTotalCoins, totalCoins);

    return {'canClaim': true, 'streak': dailyStreak, 'reward': rewardAmount};
  }

  static Color getSkinColor() {
    switch (selectedSkinId) {
      case 0:
        return Colors.cyanAccent;
      case 1:
        return Colors.purpleAccent;
      case 2:
        return Colors.amberAccent;
      case 3:
        return Colors.redAccent;
      case 4:
        return const Color(0xFF00FF00);
      default:
        return Colors.cyanAccent;
    }
  }
}

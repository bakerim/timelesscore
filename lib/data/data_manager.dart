import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static late SharedPreferences _prefs;

  // --- OYUNCU VERİLERİ ---
  static int totalCoins = 0;
  static int maxLevel = 1;
  static double currentXp = 0.0; // EKSİK OLAN DAMAR EKLENDİ
  static bool isAdsRemoved = false; // YENİ: Reklam kaldırma durumu
  static int highScore = 0;

  // --- AYARLAR ---
  static bool isSoundOn = true;
  static bool isMusicOn = true;

  // --- GÜNLÜK ÇARK KONTROLÜ ---
  static String lastSpinDate = "";

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Verileri Yükle
    totalCoins = _prefs.getInt('totalCoins') ?? 0;
    maxLevel = _prefs.getInt('maxLevel') ?? 1;
    currentXp = _prefs.getDouble('currentXp') ?? 0.0; // YÜKLEME EKLENDİ
    isAdsRemoved = _prefs.getBool('isAdsRemoved') ?? false;
    highScore = _prefs.getInt('highScore') ?? 0;

    isSoundOn = _prefs.getBool('isSoundOn') ?? true;
    isMusicOn = _prefs.getBool('isMusicOn') ?? true;

    lastSpinDate = _prefs.getString('lastSpinDate') ?? "";
  }

  static Future<void> saveData() async {
    // Verileri Kaydet
    await _prefs.setInt('totalCoins', totalCoins);
    await _prefs.setInt('maxLevel', maxLevel);
    await _prefs.setDouble('currentXp', currentXp); // KAYDETME EKLENDİ
  }

  static Future<void> saveScore(int score) async {
    if (score > highScore) {
      highScore = score;
      await _prefs.setInt('highScore', highScore);
    }
  }

  static Future<void> updateMaxLevel(int level) async {
    if (level > maxLevel) {
      maxLevel = level;
      await saveData();
    }
  }

  static void setSound(bool value) {
    isSoundOn = value;
    _prefs.setBool('isSoundOn', isSoundOn);
  }

  static void setMusic(bool value) {
    isMusicOn = value;
    _prefs.setBool('isMusicOn', isMusicOn);
  }

  // --- GÜNLÜK ÇARK MANTIĞI ---
  static bool canFreeSpin() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    return lastSpinDate != today;
  }

  static Future<void> setSpinUsed() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    lastSpinDate = today;
    await _prefs.setString('lastSpinDate', lastSpinDate);
  }
  static Future<void> removeAds() async {
  isAdsRemoved = true;
  await _prefs.setBool('isAdsRemoved', true);
}
}

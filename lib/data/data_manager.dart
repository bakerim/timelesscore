import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static late SharedPreferences _prefs;

  // --- OYUNCU VERİLERİ ---
  static int totalCoins = 0;
  static int maxLevel = 1;
  static double currentXp = 0.0;
  static bool isAdsRemoved = false;
  static int highScore = 0;

  static List<int> claimedRewards = [];

  // ==========================================
  // YENİ EKLENEN: TEMA HAFIZASI
  // ==========================================
  static String activeTheme = 'classic_neon'; // Varsayılan tema
  static List<String> unlockedThemes = ['classic_neon']; // Sahip olunan temalar

  // --- AYARLAR ---
  static bool isSoundOn = true;
  static bool isMusicOn = true;

  static String lastSpinDate = "";

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    totalCoins = _prefs.getInt('totalCoins') ?? 0;
    maxLevel = _prefs.getInt('maxLevel') ?? 1;
    currentXp = _prefs.getDouble('currentXp') ?? 0.0;
    isAdsRemoved = _prefs.getBool('isAdsRemoved') ?? false;
    highScore = _prefs.getInt('highScore') ?? 0;

    isSoundOn = _prefs.getBool('isSoundOn') ?? true;
    isMusicOn = _prefs.getBool('isMusicOn') ?? true;
    lastSpinDate = _prefs.getString('lastSpinDate') ?? "";

    List<String>? savedRewards = _prefs.getStringList('claimedRewards');
    claimedRewards = savedRewards?.map((e) => int.parse(e)).toList() ?? [];

    // YENİ: Temaları Yükle
    activeTheme = _prefs.getString('activeTheme') ?? 'classic_neon';
    unlockedThemes = _prefs.getStringList('unlockedThemes') ?? ['classic_neon'];
  }

  static Future<void> saveData() async {
    await _prefs.setInt('totalCoins', totalCoins);
    await _prefs.setInt('maxLevel', maxLevel);
    await _prefs.setDouble('currentXp', currentXp);

    // YENİ: Temaları Kaydet
    await _prefs.setString('activeTheme', activeTheme);
    await _prefs.setStringList('unlockedThemes', unlockedThemes);
  }

  // --- TEMA SATIN ALMA VE SEÇME FONKSİYONLARI ---
  static Future<void> unlockTheme(String themeId) async {
    if (!unlockedThemes.contains(themeId)) {
      unlockedThemes.add(themeId);
      await saveData();
    }
  }

  static Future<void> setActiveTheme(String themeId) async {
    if (unlockedThemes.contains(themeId)) {
      activeTheme = themeId;
      await saveData();
    }
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

  static bool canFreeSpin() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    return lastSpinDate != today;
  }

  static Future<void> setSpinUsed() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    lastSpinDate = today;
    await _prefs.setString('lastSpinDate', lastSpinDate);
  }

  static Future<void> setAdsRemoved(bool isRemoved) async {
    isAdsRemoved = isRemoved;
    await _prefs.setBool('isAdsRemoved', isAdsRemoved);
  }

  static bool isRewardClaimed(int level) {
    return claimedRewards.contains(level);
  }

  static Future<void> claimReward(int level) async {
    if (!claimedRewards.contains(level)) {
      claimedRewards.add(level);
      List<String> stringList =
          claimedRewards.map((e) => e.toString()).toList();
      await _prefs.setStringList('claimedRewards', stringList);
    }
  }
}

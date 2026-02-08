import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager {
  // Singleton yapısı (Her yerden erişim için)
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  int _xp = 0;
  int _level = 1;

  int get xp => _xp;
  int get level => _level;

  // Level atlamak için gereken XP (Örn: Level 1 için 1000, Level 2 için 2000)
  int nextLevelXp(int lvl) => lvl * 1000;

  // Rütbe İsimleri
  String get rankName {
    if (_level <= 5) return "Acemi";
    if (_level <= 10) return "Çırak";
    if (_level <= 20) return "Uzman";
    if (_level <= 50) return "Usta";
    return "Efsane";
  }

  // Başlangıçta verileri yükle
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('player_xp') ?? 0;
    _level = prefs.getInt('player_level') ?? 1;
  }

  // XP Ekleme ve Level Atlama Kontrolü
  Future<void> addXp(int amount) async {
    _xp += amount;
    checkLevelUp();
    await saveProgress();
  }

  void checkLevelUp() {
    int required = nextLevelXp(_level);
    while (_xp >= required) {
      _xp -=
          required; // XP'yi sıfırlayıp level atlatıyoruz (veya birikimli yapabilirsin)
      _level++;
      required = nextLevelXp(_level);
      // Buraya "Level Up" sesi eklenebilir
    }
  }

  // Verileri Kaydet
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_xp', _xp);
    await prefs.setInt('player_level', _level);
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization.dart'; // <-- GERİ GELDİ!

class ProgressManager {
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  int _level = 1;
  int _currentXp = 0;

  int get level => _level;
  int get currentXp => _currentXp;

  int get maxXpForCurrentLevel => _level * 1000;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _level = prefs.getInt('player_level') ?? 1;
    _currentXp = prefs.getInt('player_xp') ?? 0;
  }

  Future<void> addXp(int amount) async {
    _currentXp += amount;

    while (_currentXp >= maxXpForCurrentLevel) {
      _currentXp -= maxXpForCurrentLevel;
      _level++;
    }

    await _saveProgress();
  }

  // --- ARTIK DİL SİSTEMİNDEN ÇEKİYORUZ ---
  String getTitle() {
    if (_level < 5) return Dil.get('rutbe_acemi');
    if (_level < 10) return Dil.get('rutbe_cirak');
    if (_level < 20) return Dil.get('rutbe_kasif');
    if (_level < 30) return Dil.get('rutbe_usta');
    if (_level < 50) return Dil.get('rutbe_efsane');
    if (_level < 80) return Dil.get('rutbe_zaman_yocusu');
    return Dil.get('rutbe_zaman_lordu');
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_level', _level);
    await prefs.setInt('player_xp', _currentXp);
  }

  Future<void> resetProgress() async {
    _level = 1;
    _currentXp = 0;
    await _saveProgress();
  }
}

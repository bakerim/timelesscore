import 'package:flutter/foundation.dart';
import 'data_manager.dart';

class ProgressManager {
  // Singleton yapısı (Projenin neresinden çağırırsan çağır, hep aynı veriye ulaşırsın)
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  // --- REAKTİF DEĞİŞKENLER (TÜM ARAYÜZLER BUNLARI DİNLEYECEK) ---
  final ValueNotifier<int> currentLevel = ValueNotifier<int>(1);
  final ValueNotifier<double> currentXp = ValueNotifier<double>(0.0);
  final ValueNotifier<double> xpToNextLevel = ValueNotifier<double>(1000.0);

  // Sistemi Başlat ve Kayıtlı Veriyi Yükle
  Future<void> init() async {
    // DataManager'dan en son kaydedilen verileri çekiyoruz
    currentLevel.value = DataManager.maxLevel;
    currentXp.value = DataManager.currentXp;
    _calculateNextLevelXp();
  }

  // Seviye hesaplama matematiği (Her level daha da zorlaşır)
  void _calculateNextLevelXp() {
    // Örnek: Level 1 -> 1500 XP, Level 2 -> 2000 XP hedefine sahip olur.
    xpToNextLevel.value = 1000.0 + (currentLevel.value * 500.0);
  }

  // Puan kazanıldığında çağrılır, barı her yerde anında doldurur
  Future<void> addXp(int amount) async {
    currentXp.value += amount;

    // Seviye atlama kontrolü (Çok puan alırsa birden fazla level atlayabilir)
    while (currentXp.value >= xpToNextLevel.value) {
      currentXp.value -= xpToNextLevel.value;
      currentLevel.value++;
      _calculateNextLevelXp();
    }

    // Veritabanına kalıcı olarak kaydet
    DataManager.updateMaxLevel(currentLevel.value);
    DataManager.currentXp = currentXp.value;
    await DataManager.saveData();
  }

  // İlerleme yüzdesini (0.0 ile 1.0 arası) döndürür (Barların UI çizimi için kritik)
  double get progressPercentage {
    if (xpToNextLevel.value == 0) return 0.0;
    return (currentXp.value / xpToNextLevel.value).clamp(0.0, 1.0);
  }
}

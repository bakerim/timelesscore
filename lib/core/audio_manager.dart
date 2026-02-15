import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../data/data_manager.dart';

class AudioManager {
  // Sınıfı "static" yapıyoruz ki her yerden (menülerden, ayarlardan, oyundan)
  // nesne üretmeden doğrudan AudioManager.playSfx() diye çağırabilelim!

  static Future<void> init() async {
    // 1. ÖNBELLEKLEME (CACHE): Performans için tüm sesleri baştan RAM'e yüklüyoruz.
    try {
      await FlameAudio.audioCache.loadAll([
        'sfx/drop.mp3',
        'sfx/clear.mp3',
        'sfx/level_up.mp3',
        'sfx/slow_motion.mp3',
        'sfx/move.mp3', // Arka plan müziğimiz
      ]);
      debugPrint("AudioManager: Tüm ses dosyaları RAM'e yüklendi. 🚀");
    } catch (e) {
      debugPrint("AudioManager: Sesler yüklenirken hata oluştu: $e");
    }
  }

  // 2. EFEKT ÇALICI (Sadece Ayarlardan ses açıksa çalar)
  static void playSfx(String file) {
    if (DataManager.isSoundOn) {
      FlameAudio.play(file);
    }
  }

  // 3. MÜZİK YÖNETİCİSİ
  static void manageBgm(bool play) {
    DataManager.setMusic(play); // Veritabanını anında güncelle
    if (play) {
      if (!FlameAudio.bgm.isPlaying) {
        try {
          // Ses seviyesini (volume) 0.2'de tutuyoruz ki efektleri bastırmasın
          FlameAudio.bgm.play('sfx/move.mp3', volume: 0.2);
        } catch (_) {}
      }
    } else {
      FlameAudio.bgm.stop();
    }
  }

  // 4. OYUN DURAKLATILDIĞINDA MÜZİĞİ SUSTUR
  static void pauseBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
    }
  }

  // 5. OYUN DEVAM ETTİĞİNDE MÜZİĞİ SÜRDÜR
  static void resumeBgm() {
    if (DataManager.isMusicOn && !FlameAudio.bgm.isPlaying) {
      manageBgm(true); // Kaldığı yerden veya baştan başlatır
    }
  }

  // 6. OYUN KOMPLE KAPATILDIĞINDA HAFIZAYI TEMİZLE
  static void dispose() {
    FlameAudio.bgm.dispose();
  }
}

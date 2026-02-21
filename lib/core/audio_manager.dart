import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../data/data_manager.dart';

class AudioManager {
  // --- YENİ EKLENEN: SES HAVUZLARI (PERFORMANS İÇİN) ---
  // Sürekli çağrılan seslerin RAM'i şişirmesini engeller.
  static AudioPool? _dropPool;
  static AudioPool? _clearPool;

  // --- YENİ EKLENEN: ANTI-SPAM ZAMANLAYICILARI ---
  // Aynı milisaniye içinde 10 tane sesin üst üste binip patlamasını önler.
  static DateTime _lastDropTime = DateTime.now();
  static DateTime _lastClearTime = DateTime.now();

  static Future<void> init() async {
    try {
      // 1. Standart/Nadir seslerin önbelleğe alınması
      await FlameAudio.audioCache.loadAll([
        'sfx/level_up.mp3',
        'sfx/slow_motion.mp3',
        'sfx/move.mp3', // Arka plan müziği
      ]);

      // 2. ÇOK TEKRAR EDEN SESLER İÇİN "AUDIO POOL" (SES HAVUZU)
      // Maksimum 3-4 kanal açar. Böylece 1 saat de oynasan oyun kasmaz!
      _dropPool = await FlameAudio.createPool(
        'sfx/drop.mp3',
        minPlayers: 1,
        maxPlayers: 4,
      );

      _clearPool = await FlameAudio.createPool(
        'sfx/clear.mp3',
        minPlayers: 1,
        maxPlayers: 3,
      );

      debugPrint(
          "AudioManager: AAA Seviye Ses Motoru ve Havuzları Başlatıldı. 🚀");
    } catch (e) {
      debugPrint("AudioManager: Sesler yüklenirken hata oluştu: $e");
    }
  }

  // EFEKT ÇALICI (Akıllı Yönlendirme)
  static void playSfx(String file) {
    // Ses kapalıysa hiç işlem yapma
    if (!DataManager.isSoundOn) return;

    try {
      final now = DateTime.now();

      // DÜŞME SESİ (Çok sık çalar)
      if (file == 'sfx/drop.mp3') {
        // 50 milisaniye kalkanı: Bloklar aynı anda inerse sadece 1 ses çıkar.
        if (now.difference(_lastDropTime).inMilliseconds < 50) return;
        _lastDropTime = now;

        if (_dropPool != null) {
          _dropPool!.start();
        } else {
          FlameAudio.play(file); // Havuz yüklenemediyse klasik yöntem
        }
      }
      // TEMİZLENME SESİ
      else if (file == 'sfx/clear.mp3') {
        // 100 milisaniye kalkanı
        if (now.difference(_lastClearTime).inMilliseconds < 100) return;
        _lastClearTime = now;

        if (_clearPool != null) {
          _clearPool!.start();
        } else {
          FlameAudio.play(file);
        }
      }
      // DİĞER (Nadir) SESLER
      else {
        FlameAudio.play(file);
      }
    } catch (e) {
      debugPrint("Ses çalma hatası: $e");
    }
  }

  // 3. MÜZİK YÖNETİCİSİ
  static void manageBgm(bool play) {
    DataManager.setMusic(play);
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
      manageBgm(true);
    }
  }

  // 6. OYUN KOMPLE KAPATILDIĞINDA HAFIZAYI TEMİZLE
  static void dispose() {
    FlameAudio.bgm.dispose();
    // Havuzları da hafızadan siliyoruz
    _dropPool?.dispose();
    _clearPool?.dispose();
  }
}

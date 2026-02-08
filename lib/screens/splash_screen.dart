import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/localization.dart';
import '../data/score_manager.dart';
import '../data/progress_manager.dart';

// DÜZELTME 1: Yeni oluşturduğumuz GameScreen dosyasını import ediyoruz
import 'game_screen.dart';
// Eğer game_wrapper.dart varsa onu silebilirsin veya yorum satırı yapabilirsin.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _status = "Başlatılıyor...";

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    // 1. Dil Yükleme
    if (mounted) {
      setState(() {
        _status = Dil.get("baslatiliyor");
        _progress = 0.1;
      });
    }

    // 2. Reklam SDK
    if (mounted) {
      setState(() {
        _status = Dil.get("reklam_hazir");
        _progress = 0.3;
      });
    }
    try {
      if (!kIsWeb) {
        await MobileAds.instance.initialize();
      }
    } catch (e) {
      debugPrint("Reklam SDK hatası: $e");
    }

    // 3. Sesler
    if (mounted) {
      setState(() {
        _status = Dil.get("sesler");
        _progress = 0.5;
      });
    }
    try {
      // DÜZELTME 2: Yeni eklediğimiz sesleri de önbelleğe alıyoruz.
      // Böylece oyun içinde takılma yapmaz.
      await FlameAudio.audioCache.loadAll([
        'sfx/move.mp3',
        'sfx/drop.mp3',
        'sfx/clear.mp3',
        'sfx/gameover.mp3',
        // Yeni Sesler:
        'sfx/levelup.mp3',
        'sfx/bonus.mp3',
        'sfx/collect.mp3',
        'sfx/powerup.mp3',
      ]);
    } catch (e) {
      debugPrint("Ses hatası: $e");
    }

    // 4. Veriler (Skor + Level)
    if (mounted) {
      setState(() {
        _status = Dil.get("veriler");
        _progress = 0.8;
      });
    }
    await ScoreManager.yukle();
    await ProgressManager().init();

    if (mounted) {
      setState(() {
        _status = Dil.get("hazir");
        _progress = 1.0;
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Yönlendirme
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const GameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121232),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Logo
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent])
                .createShader(bounds),
            child: const Text("TIMELESS\nCORE",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2)),
          ),
          const SizedBox(height: 50),

          // Yükleme Çubuğu
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _progress,
              color: Colors.purpleAccent,
              backgroundColor: Colors.white10,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 20),

          // Durum Yazısı
          Text(_status,
              style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ]),
      ),
    );
  }
}

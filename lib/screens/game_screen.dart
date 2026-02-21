import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

import '../game/timeless_game.dart';

// --- OVERLAY IMPORTLARI ---
import '../overlays/main_menu.dart';
import '../overlays/game_over.dart';
import '../overlays/pause_menu.dart';
import '../overlays/settings_overlay.dart';
import '../overlays/shop_menu.dart';
import '../overlays/roadmap_overlay.dart';
import '../overlays/revive_menu.dart';
import '../overlays/daily_spin_overlay.dart';
import '../overlays/game_hud.dart';
import '../overlays/theme_menu.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final TimelessGame game = TimelessGame();

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    // Web değilse Banner reklamı yükle
    if (!kIsWeb) _loadBanner();

    // Arka plan animasyonu için controller
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Google Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner yükleme hatası: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Uygulamanın aniden kapanmasını engeller
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Geri tuşuna basıldığında oyunun kendi iç mantığını çalıştırır
        game.onBackPressed();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. KATMAN: HAREKETLİ ARKA PLAN
            Positioned.fill(
              child: Container(
                color: const Color(0xFF10102A),
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, child) => CustomPaint(
                    painter: FloatingShapesPainter(_bgController.value),
                  ),
                ),
              ),
            ),

            // 2. KATMAN: FLAME OYUN MOTORU VE MENÜLER
            GameWidget(
              game: game,
              initialActiveOverlays: const ['AnaMenu'],
              overlayBuilderMap: {
                'AnaMenu': (context, game) =>
                    MainMenu(game: game as TimelessGame),
                'GameHUD': (context, game) =>
                    GameHUD(game: game as TimelessGame),
                'GameOver': (context, game) =>
                    GameOver(game: game as TimelessGame),
                'PauseMenu': (context, game) =>
                    PauseMenu(game: game as TimelessGame),
                'ReviveMenu': (context, game) =>
                    ReviveMenu(game: game as TimelessGame),
                'ShopMenu': (context, game) =>
                    ShopMenu(game: game as TimelessGame),
                'Roadmap': (context, game) =>
                    RoadmapOverlay(game: game as TimelessGame),
                'DailySpin': (context, game) =>
                    DailySpinOverlay(game: game as TimelessGame),
                'SettingsMenu': (context, game) =>
                    SettingsOverlay(game: game as TimelessGame),
                'ThemeMenu': (context, game) => 
                    ThemeMenu(game: game as TimelessGame),    
              },
            ),

            // 3. KATMAN: ALT BANNER REKLAM (ShopMenu Açıksa Gizlenir)
            if (_isBannerLoaded &&
                _bannerAd != null &&
                !game.overlays.isActive('ShopMenu'))
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.black, // Reklamın arkasındaki boşluğu kapatır
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- ARKA PLAN ŞEKİL ANİMASYONU ---
class FloatingShapesPainter extends CustomPainter {
  final double anim;
  FloatingShapesPainter(this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);

    for (int i = 0; i < 15; i++) {
      paint.color = i % 2 == 0
          ? Colors.blueAccent.withValues(alpha: 0.05)
          : Colors.purpleAccent.withValues(alpha: 0.05);

      double startX = random.nextDouble() * size.width;
      double startY = random.nextDouble() * size.height;

      // Animasyon değeriyle yukarı doğru akış sağlanır
      double y = (startY - (anim * 300)) % size.height;
      if (y < 0) y += size.height;

      double sizeShape = 30.0 + random.nextDouble() * 80;

      if (i % 3 == 0) {
        canvas.drawCircle(Offset(startX, y), sizeShape / 2, paint);
      } else {
        canvas.save();
        canvas.translate(startX, y);
        canvas.rotate(anim * 2 * pi + i);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: sizeShape, height: sizeShape),
            paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

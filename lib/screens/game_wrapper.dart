import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

import '../game/timeless_game.dart';
import '../overlays/game_over.dart';
// import '../overlays/settings_overlay.dart'; // Ayarlar dosyan varsa yorumu kaldır
// import '../overlays/roadmap_overlay.dart';   // Roadmap dosyan varsa yorumu kaldır

// --- İŞTE EKSİK OLAN SATIR BUYDU! ---
import '../overlays/main_menu.dart';
// ------------------------------------

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
    if (!kIsWeb) _loadBanner();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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
    return Scaffold(
      body: Stack(
        children: [
          // ARKA PLAN
          Positioned.fill(
            child: Container(
              color: const Color(0xFF10102A),
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) => CustomPaint(
                    painter: FloatingShapesPainter(_bgController.value)),
              ),
            ),
          ),

          // OYUN VE MENÜLER
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'AnaMenu': (context, game) =>
                  AnaMenuOverlay(game: game as TimelessGame),
              'GameOver': (context, game) =>
                  GameOverOverlay(game: game as TimelessGame),
              // 'Ayarlar': (context, game) => SettingsOverlay(game: game as TimelessGame),
              // 'Roadmap': (context, game) => RoadmapOverlay(game: game as TimelessGame),
            },
            initialActiveOverlays: const ['AnaMenu'],
          ),

          // REKLAM
          if (_isBannerLoaded && _bannerAd != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FloatingShapesPainter extends CustomPainter {
  final double anim;
  FloatingShapesPainter(this.anim);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      paint.color = i % 2 == 0
          ? Colors.blueAccent.withOpacity(0.05)
          : Colors.purpleAccent.withOpacity(0.05);
      double startX = random.nextDouble() * size.width;
      double startY = random.nextDouble() * size.height;
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

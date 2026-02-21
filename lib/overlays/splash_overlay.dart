import 'dart:async';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';

class SplashOverlay extends StatefulWidget {
  final TimelessGame game;
  const SplashOverlay({super.key, required this.game});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra Ana Menü'ye geçiş yap
    Timer(const Duration(seconds: 3), () {
      // Widget'ın hala ağaçta olduğundan emin ol (güvenlik)
      if (mounted) {
        // Kendini (SplashOverlay) kaldır ve AnaMenu'yü ekle
        widget.game.overlays.remove('Splash');
        widget.game.overlays.add('AnaMenu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Logo
            Image.asset(
              'assets/images/moving_pixel.png',
              width: 250,
            ),
            const SizedBox(height: 40),
            // 2. Yükleme İndikatörü
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ],
        ),
      ),
    );
  }
}

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
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.game.overlays.remove('Splash');
        widget.game.overlays.add('AnaMenu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Arka planı da siyah yapalım
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DÜZELTİLDİ: Artık stüdyo logosunu kullanıyor
            Image.asset(
              'assets/images/moving_pixel.png', // <-- DEĞİŞTİ
              width: 250, 
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ],
        ),
      ),
    );
  }
}

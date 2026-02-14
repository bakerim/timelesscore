import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';

class ReviveMenu extends StatefulWidget {
  final TimelessGame game;
  const ReviveMenu({super.key, required this.game});

  @override
  State<ReviveMenu> createState() => _ReviveMenuState();
}

class _ReviveMenuState extends State<ReviveMenu>
    with SingleTickerProviderStateMixin {
  int _counter = 5;
  late Timer _timer;
  late AnimationController _controller;

  bool _canTap = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _canTap = true);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          timer.cancel();
          widget.game.vazgecVeBitir();
        }
      });
    });
  }

  void _showReviveAd() {
    if (!_canTap) return;

    _timer.cancel();
    setState(() => _canTap = false);

    widget.game.reklamIzleVeCanlan();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. ARKA PLAN BLUR
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),

          // 2. İÇERİK
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Dil.get("ikinci_sans"), // HATA VEREN KISIM TEMİZLENDİ
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.greenAccent, blurRadius: 15)
                      ]),
                ),
                const SizedBox(height: 10),
                Text(
                  Dil.get("devam_et_aciklama"), // HATA VEREN KISIM TEMİZLENDİ
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- GERİ SAYIM HALKASI ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _counter / 5,
                        color: Colors.cyanAccent,
                        backgroundColor: Colors.white10,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      "$_counter",
                      style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.cyanAccent, blurRadius: 10)
                          ]),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // --- AKILLI REKLAM İZLE BUTONU ---
                _buildReviveButton(),

                const SizedBox(height: 25),

                // --- VAZGEÇ BUTONU ---
                TextButton(
                  onPressed: () {
                    _timer.cancel();
                    widget.game.vazgecVeBitir();
                  },
                  child: Text(Dil.get("vazgec"), // HATA VEREN KISIM TEMİZLENDİ
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviveButton() {
    // HATA VEREN KISIMLAR TEMİZLENDİ
    String buttonText =
        _canTap ? Dil.get("izle_devam_et") : Dil.get("reklam_yukleniyor");
    Color buttonColor =
        _canTap ? Colors.greenAccent.shade700 : Colors.grey.shade800;
    IconData buttonIcon = _canTap
        ? Icons.play_circle_fill_rounded
        : Icons.hourglass_empty_rounded;

    Widget buttonChild = ElevatedButton.icon(
      onPressed: _canTap ? _showReviveAd : null,
      icon: Icon(buttonIcon, size: 32),
      label: Text(buttonText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade900,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
    );

    if (_canTap) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.greenAccent.withOpacity(0.6 * _controller.value),
                    blurRadius: 20 + (10 * _controller.value),
                    spreadRadius: 2,
                  )
                ]),
            child: child,
          );
        },
        child: buttonChild,
      );
    }

    return buttonChild;
  }
}

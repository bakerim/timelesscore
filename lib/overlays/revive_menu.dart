import 'dart:async';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';

class ReviveMenuOverlay extends StatefulWidget {
  final TimelessGame game;
  const ReviveMenuOverlay({super.key, required this.game});

  @override
  State<ReviveMenuOverlay> createState() => _ReviveMenuOverlayState();
}

class _ReviveMenuOverlayState extends State<ReviveMenuOverlay>
    with SingleTickerProviderStateMixin {
  int _counter = 5;
  late Timer _timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
      } else {
        // Süre doldu, hakkını kaybetti
        widget.game.vazgecVeBitir();
      }
    });
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
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "DEVAM ETMEK İSTER MİSİN?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // GERİ SAYIM HALKASI
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _counter / 5,
                    color: Colors.cyanAccent,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    strokeWidth: 10,
                  ),
                ),
                Text(
                  "$_counter",
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 60,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // REKLAM İZLE BUTONU (Parlayan)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent
                          .withOpacity(0.5 * _controller.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]),
                  child: child,
                );
              },
              child: ElevatedButton.icon(
                onPressed: () {
                  _timer.cancel(); // Sayacı durdur
                  // Reklamı başlat (Revive modunda)
                  widget.game.reklamGoster(AdPurpose.revive);
                },
                icon: const Icon(Icons.play_circle_fill, size: 30),
                label: const Text("İZLE VE DEVAM ET",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // VAZGEÇ BUTONU
            TextButton(
              onPressed: () {
                _timer.cancel();
                widget.game.vazgecVeBitir();
              },
              child: const Text("Hayır, Pes Ediyorum",
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

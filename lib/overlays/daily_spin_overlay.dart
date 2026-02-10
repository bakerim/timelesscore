import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';

class DailySpinOverlay extends StatefulWidget {
  final TimelessGame game;
  const DailySpinOverlay({super.key, required this.game});

  @override
  State<DailySpinOverlay> createState() => _DailySpinOverlayState();
}

class _DailySpinOverlayState extends State<DailySpinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Çark Dilimleri (Ödüller)
  final List<int> _rewards = [5, 10, 20, 50, 100, 250];
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.amber
  ];

  bool _isSpinning = false;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 Saniye dönecek
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // Rastgele bir ödül seç (0 ile 5 arası index)
    // Şans faktörü: Büyük ödüllerin çıkma ihtimalini düşürebilirsin burada.
    // Şimdilik tamamen rastgele yapıyoruz.
    int winningIndex = Random().nextInt(_rewards.length);

    // Dönme Hesabı:
    // 5 tam tur (5 * 2pi) + Hedef dilime kadar olan açı
    double sectorAngle = 2 * pi / _rewards.length;
    double targetAngle = 5 * 2 * pi + (winningIndex * sectorAngle);

    // Tween güncellemesi
    _animation = Tween<double>(
            begin: _currentRotation, end: _currentRotation + targetAngle)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentRotation += targetAngle; // Sonraki çeviriş için açıyı sakla
        _isSpinning = false;

        // ÖDÜLÜ VER!
        int reward =
            _rewards[_rewards.length - 1 - winningIndex]; // Tersten index
        _claimReward(reward);
      });
    });
  }

  void _claimReward(int amount) {
    DataManager.totalCoins += amount;
    DataManager.saveData();
    widget.game.elmasYazisi.text = '💎 ${DataManager.totalCoins}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.celebration, color: Colors.amber, size: 50),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("TEBRİKLER!",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            const SizedBox(height: 10),
            Text("+$amount Zaman Kristali Kazandın!",
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialog kapa
              widget.game.overlays.remove('DailySpin'); // Overlay kapa
              widget.game.overlays.add('AnaMenu'); // Ana menüye dön
            },
            child: const Text("HARİKA",
                style: TextStyle(
                    color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur Arka Plan
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ŞANS ÇARKI",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2),
                ),
                const Text("Günde 1 kez ücretsiz!",
                    style: TextStyle(color: Colors.amberAccent)),
                const SizedBox(height: 40),

                // --- ÇARK GÖVDESİ ---
                SizedBox(
                  height: 320,
                  width: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // OK İŞARETİ (Tepede Sabit)
                      const Positioned(
                        top: 0,
                        child: Icon(Icons.arrow_drop_down_rounded,
                            color: Colors.white, size: 50),
                      ),

                      // DÖNEN KISIM
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.5),
                                        blurRadius: 20)
                                  ]),
                              child: CustomPaint(
                                size: const Size(300, 300),
                                painter: WheelPainter(
                                    rewards: _rewards, colors: _colors),
                              ),
                            ),
                          );
                        },
                      ),

                      // ORTA BUTON (SPIN)
                      GestureDetector(
                        onTap: _spinWheel,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10)
                              ],
                              border: Border.all(
                                  color: Colors.purpleAccent, width: 4)),
                          child: Center(
                            child: Text(
                              _isSpinning ? "..." : "ÇEVİR",
                              style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // KAPAT BUTONU
                if (!_isSpinning)
                  TextButton.icon(
                    onPressed: () {
                      widget.game.overlays.remove('DailySpin');
                      widget.game.overlays.add('AnaMenu');
                    },
                    icon: const Icon(Icons.close, color: Colors.white54),
                    label: const Text("Kapat",
                        style: TextStyle(color: Colors.white54)),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Çarkı Çizen Ressam Sınıfı
class WheelPainter extends CustomPainter {
  final List<int> rewards;
  final List<Color> colors;

  WheelPainter({required this.rewards, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double anglePerSlice = 2 * pi / rewards.length;
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < rewards.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];

      // Dilimi Çiz
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerSlice - (pi / 2), // -90 derece ofset ile tepeden başlat
        anglePerSlice,
        true,
        paint,
      );

      // Yazıyı Çiz (Matematiksel Döndürme)
      _drawText(canvas, size, rewards[i].toString(), i * anglePerSlice,
          anglePerSlice);
    }
  }

  void _drawText(Canvas canvas, Size size, String text, double startAngle,
      double sweepAngle) {
    final textStyle = const TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    double angle = startAngle - (pi / 2) + (sweepAngle / 2);
    double radius = size.width / 2 * 0.7; // Merkeze uzaklık

    double x = (size.width / 2) + radius * cos(angle);
    double y = (size.height / 2) + radius * sin(angle);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle + (pi / 2)); // Yazıyı merkeze bakacak şekilde döndür
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

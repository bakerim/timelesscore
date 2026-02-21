import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../core/audio_manager.dart'; // YENİ: Ses Bakanlığını ekledik!

class DailySpinOverlay extends StatefulWidget {
  final TimelessGame game;
  const DailySpinOverlay({super.key, required this.game});

  @override
  State<DailySpinOverlay> createState() => _DailySpinOverlayState();
}

class _DailySpinOverlayState extends State<DailySpinOverlay>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _pulseController;

  bool _isSpinning = false;
  late bool canFree;
  double _currentAngle = 0;

  // Çarktaki efsanevi ödüller ve neon renkleri
  final List<Map<String, dynamic>> rewards = [
    {'amount': 1, 'color': Colors.blueAccent},
    {'amount': 3, 'color': Colors.purpleAccent},
    {'amount': 5, 'color': Colors.greenAccent},
    {'amount': 10, 'color': Colors.orangeAccent},
    {'amount': 15, 'color': Colors.redAccent},
    {'amount': 25, 'color': Colors.amberAccent}, // Büyük İkramiye
  ];

  @override
  void initState() {
    super.initState();
    canFree = DataManager.canFreeSpin();

    _spinController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _spinAnimation =
        CurvedAnimation(parent: _spinController, curve: Curves.decelerate);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSpin() {
    if (_isSpinning) return;

    if (canFree) {
      _startSpin(isFree: true);
    } else {
      widget.game.adManager.showRewardedAd(
          onReward: (amount) => _startSpin(isFree: false),
          onAdFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Bağlantı koptu, reklam yüklenemedi. 📡"),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating));
          });
    }
  }

  void _startSpin({required bool isFree}) {
    setState(() => _isSpinning = true);

    if (!kIsWeb) HapticFeedback.heavyImpact();

    // YENİ: Sesi AudioManager ile çağırıyoruz!
    AudioManager.playSfx('sfx/spin.mp3');

    int randomIndex = Random().nextInt(rewards.length);
    double segmentAngle = (2 * pi) / rewards.length;

    int extraSpins = 5 + Random().nextInt(5);
    double targetAngle = (extraSpins * 2 * pi) - (randomIndex * segmentAngle);

    double startAngle = _currentAngle;
    double endAngle = startAngle + targetAngle;

    _spinAnimation = Tween<double>(begin: startAngle, end: endAngle).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.fastOutSlowIn));

    _spinController.forward(from: 0.0).then((_) {
      _currentAngle = endAngle % (2 * pi);

      if (isFree) {
        DataManager.setSpinUsed();
        setState(() => canFree = false);
      }

      _onSpinEnd(rewards[randomIndex]['amount'], rewards[randomIndex]['color']);
    });
  }

  void _onSpinEnd(int rewardAmount, Color rewardColor) {
    setState(() => _isSpinning = false);

    DataManager.totalCoins += rewardAmount;
    DataManager.saveData();

    if (!kIsWeb) HapticFeedback.vibrate();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.diamond_rounded, color: rewardColor, size: 28),
          const SizedBox(width: 15),
          Text("+$rewardAmount KRİSTAL KAZANDIN!",
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1))
        ],
      ),
      backgroundColor: Colors.green.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withValues(alpha: 0.88))),
          Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.3),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 5)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.casino_rounded,
                          color: Colors.amberAccent, size: 36),
                      SizedBox(width: 10),
                      Text("KADER ÇARKI",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                              color: canFree
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: canFree
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent)),
                          child: Text(
                            canFree
                                ? "Bugünkü ÜCRETSİZ çevirme hakkın hazır!"
                                : "Ücretsiz hakkını kullandın.\nReklam izleyerek tekrar çevir!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: canFree
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                      color: canFree
                                          ? Colors.green
                                          : Colors.orange,
                                      blurRadius: 10)
                                ]),
                          ),
                        );
                      }),
                  const SizedBox(height: 35),
                  _buildWheelGraphic(),
                  const SizedBox(height: 45),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton.icon(
                      onPressed: _isSpinning ? null : _handleSpin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canFree
                            ? Colors.green.shade600
                            : Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: _isSpinning ? 0 : 10,
                        shadowColor:
                            canFree ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      icon: Icon(
                          _isSpinning
                              ? Icons.hourglass_top_rounded
                              : (canFree
                                  ? Icons.autorenew_rounded
                                  : Icons.ondemand_video_rounded),
                          size: 26),
                      label: Text(
                          _isSpinning
                              ? "DÖNÜYOR..."
                              : (canFree
                                  ? "ÜCRETSİZ ÇEVİR"
                                  : "REKLAM İZLE & ÇEVİR"),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed:
                        _isSpinning ? null : () => widget.game.anaMenuyeDon(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 20),
                    label: const Text("ÇIK VE ANA MENÜYE DÖN",
                        style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelGraphic() {
    return SizedBox(
      height: 260,
      width: 260,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E293B),
                        border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.5),
                            width: 5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5),
                          const BoxShadow(color: Colors.black54, blurRadius: 20)
                        ]),
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(rewards.length, (index) {
                        double angle = (2 * pi * index) / rewards.length;
                        return Transform.rotate(
                          angle: angle,
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("${rewards[index]['amount']}",
                                          style: TextStyle(
                                              color: rewards[index]['color'],
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900)),
                                      Icon(Icons.diamond_rounded,
                                          color: rewards[index]['color'],
                                          size: 18),
                                    ],
                                  ))),
                        );
                      }),
                    ),
                  ),
                );
              }),
          Positioned(
              top: -15,
              child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Icon(Icons.arrow_drop_down_circle_rounded,
                        color: Colors.redAccent,
                        size: 45,
                        shadows: [
                          Shadow(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              blurRadius: 10)
                        ]);
                  })),
          Positioned(
              top: 115,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyanAccent, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 5)
                    ]),
              ))
        ],
      ),
    );
  }
}

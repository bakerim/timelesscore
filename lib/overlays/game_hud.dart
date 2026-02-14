import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart'; // Senkronizasyon için eklendi

class GameHUD extends StatefulWidget {
  final TimelessGame game;
  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  // --- Senin Orijinal Animasyonların ---
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _readyController;
  late Animation<double> _glowAnimation;

  int _coins = 0;
  final int _abilityCost = 5;

  @override
  void initState() {
    super.initState();
    _coins = DataManager.totalCoins;

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _readyController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(
        CurvedAnimation(parent: _readyController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _readyController.dispose();
    super.dispose();
  }

  void _watchAdAndEarn() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += 3;
          DataManager.saveData();
          _coins = DataManager.totalCoins;
          widget.game.elmasYazisi.text = '💎 $_coins';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("ENERJİ YÜKLENDİ! +3 💎",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.cyan.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))));
      },
      onAdFailed: () => debugPrint("Reklam hatası"),
    );
  }

  void _triggerTimeBender() {
    if (_coins >= _abilityCost) {
      widget.game.manuelZamanYavaslat();
      setState(() => _coins = DataManager.totalCoins);
    } else {
      _watchAdAndEarn();
    }
  }

  @override
  Widget build(BuildContext context) {
    _coins = DataManager.totalCoins;
    double fillPercent = (_coins / _abilityCost).clamp(0.0, 1.0);
    bool isReady = _coins >= _abilityCost;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==========================================
            // 1. EKLENEN YENİ ÖZELLİK: SENKRONİZE LEVEL BAR
            // ==========================================
            IgnorePointer(
              // Bu kısma dokunmayı engeller (oyun akışını bozmamak için)
              child: ValueListenableBuilder<double>(
                valueListenable: ProgressManager().currentXp,
                builder: (context, xp, child) {
                  int level = ProgressManager().currentLevel.value;
                  double progress = ProgressManager().progressPercentage;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    margin: const EdgeInsets.only(
                        bottom: 15), // Zaman bükücü butonuyla arasına mesafe
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.1),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.military_tech,
                                color: Colors.amberAccent, size: 20),
                            const SizedBox(width: 5),
                            Text("LEVEL $level",
                                style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 150,
                          height: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.cyanAccent)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==========================================
            // 2. SENİN ORİJİNAL ZAMAN BÜKÜCÜ BUTONUN
            // ==========================================
            // ... (Kalan tüm kodlar senin gönderdiğin ile birebir aynı)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: isReady
                            ? Colors.cyanAccent.withValues(alpha: 0.3)
                            : Colors.white10,
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond,
                          color: Colors.cyanAccent, size: 14),
                      const SizedBox(width: 6),
                      Text("$_coins",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(width: 8),
                      ScaleTransition(
                        scale: !isReady
                            ? _pulseAnimation
                            : const AlwaysStoppedAnimation(1.0),
                        child: GestureDetector(
                          onTap: _watchAdAndEarn,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: !isReady
                                        ? [
                                            Colors.orangeAccent,
                                            Colors.deepOrange
                                          ]
                                        : [Colors.green, Colors.teal]),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            GestureDetector(
              onTap: _triggerTimeBender,
              child: AnimatedBuilder(
                animation: _readyController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isReady)
                        Container(
                          width: 65,
                          height: 65,
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.6),
                                blurRadius: _glowAnimation.value,
                                spreadRadius: 2)
                          ]),
                        ),
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: CircularProgressIndicator(
                            value: fillPercent,
                            strokeWidth: 4,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(isReady
                                ? Colors.cyanAccent
                                : Colors.orangeAccent)),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: isReady
                                    ? [
                                        Colors.cyan.shade300,
                                        Colors.blue.shade800
                                      ]
                                    : [
                                        Colors.blueGrey.shade800,
                                        Colors.grey.shade900
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(2, 4),
                                  blurRadius: 5)
                            ]),
                        child: Icon(
                            isReady ? Icons.ac_unit_rounded : Icons.lock_clock,
                            color: isReady ? Colors.white : Colors.white24,
                            size: 28),
                      ),
                      if (!isReady)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2)),
                            child: const Icon(Icons.play_arrow,
                                size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

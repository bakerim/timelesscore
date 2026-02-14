import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';

class MainMenu extends StatefulWidget {
  final TimelessGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Play butonu ve logo için hafif nefes alma efekti
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- KUSURSUZ NAVİGASYON ---
  void _openOverlay(String overlayName) {
    widget.game.overlays.remove('AnaMenu');
    widget.game.overlays.add(overlayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ==========================================
              // 1. ÜST BAR: SENKRONİZE LEVEL VE KRİSTAL
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- REAKTİF LEVEL BAR ---
                  ValueListenableBuilder<double>(
                    valueListenable: ProgressManager().currentXp,
                    builder: (context, xp, child) {
                      int level = ProgressManager().currentLevel.value;
                      double progress = ProgressManager().progressPercentage;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.cyanAccent.withValues(alpha: 0.1),
                                  blurRadius: 10)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                width: 130,
                                height: 6,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.cyanAccent)))),
                          ],
                        ),
                      );
                    },
                  ),

                  // --- KRİSTAL GÖSTERGESİ ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.purpleAccent.withValues(alpha: 0.4),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Colors.purpleAccent.withValues(alpha: 0.15),
                              blurRadius: 10)
                        ]),
                    child: Row(
                      children: [
                        Text("${DataManager.totalCoins}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                        const SizedBox(width: 8),
                        const Icon(Icons.diamond_rounded,
                            color: Colors.purpleAccent, size: 22),
                      ],
                    ),
                  ),
                ],
              ),

              // ==========================================
              // 2. MERKEZ: LOGO VE PLAY BUTONU
              // ==========================================
              Column(
                children: [
                  AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Icon(Icons.hourglass_empty_rounded,
                            color: Colors.cyanAccent,
                            size: 90,
                            shadows: [
                              Shadow(
                                  color:
                                      Colors.cyanAccent.withValues(alpha: 0.6),
                                  blurRadius: _glowAnimation.value)
                            ]);
                      }),
                  const SizedBox(height: 15),
                  const Text("TIMELESS CORE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: Colors.cyanAccent, blurRadius: 20)
                          ])),
                  const SizedBox(height: 50),

                  // --- PLAY BUTONU ---
                  GestureDetector(
                    onTap: () => widget.game.oyunuBaslat(),
                    child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 220,
                            height: 75,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.cyanAccent.shade700,
                                      Colors.blueAccent.shade700
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.cyanAccent
                                          .withValues(alpha: 0.4),
                                      blurRadius: _glowAnimation.value * 2,
                                      spreadRadius: 2),
                                  const BoxShadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 5),
                                      blurRadius: 10)
                                ]),
                            child: const Center(
                                child: Text("PLAY",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 5))),
                          );
                        }),
                  ),
                ],
              ),

              // ==========================================
              // 3. ALT MENÜ: KUSURSUZ GEÇİŞLER
              // ==========================================
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuButton(Icons.storefront_rounded,
                        Colors.orangeAccent, () => _openOverlay('ShopMenu')),
                    _buildMenuButton(Icons.map_rounded, Colors.greenAccent,
                        () => _openOverlay('Roadmap')),
                    _buildMenuButton(Icons.casino_rounded, Colors.purpleAccent,
                        () => _openOverlay('DailySpin')),
                    _buildMenuButton(
                        Icons.settings_rounded,
                        Colors.grey.shade400,
                        () => _openOverlay('SettingsMenu')),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Alt menü butonları için şık tasarım fonksiyonu
  Widget _buildMenuButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1)
            ]),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

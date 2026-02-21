import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/progress_manager.dart';
import '../data/data_manager.dart';
import '../core/localization.dart';

class MainMenu extends StatefulWidget {
  final TimelessGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openOverlay(String overlayName) {
    widget.game.overlays.add(overlayName);
  }

  String _getRankName(int level) {
    if (level < 5) return Dil.get('rutbe_cirak');
    if (level < 15) return Dil.get('rutbe_acemi');
    if (level < 30) return Dil.get('rutbe_kasif');
    if (level < 50) return Dil.get('rutbe_usta');
    if (level < 80) return Dil.get('rutbe_zaman_yocusu');
    return Dil.get('rutbe_efsane');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // --- ARKA PLAN EFEKTİ ---
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Colors.cyan.withValues(alpha: 0.15),
                    const Color(0xFF0A0E17).withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),

          // --- ANA İÇERİK ---
          SafeArea(
            child: Stack(
              children: [
                // 1. VE 2. KISIM: LOGO VE ORTA BUTONLAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      const Spacer(flex: 2), // Üstten boşluk

                      // --- 1. ÜST KISIM: LOGO ---
                      Column(
                        children: [
                          AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.cyanAccent
                                              .withValues(alpha: 0.5),
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.cyanAccent
                                                .withValues(alpha: 0.3),
                                            blurRadius: _glowAnimation.value,
                                            spreadRadius: 2)
                                      ]),
                                  child: const Icon(
                                      Icons.hourglass_empty_rounded,
                                      color: Colors.cyanAccent,
                                      size: 40),
                                );
                              }),
                          const SizedBox(height: 10),
                          Text(
                            Dil.get('baslik'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                      color: Colors.cyanAccent, blurRadius: 15)
                                ]),
                          ),
                        ],
                      ),

                      const Spacer(flex: 3), // Logo ve Orta kısım arası mesafe

                      // --- 2. ORTA KISIM: LEVEL VE ANA BUTONLAR ---
                      Column(
                        children: [
                          ValueListenableBuilder<int>(
                              valueListenable: ProgressManager().currentLevel,
                              builder: (context, currentLevel, child) {
                                double targetXp = currentLevel * 1000.0;
                                double currentXp = DataManager.currentXp;
                                double progress =
                                    (currentXp / targetXp).clamp(0.0, 1.0);

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B)
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.05)),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 5),
                                            blurRadius: 10)
                                      ]),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                            color: Colors.cyanAccent,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.cyanAccent,
                                                  blurRadius: 10)
                                            ]),
                                        child: Center(
                                            child: Text("$currentLevel",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w900))),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_getRankName(currentLevel),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1)),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                minHeight: 6,
                                                backgroundColor: Colors.black45,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.cyanAccent),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                                "${currentXp.toInt()} / ${targetXp.toInt()} XP",
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.5),
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                          const SizedBox(height: 15),
                          _ClassicMenuButton(
                            icon: Icons.play_arrow_rounded,
                            label: Dil.get('basla'),
                            colors: [
                              Colors.greenAccent.shade400,
                              Colors.green.shade600
                            ],
                            onTap: () => widget.game.oyunuBaslat(),
                          ),
                          const SizedBox(height: 10),
                          _ClassicMenuButton(
                            icon: Icons.shopping_bag_rounded,
                            label: Dil.get('market'),
                            colors: [
                              Colors.purpleAccent.shade400,
                              Colors.deepPurple.shade700
                            ],
                            onTap: () => _openOverlay('ShopMenu'),
                          ),
                          const SizedBox(height: 10),
                          _ClassicMenuButton(
                            icon: Icons.palette_rounded,
                            label: Dil.get('temalar'),
                            colors: [
                              Colors.blueAccent.shade400,
                              Colors.indigo.shade700
                            ],
                            onTap: () => _openOverlay('ThemeMenu'),
                          ),
                        ],
                      ),

                      const Spacer(
                          flex:
                              6), // Alt kısımdaki butonlar ve banner için bolca alan bırakıyoruz
                    ],
                  ),
                ),

                // --- 3. ALT KISIM: YARDIMCI BUTONLAR ---
                // Positioned ile banner boşluğunu garanti altına alarak tam 80px yukarıya sabitliyoruz.
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavButton(
                          icon: Icons.map_rounded,
                          label: Dil.get('yol_haritasi'),
                          color: Colors.pinkAccent,
                          onTap: () => _openOverlay('Roadmap')),
                      _BottomNavButton(
                          icon: Icons.casino_rounded,
                          label: Dil.get('cark'),
                          color: Colors.orangeAccent,
                          onTap: () => _openOverlay('DailySpin')),
                      _BottomNavButton(
                          icon: Icons.settings_rounded,
                          label: Dil.get('ayarlar'),
                          color: Colors.amberAccent,
                          onTap: () => _openOverlay('SettingsMenu')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- ÖZEL BUTON WIDGET'LARI ---

class _ClassicMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ClassicMenuButton(
      {required this.icon,
      required this.label,
      required this.colors,
      required this.onTap});

  @override
  State<_ClassicMenuButton> createState() => _ClassicMenuButtonState();
}

class _ClassicMenuButtonState extends State<_ClassicMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.95,
        upperBound: 1.0)
      ..value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: widget.colors.first.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomNavButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  State<_BottomNavButton> createState() => _BottomNavButtonState();
}

class _BottomNavButtonState extends State<_BottomNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.90,
        upperBound: 1.0)
      ..value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
              color: const Color(0xFF141A29),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: widget.color.withValues(alpha: 0.3), width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

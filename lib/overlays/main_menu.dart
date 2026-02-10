import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../data/progress_manager.dart';

class MainMenu extends StatefulWidget {
  final TimelessGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _xp = 0;
  int _level = 1;
  int _maxXp = 100;
  String _title = "ACEMİ";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pm = ProgressManager();
    await pm.init();
    setState(() {
      _xp = pm.currentXp;
      _level = pm.level;
      _maxXp = pm.maxXpForCurrentLevel;
      _title = pm.getTitle();
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_maxXp == 0) ? 0 : (_xp / _maxXp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. ARKA PLAN BLUR (Sadece sahne flulaşsın)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // 2. ORTA MENÜ (O sevdiğin tasarım)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- LOGO ---
                const Text(
                  'TIMELESS',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.cyanAccent,
                    letterSpacing: 8,
                    shadows: [
                      Shadow(
                          color: Colors.cyan,
                          blurRadius: 20,
                          offset: Offset(0, 0))
                    ],
                  ),
                ),
                Text(
                  'C O R E',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 50),

                // --- LEVEL KARTI (Glassmorphism) ---
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5)
                      ]),
                  child: Row(
                    children: [
                      // Level Yuvarlağı
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.cyanAccent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.2),
                                  blurRadius: 15)
                            ]),
                        child: Center(
                          child: Text(
                            '$_level',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Bilgiler
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            // Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.black54,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.purpleAccent),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$_xp / $_maxXp XP',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // --- BÜYÜK BUTONLAR ---
                _buildMainButton(
                  label: Dil.get('oyna'),
                  icon: Icons.play_arrow_rounded,
                  color: Colors.greenAccent.shade400,
                  onTap: () {
                    widget.game.overlays.remove('AnaMenu');
                    widget.game.oyunuBaslat();
                  },
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  label: Dil.get('market'),
                  icon: Icons.shopping_bag_rounded,
                  color: Colors.purpleAccent.shade400,
                  onTap: () {
                    widget.game.overlays.remove('AnaMenu');
                    widget.game.overlays.add('Shop');
                  },
                ),

                const SizedBox(height: 40),

                // --- ALT KÜÇÜK BUTONLAR (Yol Haritası, Ayarlar, Çark) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallButton(
                        icon: Icons.map_rounded,
                        label: Dil.get('yol_haritasi'),
                        onTap: () {
                          widget.game.overlays.remove('AnaMenu');
                          widget.game.overlays.add('Roadmap');
                        }),
                    const SizedBox(width: 25),
                    _buildSmallButton(
                        icon: Icons.casino_rounded, // ŞANS ÇARKI BURADA
                        label: "ÇARK",
                        color: Colors.amber,
                        onTap: () {
                          widget.game.overlays.remove('AnaMenu');
                          widget.game.overlays.add('DailySpin');
                        }),
                    const SizedBox(width: 25),
                    _buildSmallButton(
                        icon: Icons.settings,
                        label: Dil.get('ayarlar'),
                        onTap: () {
                          widget.game.overlays.remove('AnaMenu');
                          widget.game.overlays.add('Settings');
                        }),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 60,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 30),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton(
      {required IconData icon,
      required String label,
      Color color = Colors.white,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5))),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

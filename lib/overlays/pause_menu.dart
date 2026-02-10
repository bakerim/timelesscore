import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';

class PauseMenu extends StatefulWidget {
  final TimelessGame game;
  const PauseMenu({super.key, required this.game});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animasyon yükünü minimumda tutuyoruz
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose(); // Bellek sızıntısını önlemek için ŞART
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. BLUR KATMANI (Performans dostu seviyede tutuldu)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child:
                  Container(color: const Color(0xFF0F172A).withOpacity(0.85)),
            ),
          ),

          // 2. KONTROL PANELİ
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4), blurRadius: 20)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BAŞLIK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pause_circle_outline,
                          color: Colors.cyanAccent, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        Dil.get("duraklatildi").toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- DURUM ÖZETİ ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                            Dil.get("seviye"), "${widget.game.currentLevel}"),
                        Container(width: 1, height: 30, color: Colors.white10),
                        _buildStat(Dil.get("puan"), "${widget.game.skor}"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- ANA BUTON: DEVAM ET ---
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: () => widget.game.togglePause(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.cyanAccent, Colors.blueAccent]),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.cyan.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                color: Colors.black, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              Dil.get("devam_et"),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- ALT BUTONLAR (KİBAR VE ŞIK) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSmallAction(
                        icon: Icons.refresh_rounded,
                        color: Colors.orangeAccent,
                        onTap: () {
                          widget.game.overlays.remove('PauseMenu');
                          widget.game.oyunuBaslat();
                        },
                      ),
                      _buildSmallAction(
                        icon: Icons.settings_outlined,
                        color: Colors.white70,
                        onTap: () => widget.game.overlays.add('Settings'),
                      ),
                      _buildSmallAction(
                        icon: Icons.home_rounded,
                        color: Colors.redAccent,
                        onTap: () => widget.game.anaMenuyeDon(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallAction(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 55,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

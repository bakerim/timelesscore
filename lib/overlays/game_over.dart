import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../data/data_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final TimelessGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Arka Plan Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.redAccent.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.redAccent.withOpacity(0.2), blurRadius: 40)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Dil.get("oyun_bitti"),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Skor Bilgileri
                  _buildScoreRow(Dil.get("puan"), "${game.skor}"),
                  const Divider(color: Colors.white10, height: 30),
                  _buildScoreRow(Dil.get("rekor"), "${DataManager.highScore}"),

                  const SizedBox(height: 35),

                  // --- YENİ BUTON: 2X KAZAN ---
                  // Bu buton sadece reklam hazırsa daha parlak görünebilir
                  _buildButton(
                    label: Dil.get("iki_kat_kazan"),
                    icon: Icons.ads_click_rounded,
                    color: Colors.amber,
                    onTap: () => game.reklamGoster(AdPurpose.doubleScore),
                  ),

                  const SizedBox(height: 12),

                  // ANA MENÜ BUTONU
                  _buildButton(
                    label: Dil.get("ana_menu"),
                    icon: Icons.home_rounded,
                    color: Colors.cyanAccent,
                    onTap: () => game.anaMenuyeDon(),
                  ),

                  const SizedBox(height: 12),

                  // YOL HARİTASI BUTONU
                  _buildButton(
                    label: Dil.get("yol_haritasi"),
                    icon: Icons.map_outlined,
                    color: Colors.white,
                    isOutlined: true,
                    onTap: () {
                      game.overlays.remove('GameOver');
                      game.overlays.add('Roadmap');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.black,
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: isOutlined ? 0 : 8,
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../core/localization.dart';

class PauseMenuOverlay extends StatelessWidget {
  final TimelessGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pause_circle_filled,
                      color: Colors.cyanAccent, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    "PAUSE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  _buildMenuButton(
                    label: "DEVAM ET",
                    icon: Icons.play_arrow,
                    color: Colors.greenAccent,
                    onTap: () => game.togglePause(),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    label: Dil.get("tekrar_oyna"),
                    icon: Icons.refresh,
                    color: Colors.amberAccent,
                    onTap: () => game.oyunuBaslat(),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    label: Dil.get("ana_menu"),
                    icon: Icons.home,
                    color: Colors.white70,
                    onTap: () => game.anaMenuyeDon(),
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isOutlined ? 0 : 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

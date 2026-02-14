import 'package:flutter/material.dart';

class EvolutionCore extends StatelessWidget {
  final int level; // ProgressManager'dan gelecek seviye

  const EvolutionCore({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Seviyeye göre görsel özellikler
    Color coreColor;
    double size;
    List<BoxShadow> shadows;
    IconData? icon;

    switch (level) {
      case 0: // Başlangıç
        coreColor = Colors.grey.shade700;
        size = 60;
        shadows = [const BoxShadow(color: Colors.black54, blurRadius: 10)];
        icon = null;
        break;
      case 1: // Çırak (Mavi Enerji)
        coreColor = Colors.blueAccent;
        size = 70;
        shadows = [
          BoxShadow(
              color: Colors.blue.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2)
        ];
        icon = Icons.bolt;
        break;
      case 2: // Usta (Mor Alev)
        coreColor = Colors.purpleAccent;
        size = 80;
        shadows = [
          BoxShadow(
              color: Colors.purple.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 5),
          BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 5)
        ];
        icon = Icons.auto_awesome;
        break;
      default: // Efsane (Altın Çekirdek)
        coreColor = Colors.amber;
        size = 90;
        shadows = [
          BoxShadow(
              color: Colors.orange.withOpacity(0.8),
              blurRadius: 40,
              spreadRadius: 10),
          const BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 2)
        ];
        icon = Icons.star;
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: coreColor,
        boxShadow: shadows,
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white, size: size * 0.5)
          : null,
    );
  }
}

import 'package:flutter/material.dart';

// Her bir temanın kimlik kartı
class GameTheme {
  final String id;
  final String name;
  final int price; // 0 ise bedava, fiyatlı ise kristalle alınır
  final List<Color> blockColors; // Blokların düşerken alacağı renkler
  final Color bgCenterColor; // Arka planın ortası
  final Color bgEdgeColor; // Arka planın kenarları
  final Color starColor; // Yıldızların rengi

  const GameTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.blockColors,
    required this.bgCenterColor,
    required this.bgEdgeColor,
    required this.starColor,
  });
}

class ThemeManager {
  // ==========================================
  // OYUNDAKİ BÜTÜN TEMALARIN LİSTESİ
  // ==========================================
  static const List<GameTheme> availableThemes = [
    // 1. Klasik Tema (Şu anki)
    GameTheme(
      id: 'classic_neon',
      name: 'KLASİK NEON',
      price: 0,
      blockColors: [
        Colors.cyanAccent,
        Colors.purpleAccent,
        Colors.orangeAccent,
        Colors.greenAccent,
        Colors.redAccent
      ],
      bgCenterColor: Color(0xFF0A0E17),
      bgEdgeColor: Colors.black,
      starColor: Colors.white,
    ),

    // 2. Cyberpunk Teması
    GameTheme(
      id: 'cyberpunk',
      name: 'CYBERPUNK',
      price: 150, // 150 Kristal
      blockColors: [
        Color(0xFFFCEE09),
        Color(0xFFFF003C),
        Color(0xFF00FFF5),
        Color(0xFFB026FF)
      ], // Cyberpunk Sarısı, Kırmızı, Neon Mavi, Mor
      bgCenterColor: Color(0xFF1B033A), // Koyu mor arka plan
      bgEdgeColor: Color(0xFF090014),
      starColor: Color(0xFF00FFF5),
    ),

    // 3. Matrix (Hacker) Teması
    GameTheme(
      id: 'matrix',
      name: 'MATRIX',
      price: 300,
      blockColors: [
        Color(0xFF00FF41),
        Color(0xFF008F11),
        Color(0xFF003B00),
        Colors.white
      ], // Tamamen yeşil tonları
      bgCenterColor: Color(0xFF001100),
      bgEdgeColor: Colors.black,
      starColor: Color(0xFF00FF41),
    ),

    // 4. Saf Altın (Prestij) Teması
    GameTheme(
      id: 'pure_gold',
      name: 'SAF ALTIN',
      price: 1000, // Çok pahalı prestij teması
      blockColors: [
        Color(0xFFFFD700),
        Color(0xFFFDB931),
        Color(0xFFFFF2CD),
        Color(0xFFB8860B)
      ], // Altın tonları
      bgCenterColor: Color(0xFF2A2000), // Koyu altın/siyah
      bgEdgeColor: Colors.black,
      starColor: Color(0xFFFFD700),
    ),
  ];

  // Aktif temayı getiren zeki fonksiyon
  static GameTheme getTheme(String themeId) {
    return availableThemes.firstWhere((theme) => theme.id == themeId,
        orElse: () => availableThemes.first); // Bulamazsa klasiği ver
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class Tasarim {
  static const Color arkaPlan = Color(0xFF10102A); // Koyu lacivert
  static const Color bosSlot = Color(0xFF1A1A35); // Grid kareleri
  static const Color playButton = Color(0xFF00E676);

  // Blok Renkleri (Canlı Neon Renkler)
  static const List<Color> renkler = [
    Color(0xFFFF0055), // Neon Kırmızı
    Color(0xFF00F0FF), // Neon Mavi
    Color(0xFFCCFF00), // Neon Sarı
    Color(0xFFBD00FF), // Neon Mor
    Color(0xFFFF9900), // Neon Turuncu
  ];

  static Color rastgeleRenk() {
    return renkler[Random().nextInt(renkler.length)];
  }
}

class GameConfig {
  // Grid Boyutları
  static const int rows = 20;
  static const int cols = 10;

  // Hız Ayarları (Milisaniye)
  static const int initialSpeedMs = 1000; // Başlangıç: 1 saniye
  static const int speedStepMs = 200; // Her zorlukta hızlanma: 0.2 saniye
  static const int minSpeedCapMs = 150; // İnsan Refleks Sınırı (Max Hız)

  // Renkler veya diğer sabitler buraya eklenebilir
  static const int emptyCell = 0;
}

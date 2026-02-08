import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// Enum'ları oyunun geri kalanıyla (DataManager ve TimelessGame) eşitledik
enum RewardType { time, coin, points }

class OdulParcacigi extends PositionComponent {
  final RewardType type;
  final double speed = 150; // Düşüş hızı
  late Paint _paint;

  OdulParcacigi({required this.type, required Vector2 position})
      : super(
            position: position, size: Vector2(30, 30), anchor: Anchor.center) {
    // Türüne göre renk belirle
    Color color;
    switch (type) {
      case RewardType.time:
        color = Colors.cyanAccent; // Zamanı yavaşlatır
        break;
      case RewardType.coin:
        color = Colors.amber; // Para verir (Market için)
        break;
      case RewardType.points:
        color = Colors.purpleAccent; // Puan verir
        break;
    }

    _paint = Paint()..color = color;
    priority = 15; // Blokların önünde dursun
  }

  @override
  void render(Canvas canvas) {
    // Basit bir ikon çizimi (Daire)
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);

    // İçine parıltı efekti (beyaz nokta)
    canvas.drawCircle(Offset(size.x / 3, size.y / 3), 4,
        Paint()..color = Colors.white.withOpacity(0.8));

    // İsteğe bağlı: Türüne göre harf veya sembol çizilebilir
    // Ancak şimdilik renk ayrımı yeterli.
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Aşağı düşür
    y += speed * dt;

    // Ekranın altına geldiyse sil (Bellek temizliği)
    if (y > 2000) {
      removeFromParent();
    }

    // Hafif sağa sola sallanma efekti (Süzülüyormuş gibi)
    x += sin(y / 50) * 1;
  }
}

import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Tıklama algılamak için şart
import 'package:flutter/material.dart';
import '../timeless_game.dart';
import '../../data/data_manager.dart';

// DEĞİŞİKLİK BURADA: HudButtonComponent yerine PositionComponent + TapCallbacks yaptık
class SlowButton extends PositionComponent with TapCallbacks {
  final TimelessGame game;

  SlowButton({required this.game, required Vector2 position})
      : super(
          position: position,
          size: Vector2(60, 60),
          anchor: Anchor.center,
          priority: 20, // UI'ın en üstünde olsun
        );

  @override
  void render(Canvas canvas) {
    // Çizim kodları aynen kalıyor, burası harika çalışıyor
    bool canAfford = DataManager.totalCoins >= 50;

    // Dış Çember
    final paint = Paint()
      ..color = canAfford
          ? Colors.cyanAccent.withOpacity(0.8)
          : Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 25, paint);

    // İkon (Kum Saati)
    final iconPaint = Paint()
      ..color = canAfford ? Colors.cyanAccent : Colors.grey;

    Path path = Path();
    path.moveTo(size.x / 2 - 10, size.y / 2 - 15);
    path.lineTo(size.x / 2 + 10, size.y / 2 - 15);
    path.lineTo(size.x / 2, size.y / 2);
    path.lineTo(size.x / 2 + 10, size.y / 2 + 15);
    path.lineTo(size.x / 2 - 10, size.y / 2 + 15);
    path.lineTo(size.x / 2, size.y / 2);
    path.close();

    canvas.drawPath(path, iconPaint);

    // Fiyat Yazısı
    final textSpan = TextSpan(
      text: "50",
      style: TextStyle(
        color: canAfford ? Colors.white : Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(size.x / 2 - textPainter.width / 2, size.y / 2 + 18));
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Tıklama olayı artık TapCallbacks sayesinde burada yakalanıyor
    game.manuelZamanYavaslat();
  }
}

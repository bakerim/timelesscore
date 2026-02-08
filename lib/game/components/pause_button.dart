import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PauseButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTapAction;

  PauseButton({required Vector2 position, required this.onTapAction})
      : super(
            position: position,
            size: Vector2(40, 40),
            anchor: Anchor.center,
            priority: 20);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Çerçeve
    canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        paint);

    // İki dikey çizgi (Pause ikonu)
    canvas.drawLine(Offset(size.x * 0.35, size.y * 0.25),
        Offset(size.x * 0.35, size.y * 0.75), paint);
    canvas.drawLine(Offset(size.x * 0.65, size.y * 0.25),
        Offset(size.x * 0.65, size.y * 0.75), paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapAction();
  }
}

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class LevelUpEffect extends PositionComponent with HasGameRef {
  final int level;

  LevelUpEffect({required this.level, required Vector2 position})
      : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Yazının Kendisi (Büyük ve Gölgeli)
    final textComp = TextComponent(
      text: 'LEVEL $level',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w900,
          color: Colors.amber, // Altın rengi
          letterSpacing: 4,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
            Shadow(
                color: Colors.orangeAccent,
                offset: Offset(0, 0),
                blurRadius: 20),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    add(textComp);

    // 2. GİRİŞ ANİMASYONU (Elastic Pop)
    // Küçücükten başlayıp (0.0), normal boyuta (1.0) yaylanarak gelir.
    scale = Vector2.all(0.0);

    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.8,
          curve: Curves.elasticOut, // O "boing" efekti
        ),
      ),
    );

    // 3. ÇIKIŞ ANİMASYONU (Fade Out & Move Up)
    // 1.5 saniye bekle, sonra yukarı doğru süzülerek kaybol.
    add(
      SequenceEffect([
        // DÜZELTİLEN KISIM BURASI: Vector2.zero -> Vector2.zero()
        // Bu "0 birim hareket et" demektir, yani olduğu yerde bekler.
        MoveEffect.by(Vector2.zero(), EffectController(duration: 1.5)),

        // Yok ol
        RemoveEffect(),
      ]),
    );

    // Opaklık efekti (Sonlara doğru silikleşsin)
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5, startDelay: 1.5),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}

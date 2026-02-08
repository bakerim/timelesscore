import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StarBackground extends Component {
  final int starCount = 100;
  late List<_Star> stars;
  final Random _rng = Random();
  late Vector2 screenSize;

  StarBackground(this.screenSize) {
    stars = List.generate(starCount, (index) => _generateStar());
  }

  _Star _generateStar() {
    return _Star(
      position: Vector2(
        _rng.nextDouble() * screenSize.x,
        _rng.nextDouble() * screenSize.y,
      ),
      speed: _rng.nextDouble() * 50 + 10,
      size: _rng.nextDouble() * 2 + 1,
      opacity: _rng.nextDouble() * 0.5 + 0.1,
    );
  }

  @override
  void update(double dt) {
    for (var star in stars) {
      star.position.y += star.speed * dt;
      if (star.position.y > screenSize.y) {
        star.position.y = -10;
        star.position.x = _rng.nextDouble() * screenSize.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Sadece yıldızları çiziyoruz, arka plan rengi TimelessGame içinde veriliyor.
    for (var star in stars) {
      final paint = Paint()..color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(star.position.toOffset(), star.size, paint);
    }
  }
}

class _Star {
  Vector2 position;
  double speed;
  double size;
  double opacity;

  _Star(
      {required this.position,
      required this.speed,
      required this.size,
      required this.opacity});
}

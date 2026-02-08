import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Kare extends PositionComponent {
  String tur; // "oyuncu", "duvar", "hud"
  Color baseColor; // Ana rengimiz bu
  Paint glowPaint; // Dış parlama için

  @override
  bool isRemoving = false;

  // --- KRİTİK DÜZELTME BURADA ---
  // TimelessGame dosyası "blok.paint.color" diye sorduğunda hata vermemesi için
  // bu "sanal" değişkeni ekledik. Rengi sorana baseColor'ı veriyoruz.
  Paint get paint => Paint()..color = baseColor;
  // ------------------------------

  Kare(double boy, {this.tur = "oyuncu", required Color renk})
      : baseColor = renk,
        glowPaint = Paint()
          ..color = renk.withOpacity(0.6) // Opaklığı biraz artırdık
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal,
              2), // <-- 10'DU, 2 YAPTIK (Artık kare görünecek)
        super(size: Vector2(boy, boy), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    // 1. Kenar Boşluğu
    double padding = 3.0;

    // 2. Çizim Alanı
    final rect = Rect.fromLTWH(
        padding, padding, size.x - (padding * 2), size.y - (padding * 2));

    // 3. Yuvarlatılmış Köşeler
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8.0));

    // --- KATMAN 1: DIŞ PARLAMA (NEON) ---
    if (tur != "hud") {
      canvas.drawRRect(rrect.inflate(2), glowPaint);
    }

    // --- KATMAN 2: BUZLU CAM GÖVDESİ (GRADIENT) ---
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.9), // Sol üst opak
          baseColor.withOpacity(0.4), // Sağ alt şeffaf
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, glassPaint);

    // --- KATMAN 3: KRİSTAL ÇERÇEVE (HIGHLIGHT) ---
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect.deflate(1), borderPaint);
  }
}

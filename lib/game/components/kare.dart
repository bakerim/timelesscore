import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Kare extends PositionComponent {
  // Blok Türü: "oyuncu", "duvar", "dusman"
  String tur;

  // Görünüm için boya kalemleri
  late Paint paint;
  late Paint glowPaint;

  // Silinme efekti kontrolü (Satır silinirken çakışmayı önler)
  @override
  bool isRemoving = false;

  Kare(double boy, {this.tur = "oyuncu", Color? bazRenk})
      : super(size: Vector2(boy, boy), anchor: Anchor.topLeft) {
    // --- KRİTİK AYAR: GÖRÜNÜRLÜK ÖNCELİĞİ ---
    // Arka plan (0) ve HUD (5) katmanlarının önünde olması için 10 yapıyoruz.
    priority = 10;

    // Eğer renk verilmezse varsayılan beyaz olsun
    Color color = bazRenk ?? Colors.white;

    // Ana Dolgu Rengi
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Parlama Efekti (Neon havası için)
    glowPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  }

  @override
  void render(Canvas canvas) {
    // Hafif içeriden çizim yaparak bloklar arası boşluk (padding) oluşturuyoruz
    double padding = 2.0;

    Rect rect = Rect.fromLTWH(
        padding, padding, size.x - (padding * 2), size.y - (padding * 2));

    // Köşeleri yuvarlatılmış kare
    RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8.0));

    // Eğer HUD elemanı değilse arkasına parlama (glow) çiz
    if (tur != "hud") {
      canvas.drawRRect(rrect.inflate(2), glowPaint);
    }

    // Asıl bloğu çiz
    canvas.drawRRect(rrect, paint);
  }
}
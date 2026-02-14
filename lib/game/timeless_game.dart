import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart' as core;
import '../data/data_manager.dart';
import '../data/progress_manager.dart';
import '../data/purchase_manager.dart';
import 'ad_manager.dart';

import 'components/kare.dart';
import 'components/pause_button.dart';
import 'components/star_background.dart';

class TimelessGame extends FlameGame
    with PanDetector, HasCollisionDetection, TapCallbacks {
  late final AdManager adManager;

  // --- UI KOMPONENTLERİ ---
  late TextComponent skorYazisi, yuksekSkorYazisi, elmasYazisi, comboYazisi;
  Kare? oyuncu;

  // --- OYUN AYARLARI ---
  final double gridSize = 50.0;
  final double hudHeight = 160.0;
  final double safeBottomArea = 100.0;
  final Random _rng = Random();

  double sayac = 0;
  double normalOyunHizi = core.GameConfig.initialSpeedMs / 1000.0;
  double oyunHizi = core.GameConfig.initialSpeedMs / 1000.0;

  // --- GÖRSEL EFEKTLER ---
  bool isTimeSlowed = false;
  double _slowMoOpacity = 0.0;
  final Paint _timeWarpPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);

  // --- DURUM & SKOR ---
  int skor = 0, comboSayaci = 0, buOyunKazanilanKristal = 0, currentLevel = 1;
  bool isGameOver = false,
      isPaused = true,
      sesAcik = true,
      muzikAcik = true,
      isReviveScreenOpen = false,
      reviveUsed = false;

  double suruklemeBirikimiX = 0, suruklemeBirikimiY = 0;
  bool dropLock = false;

  final Paint slotPaint = Paint()
    ..color = const Color.fromARGB(12, 255, 255, 255)
    ..style = PaintingStyle.fill;

  @override
  Color backgroundColor() => const Color(0xFF020617);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Yöneticileri Başlat
    await DataManager.init();
    await ProgressManager().init();
    PurchaseManager.init();
    adManager = AdManager();
    await adManager.init();

    sesAcik = DataManager.isSoundOn;
    muzikAcik = DataManager.isMusicOn;

    _buildUI();
    add(StarBackground(size)..priority = 0);
    pauseEngine();
  }

  void _buildUI() {
    add(RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, hudHeight),
        paint: Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.6),
        priority: 5));

    skorYazisi = TextComponent(
        text: '0',
        textRenderer: TextPaint(
            style: const TextStyle(
                color: Colors.white,
                fontSize: 55,
                fontWeight: FontWeight.w900)),
        position: Vector2(size.x / 2, 40),
        anchor: Anchor.topCenter,
        priority: 10);
    yuksekSkorYazisi = TextComponent(
        text: 'BEST: ${DataManager.highScore}',
        textRenderer: TextPaint(
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        position: Vector2(size.x / 2, 105),
        anchor: Anchor.topCenter,
        priority: 10);
    elmasYazisi = TextComponent(
        text: '💎 ${DataManager.totalCoins}',
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 1, color: Colors.transparent)),
        position: Vector2(-100, -100));
    comboYazisi = TextComponent(
        text: '',
        textRenderer: TextPaint(
            style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        priority: 20);

    // PAUSE BUTONU (Sağ Üst Köşeye Alındı - Windows/Klasik UX)
    add(PauseButton(
        position: Vector2(size.x - 50, 50), onTapAction: togglePause));

    add(skorYazisi);
    add(yuksekSkorYazisi);
    add(elmasYazisi);
    add(comboYazisi);
    overlays.add('GameHUD');
  }

  @override
  void render(Canvas canvas) {
    double sy = hudHeight + 20, ey = size.y - safeBottomArea;
    int r = ((ey - sy) / gridSize).floor(), col = (size.x / gridSize).floor();
    double off = (size.x - col * gridSize) / 2;

    for (int i = 0; i < col; i++) {
      for (int j = 0; j < r; j++) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(off + i * gridSize + 5, sy + j * gridSize + 5,
                    gridSize - 10, gridSize - 10),
                const Radius.circular(10)),
            slotPaint);
      }
    }

    if (isTimeSlowed) {
      _slowMoOpacity =
          0.2 + (sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.15);
      _timeWarpPaint.color =
          Colors.cyanAccent.withValues(alpha: _slowMoOpacity.clamp(0, 1));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _timeWarpPaint);
    }
    super.render(canvas);
  }

  // --- OYUN MATEMATİĞİ VE PUAN SİSTEMİ ---

  void hizliIndir(Kare k) {
    int dusulenBosluk = 0;
    while (!carpismaVarMi(k.position.x, k.position.y + gridSize)) {
      k.position.y += gridSize;
      dusulenBosluk++;
    }

    // ADALETLİ PUAN: Kaç boşluk hızlı indiyse o kadar puan
    if (dusulenBosluk > 0) {
      puanEkle(dusulenBosluk);
      _showFloatingText("+$dusulenBosluk", Colors.white70, hizli: true);
    }
    blokKatilastir(k, hizliIndiMi: true);
  }

  void blokKatilastir(Kare k, {bool hizliIndiMi = false}) {
    k.tur = "duvar";
    sesCal('sfx/drop.mp3');

    // SABİT İNİŞ PUANI: Hızlı indirmediyse sadece 1 puan tesellisi
    if (!hizliIndiMi) {
      puanEkle(1);
    }

    if (k.position.y <= hudHeight + gridSize) {
      carpismaSonrasiKontrol();
      return;
    }

    // Satır silinmezse COMBO SIFIRLANIR! (Klasik Mantık)
    bool temizlendi = satirTemizle();
    if (!temizlendi) {
      comboSayaci = 0;
      comboYazisi.text = ''; // Ekrandaki combo yazısını sil
    }

    oyuncu = null;
    spawnOyuncu();
  }

  bool satirTemizle() {
    List<Kare> duvarlar = children
        .whereType<Kare>()
        .where((k) => k.tur == "duvar" && !k.isRemoving)
        .toList();
    if (duvarlar.isEmpty) return false;

    Map<int, List<Kare>> satirlar = {};
    for (var k in duvarlar) {
      satirlar.putIfAbsent((k.position.y).round(), () => []).add(k);
    }

    int cols = (size.x / gridSize).floor();
    List<int> doluSatirlar = [];
    satirlar.forEach((y, bloklar) {
      if (bloklar.length >= cols) doluSatirlar.add(y);
    });

    if (doluSatirlar.isEmpty) return false;

    // --- KLASİK COMBO MATEMATİĞİ (100 -> 200 -> 300) ---
    int kazanilanPuan = 0;
    for (int i = 0; i < doluSatirlar.length; i++) {
      comboSayaci++;
      kazanilanPuan += (comboSayaci * 100);
    }
    puanEkle(kazanilanPuan);

    if (comboSayaci > 1) {
      comboYazisi.text = 'COMBO x$comboSayaci';
      comboYazisi.add(ScaleEffect.by(Vector2.all(1.2),
          EffectController(duration: 0.1, reverseDuration: 0.1)));
      _showFloatingText("+$kazanilanPuan", Colors.amberAccent);
    }

    sesCal('sfx/clear.mp3');
    if (!kIsWeb) HapticFeedback.heavyImpact();

    // Güvenli Silme İşlemi
    for (int y in doluSatirlar) {
      for (var k in satirlar[y]!) {
        k.isRemoving = true;
        k.add(ScaleEffect.to(Vector2.all(0.0),
            EffectController(duration: 0.35, curve: Curves.easeInBack),
            onComplete: () => k.removeFromParent()));
        k.add(OpacityEffect.fadeOut(EffectController(duration: 0.4)));
      }
    }

    doluSatirlar.sort();
    add(TimerComponent(
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
          for (var k in duvarlar) {
            if (k.isRemoving) continue;
            int kayma = doluSatirlar.where((y) => k.position.y < y).length;
            if (kayma > 0) {
              k.position.y += kayma * gridSize;
              k.add(MoveEffect.by(Vector2.zero(),
                  EffectController(duration: 0.2, curve: Curves.bounceOut)));
            }
          }
        }));
    return true;
  }

  void puanEkle(int miktar) {
    skor += miktar;
    skorYazisi.text = '$skor';

    // Adım 1'deki "Merkezi Sinir Sistemi" ile anında tüm UI'ları doldurur
    ProgressManager().addXp(miktar);

    // Otomatik Kristal Kazanımı (5000 Puan'da 1 Tane)
    if (skor % 5000 < miktar) {
      DataManager.totalCoins += 1;
      buOyunKazanilanKristal += 1;
      DataManager.saveData();
      elmasYazisi.text = '💎 ${DataManager.totalCoins}';
      _showFloatingText("+1 KRİSTAL", Colors.cyanAccent);
    }

    // Oyun hızı güncellemesi (Artık UI Level yazısı GameHUD üzerinden ilerleyecek)
    int yeniLevel = (skor / 1000).floor() + 1;
    if (yeniLevel > currentLevel) {
      currentLevel = yeniLevel;
      normalOyunHizi = max(0.08, normalOyunHizi * 0.93);
      if (!isTimeSlowed) oyunHizi = normalOyunHizi;
      sesCal('sfx/level_up.mp3');
    }
  }

  // --- GÜVENLİ NAVİGASYON VE BOŞ EKRAN DÜŞMANI ---

  void anaMenuyeDon() {
    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    overlays.clear();
    skor = 0;
    skorYazisi.text = '0';
    currentLevel = 1;
    comboSayaci = 0;
    comboYazisi.text = '';
    reviveUsed = false;
    isGameOver = false;
    buOyunKazanilanKristal = 0;
    isPaused = true;
    pauseEngine();
    FlameAudio.bgm.stop();
    // Oyun kapatıldığında KESİNLİKLE Ana Menüyü aç
    overlays.add('AnaMenu');
  }

  bool onBackPressed() {
    // 1. Ana menüdeysek çıkışa izin ver
    if (overlays.isActive('AnaMenu')) return true;

    // 2. Alt menülerdeysek (Shop, Roadmap vs) Ana Menüye at
    if (overlays.isActive('ShopMenu') ||
        overlays.isActive('DailySpin') ||
        overlays.isActive('SettingsMenu') ||
        overlays.isActive('Roadmap')) {
      anaMenuyeDon();
      return false;
    }

    // 3. Oyun içindeysek Pause yap, zaten pause ise ana menüye dön
    if (!isPaused && !isGameOver)
      togglePause();
    else if (isPaused && overlays.isActive('PauseMenu')) anaMenuyeDon();

    return false;
  }

  void oyunuBaslat() {
    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    overlays.clear();
    skor = 0;
    skorYazisi.text = '0';
    comboSayaci = 0;
    comboYazisi.text = '';
    buOyunKazanilanKristal = 0;
    reviveUsed = false;
    isGameOver = false;
    normalOyunHizi = core.GameConfig.initialSpeedMs / 1000.0;
    oyunHizi = normalOyunHizi;

    overlays.add('GameHUD');
    isPaused = false;
    resumeEngine();
    if (muzikAcik) muzikYonetimi(true);
    Future.delayed(
        const Duration(milliseconds: 200), () => spawnOyuncu(zorla: true));
  }

  // --- DİĞER FONKSİYONLAR ---

  void spawnOyuncu({bool zorla = false}) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    oyuncu = Kare(gridSize, bazRenk: _getLevelBasedColor(), tur: "oyuncu");
    oyuncu!.position = Vector2(
        ((size.x - ((size.x / gridSize).floor() * gridSize)) / 2) +
            ((size.x / gridSize).floor() / 2).floor() * gridSize,
        hudHeight + 20);
    add(oyuncu!);
  }

  void yercekimiAdimi() {
    if (oyuncu == null) return;
    if (carpismaVarMi(oyuncu!.position.x, oyuncu!.position.y + gridSize)) {
      blokKatilastir(oyuncu!);
    } else {
      oyuncu!.position.y += gridSize;
    }
  }

  bool carpismaVarMi(double x, double y) {
    if (y >= size.y - safeBottomArea - gridSize) return true;
    return children.any((c) =>
        c is Kare &&
        c.tur == "duvar" &&
        !c.isRemoving &&
        (c.position.x - x).abs() < 5 &&
        (c.position.y - y).abs() < 5);
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      overlays.add('PauseMenu');
      pauseEngine();
      FlameAudio.bgm.pause();
    } else {
      overlays.remove('PauseMenu');
      resumeEngine();
      if (muzikAcik) muzikYonetimi(true);
    }
  }

  void manuelZamanYavaslat() {
    if (isGameOver || isPaused || isTimeSlowed || isReviveScreenOpen) return;
    const int maliyet = 5;
    if (DataManager.totalCoins >= maliyet) {
      DataManager.totalCoins -= maliyet;
      DataManager.saveData();
      elmasYazisi.text = '💎 ${DataManager.totalCoins}';
      isTimeSlowed = true;
      oyunHizi = normalOyunHizi * 3.5;
      sesCal('sfx/slow_motion.mp3');
      add(TimerComponent(
          period: 5.0,
          removeOnFinish: true,
          onTick: () {
            isTimeSlowed = false;
            oyunHizi = normalOyunHizi;
          }));
    }
  }

  void sesCal(String dosya) {
    if (DataManager.isSoundOn) FlameAudio.play(dosya);
  }

  void muzikYonetimi(bool ac) {
    muzikAcik = ac;
    DataManager.setMusic(ac);
    if (ac) {
      if (!FlameAudio.bgm.isPlaying) {
        try {
          FlameAudio.bgm.play('sfx/move.mp3', volume: 0.2);
        } catch (_) {}
      }
    } else {
      FlameAudio.bgm.stop();
    }
  }

  void reklamIzleVeCanlan() {
    adManager.showRewardedAd(onReward: (amount) => devamEtIslemi());
  }

  void devamEtIslemi() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    reviveUsed = true;
    altSatirlariTemizle(6);
    isGameOver = false;
    isPaused = false;
    resumeEngine();
    spawnOyuncu(zorla: true);
    overlays.add('GameHUD');
    elmasYazisi.text = '💎 ${DataManager.totalCoins}';
  }

  void vazgecVeBitir() {
    isReviveScreenOpen = false;
    oyunuBitir();
  }

  Future<void> oyunuBitir() async {
    isGameOver = true;
    isPaused = true;
    await DataManager.saveScore(skor);
    overlays.remove('GameHUD');
    overlays.add('GameOver');
    pauseEngine();
    FlameAudio.bgm.stop();
    adManager.showInterstitialAd();
  }

  void carpismaSonrasiKontrol() {
    if (!reviveUsed && skor > 100) {
      isPaused = true;
      pauseEngine();
      isReviveScreenOpen = true;
      overlays.remove('GameHUD');
      overlays.add('ReviveMenu');
    } else {
      oyunuBitir();
    }
  }

  void altSatirlariTemizle(int n) {
    List<Kare> duvarlar =
        children.whereType<Kare>().where((k) => k.tur == "duvar").toList();
    duvarlar.sort((a, b) => b.position.y.compareTo(a.position.y));
    for (int i = 0; i < min(duvarlar.length, n * 5); i++) {
      duvarlar[i].removeFromParent();
    }
  }

  Color _getLevelBasedColor() => [
        Colors.cyanAccent,
        Colors.purpleAccent,
        Colors.orangeAccent,
        Colors.greenAccent,
        Colors.redAccent
      ][_rng.nextInt(5)];

  void _showFloatingText(String text, Color color, {bool hizli = false}) {
    final textComp = TextComponent(
        text: text,
        textRenderer: TextPaint(
            style: TextStyle(
                color: color,
                fontSize: hizli ? 18 : 28,
                fontWeight: FontWeight.w900,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black)])),
        position: size / 2,
        anchor: Anchor.center);
    add(textComp);
    textComp.add(MoveEffect.by(Vector2(0, hizli ? -50 : -150),
        EffectController(duration: hizli ? 0.6 : 1.2),
        onComplete: () => textComp.removeFromParent()));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    sayac += dt;
    if (sayac > oyunHizi) {
      sayac = 0;
      yercekimiAdimi();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused || oyuncu == null) return;
    if (info.delta.global.x.abs() > info.delta.global.y.abs()) {
      suruklemeBirikimiX += info.delta.global.x;
      if (suruklemeBirikimiX.abs() >= gridSize) {
        _hareketEt(oyuncu!, suruklemeBirikimiX.sign.toInt());
        suruklemeBirikimiX = 0;
      }
    } else if (info.delta.global.y > 40 && !dropLock) {
      dropLock = true;
      hizliIndir(oyuncu!);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    dropLock = false;
    suruklemeBirikimiX = 0;
  }

  void _hareketEt(Kare k, int dx) {
    double nx = k.position.x + dx * gridSize;
    if (nx >= 0 &&
        nx <= size.x - gridSize &&
        !carpismaVarMi(nx, k.position.y)) {
      k.position.x = nx;
    }
  }

  @override
  void onRemove() {
    FlameAudio.bgm.dispose();
    adManager.disposeAds();
    super.onRemove();
  }
}

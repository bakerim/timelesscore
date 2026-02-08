import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart'; // Efektler için gerekli
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants.dart' as Core;
import '../core/localization.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';
import 'components/kare.dart';
import 'components/pause_button.dart';
import 'components/reward.dart';
import 'components/star_background.dart';
import 'components/slow_button.dart';

enum AdPurpose { revive, doubleScore, none }

class TimelessGame extends FlameGame
    with PanDetector, TapDetector, HasCollisionDetection {
  // --- OYUN BİLEŞENLERİ ---
  late Kare oyuncu;
  late TextComponent skorYazisi;
  late TextComponent elmasYazisi;
  late TextComponent yuksekSkorYazisi;
  late TextComponent comboYazisi;

  // --- AYARLAR ---
  final double gridSize = 50.0;
  final double hudHeight = 160.0;
  final Random _rng = Random();

  // --- DURUM DEĞİŞKENLERİ (STATE) ---
  double sayac = 0;
  double oyunHizi = Core.GameConfig.initialSpeedMs / 1000.0;
  double _orijinalHiz = 0.5;
  bool isTimeSlowed = false;

  int currentLevel = 1;
  int levelScoreThreshold = 500;
  double rewardSpawnTimer = 0;

  int skor = 0;
  int comboSayaci = 0;

  // --- KONTROL BAYRAKLARI ---
  bool isGameOver = false;
  bool isPaused = false;
  bool sesAcik = true;
  bool isReviveScreenOpen = false;
  bool reviveUsed = false;

  // --- ETKİLEŞİM DEĞİŞKENLERİ ---
  double suruklemeBirikimiX = 0;
  double suruklemeBirikimiY = 0;
  bool dropLock = false;

  // --- REKLAM ---
  RewardedAd? _rewardedAd;
  bool reklamHazir = false;
  AdPurpose _currentAdPurpose = AdPurpose.none;
  final String reklamBirimID = 'ca-app-pub-3940256099942544/5224354917';

  final Paint slotPaint = Paint()
    ..color = Core.Tasarim.bosSlot
    ..style = PaintingStyle.fill;

  @override
  Color backgroundColor() => const Color(0xFF0F172A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await DataManager.init();
    await ProgressManager().init();

    if (!kIsWeb) reklamYukle();

    // Arka Plan
    add(StarBackground(size)..priority = 0);

    // Üst Panel (HUD)
    add(RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, hudHeight),
        paint: Paint()..color = Core.Tasarim.arkaPlan.withOpacity(0.8),
        priority: 5));

    add(PauseButton(
        position: Vector2(size.x - 40, 50), onTapAction: togglePause));

    add(SlowButton(game: this, position: Vector2(40, 50)));

    skorYazisi = TextComponent(
      text: '0',
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900)),
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.topCenter,
      priority: 10,
    );
    add(skorYazisi);

    elmasYazisi = TextComponent(
      text: '💎 ${DataManager.totalCoins}',
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      position: Vector2(size.x / 2, 110),
      anchor: Anchor.topCenter,
      priority: 10,
    );
    add(elmasYazisi);

    yuksekSkorYazisi = TextComponent(
      text: '${Dil.get("rekor")}: ${DataManager.highScore}',
      textRenderer: TextPaint(
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
      position: Vector2(size.x / 2, 135),
      anchor: Anchor.topCenter,
      priority: 10,
    );
    add(yuksekSkorYazisi);

    comboYazisi = TextComponent(
      text: '',
      textRenderer: TextPaint(
          style: TextStyle(
              color: Core.Tasarim.renkler[3],
              fontSize: 30,
              fontWeight: FontWeight.bold)),
      position: Vector2(size.x / 2, hudHeight + 50),
      anchor: Anchor.center,
      priority: 20,
    );
    add(comboYazisi);

    // --- BAŞLANGIÇTA DUR ---
    isPaused = true;
    pauseEngine();
  }

  // ==========================================================
  // --- OYUN DÖNGÜSÜ YÖNETİMİ (Game Loop) ---
  // ==========================================================

  void anaMenuyeDon() {
    if (isPaused) resumeEngine();

    overlays.removeAll(
        ['GameOver', 'PauseMenu', 'ReviveMenu', 'Shop', 'Roadmap', 'Ayarlar']);
    overlays.add('AnaMenu');

    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    children.whereType<OdulParcacigi>().forEach((o) => o.removeFromParent());
    children
        .whereType<ParticleSystemComponent>()
        .forEach((p) => p.removeFromParent());
    // Efekt katmanlarını da temizle
    children
        .whereType<RectangleComponent>()
        .where((r) => r.priority == 1000)
        .forEach((r) => r.removeFromParent());

    isPaused = true;
    pauseEngine();
  }

  void oyunuBaslat() {
    if (isPaused) {
      resumeEngine();
      isPaused = false;
    }

    overlays.removeAll([
      'AnaMenu',
      'Shop',
      'GameOver',
      'PauseMenu',
      'ReviveMenu',
      'Roadmap',
      'Ayarlar'
    ]);

    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    children.whereType<OdulParcacigi>().forEach((o) => o.removeFromParent());
    children
        .whereType<ParticleSystemComponent>()
        .forEach((p) => p.removeFromParent());
    children
        .whereType<RectangleComponent>()
        .where((r) => r.priority == 1000)
        .forEach((r) => r.removeFromParent());

    skor = 0;
    skorYazisi.text = '0';
    comboSayaci = 0;
    comboYazisi.text = '';

    currentLevel = 1;
    oyunHizi = Core.GameConfig.initialSpeedMs / 1000.0;

    isGameOver = false;
    isPaused = false;
    isReviveScreenOpen = false;
    reviveUsed = false;
    isTimeSlowed = false;

    Future.delayed(const Duration(milliseconds: 100), () {
      spawnOyuncu(zorla: true);
    });
  }

  Future<void> oyunuBitir() async {
    if (isGameOver) return;

    isGameOver = true;
    isPaused = true;
    sesCal('sfx/gameover.mp3');

    await DataManager.saveScore(skor);
    await ProgressManager().addXp(skor);

    yuksekSkorYazisi.text = '${Dil.get("rekor")}: ${DataManager.highScore}';
    overlays.add('GameOver');
    pauseEngine();
  }

  void devamEtIslemi() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    reviveUsed = true;

    altSatirlariTemizle(5);

    isGameOver = false;
    isPaused = false;
    resumeEngine();
    spawnOyuncu(zorla: true);
    _showFloatingText("İKİNCİ ŞANS!", Colors.greenAccent);
  }

  void vazgecVeBitir() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    oyunuBitir();
  }

  // --- REKLAM YÖNETİMİ ---
  void reklamYukle() {
    if (kIsWeb) return;
    RewardedAd.load(
      adUnitId: reklamBirimID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          reklamHazir = true;
          _rewardedAd!.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            reklamHazir = false;
            reklamYukle();
          }, onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            reklamHazir = false;
            reklamYukle();
          });
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          reklamHazir = false;
          Future.delayed(const Duration(seconds: 10), reklamYukle);
        },
      ),
    );
  }

  void reklamGoster(AdPurpose amac) {
    if (kIsWeb) {
      _reklamBasarili(amac);
      return;
    }

    if (_rewardedAd != null && reklamHazir) {
      _currentAdPurpose = amac;
      _rewardedAd!.show(onUserEarnedReward: (adWithoutView, reward) {
        _reklamBasarili(_currentAdPurpose);
      });
    } else {
      _showFloatingText("Reklam Yükleniyor...", Colors.red);
      reklamYukle();
    }
  }

  void _reklamBasarili(AdPurpose amac) {
    if (amac == AdPurpose.revive) {
      devamEtIslemi();
    } else if (amac == AdPurpose.doubleScore) puanKatla();
    _currentAdPurpose = AdPurpose.none;
  }

  // --- OYUN MANTIĞI ---

  void spawnOyuncu({bool zorla = false}) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;

    double gridStartY = hudHeight + 20;
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;
    double baslangicX = gridOffsetX + (cols / 2).floor() * gridSize;
    double baslangicY = gridStartY;

    if (!zorla && carpismaVarMi(baslangicX, baslangicY)) {
      carpismaSonrasiKontrol();
      return;
    }

    Color blockColor = _getLevelBasedColor();
    oyuncu = Kare(gridSize, bazRenk: blockColor, tur: "oyuncu");
    oyuncu.position = Vector2(baslangicX, baslangicY);
    add(oyuncu);

    suruklemeBirikimiX = 0;
    suruklemeBirikimiY = 0;
  }

  void carpismaSonrasiKontrol() {
    if (!reviveUsed && skor > 100) {
      isPaused = true;
      isReviveScreenOpen = true;
      overlays.add('ReviveMenu');
    } else {
      oyunuBitir();
    }
  }

  void puanKatla() {
    skor *= 2;
    skorYazisi.text = '$skor';
    DataManager.saveScore(skor);
    ProgressManager().addXp(skor);
    yuksekSkorYazisi.text = '${Dil.get("rekor")}: ${DataManager.highScore}';
    _showFloatingText("2x PUAN AKTİF!", Colors.purpleAccent);
    sesCal('sfx/bonus.mp3');
    konfetiYagmuru();
  }

  void puanEkle(int miktar) {
    skor += miktar;
    skorYazisi.text = '$skor';
    _showFloatingText("+$miktar", Colors.amber);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused || isReviveScreenOpen) return;

    _checkRewardSpawn(dt);
    _checkRewardCollection();

    bool oyuncuVar = children.whereType<Kare>().any((k) => k.tur == "oyuncu");
    if (!oyuncuVar) return;

    sayac += dt;
    if (sayac > oyunHizi) {
      sayac = 0;
      yercekimiAdimi();
    }
  }

  void yercekimiAdimi() {
    var oyuncular = children.whereType<Kare>().where((k) => k.tur == "oyuncu");
    if (oyuncular.isEmpty) return;
    Kare aktifKare = oyuncular.first;
    if (carpismaVarMi(aktifKare.position.x, aktifKare.position.y + gridSize)) {
      blokKatilastir(aktifKare);
    } else {
      aktifKare.position.y += gridSize;
    }
  }

  bool carpismaVarMi(double x, double y) {
    double gridStartY = hudHeight + 20;
    int rows = ((size.y - gridStartY - 20) / gridSize).floor();
    double gridEndY = gridStartY + rows * gridSize;
    if (y >= gridEndY - 5) return true;

    for (final component in children) {
      if (component is Kare &&
          component.tur == "duvar" &&
          !component.isRemoving) {
        if ((component.position.x - x).abs() < 10 &&
            (component.position.y - y).abs() < 30) {
          return true;
        }
      }
    }
    return false;
  }

  void blokKatilastir(Kare k) {
    sesCal('sfx/drop.mp3');
    titresimYap(agir: true);
    k.tur = "duvar";
    bool satirSilindi = satirTemizle();
    if (!satirSilindi) {
      skor += 1;
      skorYazisi.text = '$skor';
      comboSayaci = 0;
      if (!comboYazisi.text.contains("LEVEL")) comboYazisi.text = '';
    }
    spawnOyuncu();
  }

  bool satirTemizle() {
    double gridStartY = hudHeight + 20;
    int rows = ((size.y - gridStartY - 20) / gridSize).floor();
    int cols = (size.x / gridSize).floor();
    bool temizlendi = false;

    for (int j = rows - 1; j >= 0; j--) {
      double checkY = gridStartY + j * gridSize;
      List<Kare> satirdakiBloklar = children
          .whereType<Kare>()
          .where((k) =>
              k.tur == "duvar" &&
              !k.isRemoving &&
              (k.position.y - checkY).abs() < 5)
          .toList();

      if (satirdakiBloklar.length >= cols) {
        bool hepsiAyniRenk = satirdakiBloklar.every(
            (blok) => blok.paint.color == satirdakiBloklar.first.paint.color);
        sesCal('sfx/clear.mp3');
        ekranSars(10);

        for (var blok in satirdakiBloklar) {
          patlamaEfekti(blok.position, blok.paint.color,
              isBigExplosion: hepsiAyniRenk);
          blok.removeFromParent();
        }
        temizlendi = true;
        comboSayaci++;
        int satirPuani = 100 * comboSayaci;
        if (hepsiAyniRenk) {
          satirPuani *= 3;
          sesCal('sfx/bonus.mp3');
          comboYazisi.text = "MÜKEMMEL!";
        } else if (comboSayaci > 1) {
          comboYazisi.text = '${comboSayaci}x COMBO';
        }
        puanEkle(satirPuani);

        children.whereType<Kare>().toList().forEach((component) {
          if (component.tur == "duvar" &&
              !component.isRemoving &&
              component.position.y < checkY) {
            component.position.y += gridSize;
          }
        });
        return true;
      }
    }
    return temizlendi;
  }

  void sesCal(String dosyaAdi) {
    if (sesAcik) {
      try {
        FlameAudio.play(dosyaAdi);
      } catch (e) {
        debugPrint("Ses hatası: $e");
      }
    }
  }

  void _showFloatingText(String text, Color color) {
    final component = TextComponent(
      text: text,
      textRenderer: TextPaint(
          style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black)])),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      priority: 100,
    );
    add(component);
    component
        .add(MoveEffect.by(Vector2(0, -50), EffectController(duration: 1.0)));
    component.add(RemoveEffect(delay: 1.5));
  }

  void konfetiYagmuru() {
    add(ParticleSystemComponent(
        priority: 110,
        particle: Particle.generate(
            count: 100,
            lifespan: 3.0,
            generator: (i) => AcceleratedParticle(
                acceleration: Vector2(0, 200),
                speed: Vector2(_rng.nextDouble() * 600 - 300,
                    _rng.nextDouble() * -400 - 100),
                position: Vector2(size.x / 2, size.y / 2),
                child: CircleParticle(
                    radius: _rng.nextDouble() * 4 + 2,
                    paint: Paint()
                      ..color =
                          Core.Tasarim.rastgeleRenk().withOpacity(0.9))))));
  }

  void patlamaEfekti(Vector2 position, Color color,
      {bool isBigExplosion = false}) {
    int count = isBigExplosion ? 40 : 20;
    double speedMult = isBigExplosion ? 2.0 : 1.0;
    add(ParticleSystemComponent(
        particle: Particle.generate(
            count: count,
            lifespan: 0.8,
            generator: (i) => AcceleratedParticle(
                acceleration: Vector2(0, 400),
                speed: Vector2((_rng.nextDouble() * 300 - 150) * speedMult,
                    (_rng.nextDouble() * 300 - 150) * speedMult),
                position: position + Vector2(gridSize / 2, gridSize / 2),
                child: CircleParticle(
                    radius: 4,
                    paint: Paint()..color = color.withOpacity(0.8))))));
  }

  void titresimYap({bool agir = false}) {
    if (kIsWeb) return;
    if (agir) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void ekranSars(double intensity) {
    camera.viewfinder.add(MoveEffect.by(
        Vector2(5, 5),
        EffectController(
            duration: 0.2,
            alternate: true,
            curve: Curves.easeIn,
            repeatCount: 3)));
    titresimYap(agir: true);
  }

  void altSatirlariTemizle(int satirSayisi) {
    sesCal('sfx/clear.mp3');
    double gridStartY = hudHeight + 20;
    double temizlenecekLimitY = gridStartY +
        (((size.y - gridStartY - 20) / gridSize).floor() - satirSayisi) *
            gridSize;

    children.whereType<Kare>().where((k) => k.tur == "duvar").forEach((k) {
      if (k.position.y >= temizlenecekLimitY) {
        patlamaEfekti(k.position, k.paint.color);
        k.removeFromParent();
      }
    });

    double kaydirmaMiktari = satirSayisi * gridSize;
    children.whereType<Kare>().where((k) => k.tur == "duvar").forEach((k) {
      if (k.position.y < temizlenecekLimitY) k.position.y += kaydirmaMiktari;
    });
  }

  void togglePause() {
    if (isGameOver || isReviveScreenOpen) return;
    if (isPaused) {
      overlays.remove('PauseMenu');
      isPaused = false;
      resumeEngine();
    } else {
      overlays.add('PauseMenu');
      isPaused = true;
      pauseEngine();
    }
  }

  Color _getLevelBasedColor() {
    List<Color> palette = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow
    ];
    if (currentLevel > 5) palette.add(Colors.purple);
    if (currentLevel > 10) palette.add(Colors.orange);
    return palette[_rng.nextInt(palette.length)];
  }

  void _checkRewardSpawn(double dt) {
    rewardSpawnTimer += dt;
    if (rewardSpawnTimer > 15.0) {
      rewardSpawnTimer = 0;
      if (_rng.nextDouble() < 0.3) _spawnRandomReward();
    }
  }

  void _spawnRandomReward() {
    double xPos = _rng.nextDouble() * (size.x - 50) + 25;
    double roll = _rng.nextDouble();
    RewardType type;
    if (roll < 0.4) {
      type = RewardType.coin;
    } else if (roll < 0.7)
      type = RewardType.points;
    else
      type = RewardType.time;
    add(OdulParcacigi(type: type, position: Vector2(xPos, -20)));
  }

  void _checkRewardCollection() {
    var oyuncular = children.whereType<Kare>().where((k) => k.tur == "oyuncu");
    if (oyuncular.isEmpty) return;
    Kare oyuncu = oyuncular.first;

    for (var odul in children.whereType<OdulParcacigi>()) {
      if (odul.position.distanceTo(
              oyuncu.position + Vector2(gridSize / 2, gridSize / 2)) <
          40) {
        _collectReward(odul);
        odul.removeFromParent();
      }
    }
  }

  void _collectReward(OdulParcacigi odul) {
    sesCal('sfx/powerup.mp3');
    titresimYap();
    switch (odul.type) {
      case RewardType.coin:
        DataManager.totalCoins += 10;
        DataManager.saveScore(0);
        elmasYazisi.text = '💎 ${DataManager.totalCoins}';
        _showFloatingText("+10 COIN", Colors.amber);
        break;
      case RewardType.points:
        puanEkle(250);
        break;
      case RewardType.time:
        zamanDurdurucu();
        break;
    }
  }

  void manuelZamanYavaslat() {
    if (isTimeSlowed || isGameOver || isPaused) return;
    if (DataManager.totalCoins >= 50) {
      DataManager.totalCoins -= 50;
      elmasYazisi.text = '💎 ${DataManager.totalCoins}';
      DataManager.saveScore(0);
      sesCal('sfx/powerup.mp3');
      zamanDurdurucu();
    } else {
      _showFloatingText("Yetersiz Coin!", Colors.red);
      titresimYap(agir: true);
    }
  }

  // --- HATA DÜZELTME BURADA YAPILDI (Çözüm 1 Uygulandı) ---
  void zamanDurdurucu() {
    if (isTimeSlowed) return;
    isTimeSlowed = true;
    _orijinalHiz = oyunHizi;
    oyunHizi = oyunHizi * 2.5;
    _showFloatingText("ZAMAN BÜKÜLDÜ!", Colors.cyanAccent);

    // Ekrana mavi bir dikdörtgen efekti ekliyoruz (Component olarak)
    final effectRect = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue.withOpacity(0.0),
      priority: 1000,
    );
    add(effectRect);

    effectRect.add(OpacityEffect.to(
      0.3,
      EffectController(duration: 0.5, alternate: true, repeatCount: 10),
      onComplete: () => effectRect.removeFromParent(),
    ));

    Future.delayed(const Duration(seconds: 5), () {
      if (!isGameOver) {
        oyunHizi = _orijinalHiz;
        isTimeSlowed = false;
        _showFloatingText("ZAMAN NORMALE DÖNDÜ", Colors.white);
      }
    });
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    var oyuncuListesi = children
        .whereType<Kare>()
        .where((k) => k.tur == "oyuncu" && !k.isRemoving);
    if (oyuncuListesi.isEmpty) return;
    Kare aktifKare = oyuncuListesi.first;
    double dx = info.delta.global.x;
    double dy = info.delta.global.y;

    if (dx.abs() > dy.abs()) {
      suruklemeBirikimiY = 0;
      suruklemeBirikimiX += dx;
      if (suruklemeBirikimiX >= gridSize) {
        hareketEt(aktifKare, 1, 0);
        suruklemeBirikimiX = 0;
      } else if (suruklemeBirikimiX <= -gridSize) {
        hareketEt(aktifKare, -1, 0);
        suruklemeBirikimiX = 0;
      }
    } else {
      if (dropLock) return;
      if (dy < 0) {
        suruklemeBirikimiY = 0;
        return;
      }
      suruklemeBirikimiY += dy;
      if (suruklemeBirikimiY > 60) {
        dropLock = true;
        hizliIndir(aktifKare);
        suruklemeBirikimiY = 0;
      }
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    dropLock = false;
    suruklemeBirikimiY = 0;
    suruklemeBirikimiX = 0;
  }

  void hizliIndir(Kare k) {
    int safetyCounter = 0;
    while (!carpismaVarMi(k.position.x, k.position.y + gridSize) &&
        safetyCounter < 30) {
      k.position.y += gridSize;
      skor += 2;
      skorYazisi.text = '$skor';
      safetyCounter++;
    }
    blokKatilastir(k);
  }

  void hareketEt(Kare k, int dx, int dy) {
    double yeniX = k.position.x + (dx * gridSize);
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;
    double gridEndX = gridOffsetX + cols * gridSize;
    if (yeniX >= gridOffsetX &&
        yeniX < gridEndX &&
        !carpismaVarMi(yeniX, k.position.y)) {
      sesCal('sfx/move.mp3');
      k.position.x = yeniX;
    }
  }

  @override
  void render(Canvas canvas) {
    double gridStartY = hudHeight + 20;
    int rows = ((size.y - gridStartY - 20) / gridSize).floor();
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        double x = gridOffsetX + i * gridSize;
        double y = gridStartY + j * gridSize;
        RRect rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 4, y + 4, gridSize - 8, gridSize - 8),
            const Radius.circular(8.0));
        slotPaint.color = Colors.white.withOpacity(0.1);
        canvas.drawRRect(rrect, slotPaint);
      }
    }
    super.render(canvas);
  }
}

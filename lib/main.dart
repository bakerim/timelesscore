import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb kontrolü için
import 'package:flame/game.dart'; // GameWidget için
import 'package:flame/flame.dart'; // Flame.device için
import 'package:google_mobile_ads/google_mobile_ads.dart';

// --- KENDİ DOSYALARIMIZ ---
import 'game/timeless_game.dart';
import 'data/data_manager.dart';

// --- OVERLAY (MENÜ) IMPORTLARI ---
import 'overlays/main_menu.dart';
import 'overlays/game_over.dart';
import 'overlays/pause_menu.dart';
import 'overlays/shop_menu.dart';
import 'overlays/roadmap_overlay.dart';
import 'overlays/settings_overlay.dart';
import 'overlays/revive_menu.dart';
import 'overlays/game_hud.dart';
import 'overlays/daily_spin_overlay.dart'; // <--- BU EKSİKTİ, EKLENDİ!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Veri Yönetimi
  await DataManager.init();

  // 2. MOBİL ÖZEL AYARLAR
  if (!kIsWeb) {
    await Flame.device.fullScreen();
    await Flame.device.setPortraitUpOnly();

    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("Reklam servisi başlatılamadı: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeless Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Oyun motorunu burada başlatıyoruz
  final TimelessGame game = TimelessGame();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        game.onBackPressed(); // Geri tuşu kontrolü oyun motorunda
      },
      child: Scaffold(
        body: GameWidget(
          game: game,
          // --- OVERLAY (MENÜ) BAĞLANTILARI ---
          // Buradaki isimler (Key) ile timeless_game.dart içindeki çağrılar (overlays.add) AYNI OLMALI.
          overlayBuilderMap: {
            'AnaMenu': (context, game) => MainMenu(game: game as TimelessGame),
            'GameOver': (context, game) =>
                GameOver(game: game as TimelessGame),
            'PauseMenu': (context, game) =>
                PauseMenu(game: game as TimelessGame),
            'Shop': (context, game) => ShopMenu(game: game as TimelessGame),
            'Roadmap': (context, game) =>
                RoadmapOverlay(game: game as TimelessGame),
            'Settings': (context, game) =>
                SettingsOverlay(game: game as TimelessGame),
            'ReviveMenu': (context, game) =>
                ReviveMenu(game: game as TimelessGame),

            // HUD ve ÇARK
            'GameHUD': (context, game) => GameHUD(game: game as TimelessGame),
            'DailySpin': (context, game) =>
                DailySpinOverlay(game: game as TimelessGame),
          },
          // Oyun ilk açıldığında Ana Menü gelsin
          initialActiveOverlays: const ['AnaMenu'],
        ),
      ),
    );
  }
}

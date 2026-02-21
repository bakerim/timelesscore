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
import 'overlays/splash_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.init();

  if (!kIsWeb) {
    await Flame.device.fullScreen();
    await Flame.device.setPortraitUpOnly();
    await MobileAds.instance.initialize();
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
  final TimelessGame game = TimelessGame();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        bool shouldExit = game.onBackPressed();
        if (shouldExit) {
          // Gerekirse uygulamadan çıkış kodu buraya
        }
      },
      child: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'Splash': (context, game) =>
                SplashOverlay(game: game as TimelessGame),
            'AnaMenu': (context, game) => MainMenu(game: game as TimelessGame),
            'GameOver': (context, game) =>
                GameOver(game: game as TimelessGame), // <-- DÜZELTİLDİ
            'PauseMenu': (context, game) =>
                PauseMenu(game: game as TimelessGame),
            'ShopMenu': (context, game) => ShopMenu(game: game as TimelessGame),
            'Roadmap': (context, game) =>
                RoadmapOverlay(game: game as TimelessGame),
            'SettingsMenu': (context, game) =>
                SettingsOverlay(game: game as TimelessGame),
            'ReviveMenu': (context, game) =>
                ReviveMenu(game: game as TimelessGame),
          },
          initialActiveOverlays: const ['Splash'],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart'; // <-- BU EKLENDİ (kIsWeb için)

import 'screens/game_screen.dart';
import 'data/data_manager.dart';
import 'core/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Veri ve Dil Yönetimi (Her yerde çalışır)
  await DataManager.init();
  await Dil.init();

  // 2. SADECE MOBİL İÇİN OLANLARI AYIRALIM
  if (!kIsWeb) {
    // Tam ekran ve dikey mod (Web'de tam ekran zorlaması hataya sebep olabilir)
    await Flame.device.fullScreen();
    await Flame.device.setPortraitUpOnly();

    // Reklam Servisi (Web'de bu satır uygulamayı çökertir)
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
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
    );
  }
}

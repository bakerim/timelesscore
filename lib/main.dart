import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';

// --- YENİ EKLENEN KISIM: Native Splash Paketi ---
import 'package:flutter_native_splash/flutter_native_splash.dart';

// --- KENDİ DOSYALARIMIZ ---
import 'data/data_manager.dart';
import 'core/localization.dart';
import 'screens/game_screen.dart';

void main() async {
  // 1. KRİTİK ADIM: Binding'i bir değişkene alıyoruz (Splash paketi bunu istiyor)
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. KRİTİK ADIM: Arka plandaki yüklemeler bitene kadar logolu splash ekranını tut!
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // --- Yöneticileri ve Firebase'i başlat ---
  await Firebase.initializeApp();
  await DataManager.init();
  await Dil.init();

  if (!kIsWeb) {
    await Flame.device.fullScreen();
    await Flame.device.setPortraitUpOnly();
    await MobileAds.instance.initialize();
  }

  // 3. KRİTİK ADIM: Her şey yüklendi! Artık logolu splash ekranını güvenle kaldırabiliriz.
  FlutterNativeSplash.remove();

  // Oyunu başlat
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

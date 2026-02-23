import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// --- YENİ EKLENEN KISIMLAR ---
import 'package:firebase_core/firebase_core.dart';

// --- KENDİ DOSYALARIMIZ ---
import 'data/data_manager.dart';
import 'core/localization.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- KRİTİK ADIM: Firebase'i burada başlatıyoruz ---
  await Firebase.initializeApp();

  // Yöneticileri başlat
  await DataManager.init();
  await Dil.init();

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
      // OYUN ARTIK İÇERİDEKİ SAHTE SINIFTAN DEĞİL,
      // SENİN HAZIRLADIĞIN GERÇEK game_screen.dart DOSYASINDAN BAŞLAYACAK!
      home: const GameScreen(),
    );
  }
}

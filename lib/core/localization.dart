import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class Dil {
  // Varsayılan dili artık İngilizce (EN) yapıyoruz (Global standart)
  static String mevcutDil = 'EN';

  static String get currentLanguage => mevcutDil.toLowerCase();

  // --- İŞTE SİHİRLİ FONKSİYON: OYUN AÇILIRKEN ÇALIŞACAK ---
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String? kayitliDil = prefs.getString('secili_dil');

    if (_sozluk.containsKey(kayitliDil)) {
      // 1. Durum: Oyuncu daha önce ayarlardan dil seçmişse onu yükle
      mevcutDil = kayitliDil!;
    } else {
      // 2. Durum: Oyun İLK DEFA açılıyor. Telefonun dilini gizlice oku!
      String cihazDili =
          ui.PlatformDispatcher.instance.locale.languageCode.toUpperCase();

      if (_sozluk.containsKey(cihazDili)) {
        mevcutDil =
            cihazDili; // Örn: Telefon Fransızca (FR) ise direkt FR açılır
      } else {
        mevcutDil =
            'EN'; // Telefon Japonca, Rusça vb. ise zorunlu İngilizce (EN) açılır
      }
    }
  }

  // Ayarlardan dil değiştiğinde anında hafızaya yazar
  static Future<void> setLanguage(String langCode) async {
    String upperLang = langCode.toUpperCase();
    if (_sozluk.containsKey(upperLang)) {
      mevcutDil = upperLang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secili_dil', upperLang);
    }
  }

  static final Map<String, Map<String, String>> _sozluk = {
    // ----------------------------------------------------------------
    // TÜRKÇE (TR)
    // ----------------------------------------------------------------
    'TR': {
      'baslik': 'Timeless Core',
      'basla': 'OYUNA BAŞLA',
      'devam_et': 'DEVAM ET',
      'ayarlar': 'AYARLAR',
      'market': 'MARKET',
      'temalar': 'TEMALAR', // HATA DÜZELTİLDİ! (Önceden THEMES yazıyordu)
      'cikis': 'ÇIKIŞ',
      'oyun_bitti': 'OYUN BİTTİ',
      'puan': 'PUAN',
      'rekor': 'REKOR',
      'seviye': 'SEVİYE',
      'yeni_rekor': 'YENİ REKOR!',
      'duraklatildi': 'OYUN DURDURULDU',
      'ana_menu': 'ANA MENÜ',
      'tekrar_oyna': 'TEKRAR OYNA',
      'muzik': 'Müzik',
      'ses': 'Ses Efektleri',
      'dil_secimi': 'Dil Seçimi',
      'geri': 'GERİ DÖN',
      'izle_kazan': 'İZLE VE KAZAN',
      'iki_kat_kazan': '2 KATI PUAN KAZAN',
      'reklam_yukleniyor': 'Reklam yükleniyor...',
      'reklam_kaldir': 'REKLAMLARI KALDIR',
      'premium_aktif': 'PREMIUM AKTİF',
      'yetersiz_bakiye': 'Yetersiz Kristal!',
      'satin_al': 'SATIN AL',
      'ucretsiz': 'ÜCRETSİZ',
      'zaman_bukuldu': 'ZAMAN BÜKÜLDÜ!',
      'zaman_normal': 'ZAMAN NORMALE DÖNDÜ',
      'ikinci_sans': 'İKİNCİ ŞANS!',
      'mukemmel': 'MÜKEMMEL!',
      'yol_haritasi': 'YOL HARİTASI',
      'kristal_kazandin': 'Kristal Kazandın!',
      'paket_baslangic': 'Başlangıç Paketi',
      'paket_profesyonel': 'Profesyonel Paket',
      'paket_mega': 'Mega Paket',
      'reklamsiz_aciklama': 'Reklamsız oyun keyfi!',
      'kesintisiz_aciklama': 'Kesintisiz deneyim için.',
      'market_baslik': 'ZAMAN MARKETİ',
      'toplam': 'TOPLAM',
      'kazanc': 'KAZANÇ',
      'tamam': 'TAMAM',
      'evet': 'EVET',
      'hayir': 'HAYIR',
      'basarili': 'BAŞARILI!',
      'kilitli': 'KİLİTLİ',
      'tamamlandi': 'TAMAMLANDI',

      'rutbe_acemi': 'ACEMİ',
      'rutbe_cirak': 'ÇIRAK',
      'rutbe_kasif': 'KAŞİF',
      'rutbe_usta': 'USTA',
      'rutbe_efsane': 'EFSANE',
      'rutbe_zaman_yocusu': 'ZAMAN YOLCUSU',
      'rutbe_zaman_lordu': 'ZAMAN LORDU',
    },

    // ----------------------------------------------------------------
    // ENGLISH (EN)
    // ----------------------------------------------------------------
    'EN': {
      'baslik': 'Timeless Core',
      'basla': 'START GAME',
      'devam_et': 'RESUME',
      'ayarlar': 'SETTINGS',
      'market': 'SHOP',
      'temalar': 'THEMES', // Eksik tamamlandı
      'cikis': 'EXIT',
      'oyun_bitti': 'GAME OVER',
      'puan': 'SCORE',
      'rekor': 'BEST',
      'seviye': 'LEVEL',
      'yeni_rekor': 'NEW RECORD!',
      'duraklatildi': 'PAUSED',
      'ana_menu': 'MAIN MENU',
      'tekrar_oyna': 'PLAY AGAIN',
      'muzik': 'Music',
      'ses': 'Sound FX',
      'dil_secimi': 'Language',
      'geri': 'BACK',
      'izle_kazan': 'WATCH & WIN',
      'iki_kat_kazan': 'GET 2X SCORE',
      'reklam_yukleniyor': 'Loading ad...',
      'reklam_kaldir': 'REMOVE ADS',
      'premium_aktif': 'PREMIUM ACTIVE',
      'yetersiz_bakiye': 'Not enough Crystals!',
      'satin_al': 'BUY',
      'ucretsiz': 'FREE',
      'zaman_bukuldu': 'TIME WARPED!',
      'zaman_normal': 'TIME NORMAL',
      'ikinci_sans': 'SECOND CHANCE!',
      'mukemmel': 'PERFECT!',
      'yol_haritasi': 'ROADMAP', // Eksik tamamlandı
      'kristal_kazandin': 'Crystals Earned!',
      'paket_baslangic': 'Starter Pack',
      'paket_profesyonel': 'Pro Pack',
      'paket_mega': 'Mega Pack',
      'reklamsiz_aciklama': 'Ad-free gaming!',
      'kesintisiz_aciklama': 'For uninterrupted experience.',
      'market_baslik': 'TIME SHOP',
      'toplam': 'TOTAL',
      'kazanc': 'EARNED',
      'tamam': 'OK',
      'evet': 'YES',
      'hayir': 'NO',
      'basarili': 'SUCCESS!',
      'kilitli': 'LOCKED',
      'tamamlandi': 'COMPLETED',

      'rutbe_acemi': 'NOVICE',
      'rutbe_cirak': 'APPRENTICE',
      'rutbe_kasif': 'EXPLORER',
      'rutbe_usta': 'MASTER',
      'rutbe_efsane': 'LEGEND',
      'rutbe_zaman_yocusu': 'TIME TRAVELER',
      'rutbe_zaman_lordu': 'TIME LORD',
    },

    // ----------------------------------------------------------------
    // DEUTSCH (DE)
    // ----------------------------------------------------------------
    'DE': {
      'baslik': 'Timeless Core',
      'basla': 'STARTEN',
      'devam_et': 'WEITER',
      'ayarlar': 'EINSTELLUNGEN',
      'market': 'LADEN',
      'temalar': 'THEMEN', // Eksik
      'cikis': 'BEENDEN',
      'oyun_bitti': 'SPIEL VORBEI',
      'puan': 'PUNKTE',
      'rekor': 'REKORD',
      'seviye': 'LEVEL',
      'yeni_rekor': 'NEUER REKORD!',
      'duraklatildi': 'PAUSIERT',
      'ana_menu': 'HAUPTMENÜ',
      'tekrar_oyna': 'NEUSTART',
      'muzik': 'Musik',
      'ses': 'Soundeffekte',
      'dil_secimi': 'Sprache',
      'geri': 'ZURÜCK',
      'izle_kazan': 'ANSEHEN & GEWINNEN',
      'iki_kat_kazan': '2X PUNKTE',
      'reklam_yukleniyor': 'Werbung lädt...',
      'reklam_kaldir': 'WERBUNG ENTFERNEN',
      'premium_aktif': 'PREMIUM AKTIV',
      'yetersiz_bakiye': 'Nicht genug Kristalle!',
      'satin_al': 'KAUFEN',
      'ucretsiz': 'KOSTENLOS',
      'zaman_bukuldu': 'ZEITVERZERRUNG!',
      'zaman_normal': 'ZEIT NORMAL',
      'ikinci_sans': 'ZWEITE CHANCE!',
      'mukemmel': 'PERFEKT!',
      'yol_haritasi': 'ROADMAP',
      'kristal_kazandin': 'Kristalle Verdient!',
      'paket_baslangic': 'Starterpaket',
      'paket_profesyonel': 'Profi-Paket',
      'paket_mega': 'Megapaket',
      'reklamsiz_aciklama': 'Werbefreies Spiel!',
      'kesintisiz_aciklama': 'Für ungestörtes Erlebnis.',
      'market_baslik': 'ZEITLADEN',
      'toplam': 'GESAMT',
      'kazanc': 'VERDIENT',
      'tamam': 'OK',
      'evet': 'JA',
      'hayir': 'NEIN',
      'basarili': 'ERFOLG!',
      'kilitli': 'GESPERRT',
      'tamamlandi': 'FERTIG',

      'rutbe_acemi': 'ANFÄNGER',
      'rutbe_cirak': 'LEHRLING',
      'rutbe_kasif': 'ENTDECKER',
      'rutbe_usta': 'MEISTER',
      'rutbe_efsane': 'LEGENDE',
      'rutbe_zaman_yocusu': 'ZEITREISENDER',
      'rutbe_zaman_lordu': 'ZEITLORD',
    },

    // ----------------------------------------------------------------
    // ESPAÑOL (ES)
    // ----------------------------------------------------------------
    'ES': {
      'baslik': 'Timeless Core',
      'basla': 'EMPEZAR',
      'devam_et': 'CONTINUAR',
      'ayarlar': 'AJUSTES',
      'market': 'TIENDA',
      'temalar': 'TEMAS', // Eksik
      'cikis': 'SALIR',
      'oyun_bitti': 'JUEGO TERMINADO',
      'puan': 'PUNTOS',
      'rekor': 'RÉCORD',
      'seviye': 'NIVEL',
      'yeni_rekor': '¡NUEVO RÉCORD!',
      'duraklatildi': 'PAUSADO',
      'ana_menu': 'MENÚ PRINCIPAL',
      'tekrar_oyna': 'JUGAR DE NUEVO',
      'muzik': 'Música',
      'ses': 'Efectos de Sonido',
      'dil_secimi': 'Idioma',
      'geri': 'VOLVER',
      'izle_kazan': 'VER Y GANAR',
      'iki_kat_kazan': '2X PUNTOS',
      'reklam_yukleniyor': 'Cargando anuncio...',
      'reklam_kaldir': 'QUITAR ANUNCIOS',
      'premium_aktif': 'PREMIUM ACTIVO',
      'yetersiz_bakiye': '¡No hay suficientes cristales!',
      'satin_al': 'COMPRAR',
      'ucretsiz': 'GRATIS',
      'zaman_bukuldu': '¡TIEMPO DEFORMADO!',
      'zaman_normal': 'TIEMPO NORMAL',
      'ikinci_sans': '¡SEGUNDA OPORTUNIDAD!',
      'mukemmel': '¡PERFECTO!',
      'yol_haritasi': 'HOJA DE RUTA',
      'kristal_kazandin': '¡Cristales Ganados!',
      'paket_baslangic': 'Paquete de Inicio',
      'paket_profesyonel': 'Paquete Pro',
      'paket_mega': 'Paquete Mega',
      'reklamsiz_aciklama': '¡Juego sin anuncios!',
      'kesintisiz_aciklama': 'Para una experiencia ininterrumpida.',
      'market_baslik': 'TIENDA',
      'toplam': 'TOTAL',
      'kazanc': 'GANADO',
      'tamam': 'OK',
      'evet': 'SÍ',
      'hayir': 'NO',
      'basarili': '¡ÉXITO!',
      'kilitli': 'BLOQUEADO',
      'tamamlandi': 'COMPLETADO',

      'rutbe_acemi': 'NOVATO',
      'rutbe_cirak': 'APRENDIZ',
      'rutbe_kasif': 'EXPLORADOR',
      'rutbe_usta': 'MAESTRO',
      'rutbe_efsane': 'LEYENDA',
      'rutbe_zaman_yocusu': 'VIAJERO DEL TIEMPO',
      'rutbe_zaman_lordu': 'SEÑOR DEL TIEMPO',
    },

    // ----------------------------------------------------------------
    // FRANÇAIS (FR)
    // ----------------------------------------------------------------
    'FR': {
      'baslik': 'Timeless Core',
      'basla': 'COMMENCER',
      'devam_et': 'CONTINUER',
      'ayarlar': 'PARAMÈTRES',
      'market': 'BOUTIQUE',
      'temalar': 'THÈMES', // Eksik
      'cikis': 'QUITTER',
      'oyun_bitti': 'JEU TERMINÉ',
      'puan': 'SCORE',
      'rekor': 'RECORD',
      'seviye': 'NIVEAU',
      'yeni_rekor': 'NOUVEAU RECORD!',
      'duraklatildi': 'PAUSE',
      'ana_menu': 'MENU PRINCIPAL',
      'tekrar_oyna': 'REJOUER',
      'muzik': 'Musique',
      'ses': 'Effets Sonores',
      'dil_secimi': 'Langue',
      'geri': 'RETOUR',
      'izle_kazan': 'REGARDER & GAGNER',
      'iki_kat_kazan': 'SCORE 2X',
      'reklam_yukleniyor': 'Chargement...',
      'reklam_kaldir': 'SUPPRIMER LES PUBS',
      'premium_aktif': 'PREMIUM ACTIVO',
      'yetersiz_bakiye': 'Pas assez de cristaux!',
      'satin_al': 'ACHETER',
      'ucretsiz': 'GRATUIT',
      'zaman_bukuldu': 'TEMPS DÉFORMÉ!',
      'zaman_normal': 'TEMPS NORMAL',
      'ikinci_sans': 'SECONDE CHANCE!',
      'mukemmel': 'PARFAIT!',
      'yol_haritasi': 'FEUILLE DE ROUTE',
      'kristal_kazandin': 'Cristaux Gagnés!',
      'paket_baslangic': 'Pack Débutant',
      'paket_profesyonel': 'Pack Pro',
      'paket_mega': 'Pack Méga',
      'reklamsiz_aciklama': 'Jeu sans publicité!',
      'kesintisiz_aciklama': 'Pour une expérience ininterrompue.',
      'market_baslik': 'BOUTIQUE',
      'toplam': 'TOTAL',
      'kazanc': 'GAGNÉ',
      'tamam': 'OK',
      'evet': 'OUI',
      'hayir': 'NON',
      'basarili': 'SUCCÈS!',
      'kilitli': 'VERROUILLÉ',
      'tamamlandi': 'TERMINÉ',

      'rutbe_acemi': 'NOVICE',
      'rutbe_cirak': 'APPRENTI',
      'rutbe_kasif': 'EXPLORATEUR',
      'rutbe_usta': 'MAÎTRE',
      'rutbe_efsane': 'LÉGENDE',
      'rutbe_zaman_yocusu': 'VOYAGEUR DU TEMPS',
      'rutbe_zaman_lordu': 'SEIGNEUR DU TEMPS',
    },
  };

  static String get(String key) {
    if (_sozluk[mevcutDil] != null && _sozluk[mevcutDil]!.containsKey(key)) {
      return _sozluk[mevcutDil]![key]!;
    }
    // Eğer kelimeyi mevcut dilde bulamazsa İngilizceye (EN) bak, orada da yoksa büyük harfle aynen yaz.
    return _sozluk['EN']?[key] ?? key.toUpperCase();
  }

  static Future<void> dilDegistir(String yeniDil) async {
    await setLanguage(yeniDil);
  }
}

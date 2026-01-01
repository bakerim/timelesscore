# Moving Pixel - Flutter & Flame Puzzle Game
**Profesyonel Kaynak Kod**

Bu proje, Flutter ve Flame oyun motoru kullanılarak geliştirilmiş, AdMob ve Skor Kayıt özellikleri entegre edilmiş bir puzzle oyunudur.

## 🚀 Özellikler
* **Flame Engine v1.20:** En güncel ve performanslı oyun motoru.
* **AdMob Entegrasyonu:** Oyuncu oyunu kaybettiğinde "İzle ve Devam Et" seçeneği çıkar. Reklam izlenirse en alttaki 3 satır silinir.
* **Kalıcı Skor:** Yüksek skorlar telefon hafızasına kaydedilir.
* **Kolay Reskin:** Renkler ve tasarım tek bir sınıftan değiştirilebilir.

## 🛠️ Kurulum
1.  Projeyi indirin ve terminalde `flutter pub get` çalıştırın.
2.  `flutter run` diyerek test edin.

## 🎨 Nasıl Reskin Yapılır? (Özelleştirme)
`main.dart` dosyasını açın ve `Tasarim` sınıfını bulun.
* `renkler` listesini değiştirerek blok renklerini ayarlayabilirsiniz.
* `arkaPlan` rengini değiştirerek oyunun temasını değiştirebilirsiniz.

## 💰 AdMob Kurulumu
Para kazanmaya başlamak için:
1.  AdMob hesabınızdan yeni bir uygulama oluşturun.
2.  `AndroidManifest.xml` dosyasındaki `APPLICATION_ID` kısmına kendi ID'nizi yazın.
3.  `main.dart` içindeki `reklamBirimID` değişkenine kendi "Ödüllü Reklam" ID'nizi yazın.

---
**İyi Satışlar!**
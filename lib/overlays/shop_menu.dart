import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/purchase_manager.dart';

class ShopMenu extends StatelessWidget {
  final TimelessGame game;
  const ShopMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("MARKET",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // REKLAM KALDIRMA BUTONU
              if (!DataManager.isAdsRemoved)
                ElevatedButton.icon(
                  onPressed: () =>
                      PurchaseManager.buyProduct(PurchaseManager.idRemoveAds),
                  icon: const Icon(Icons.block, color: Colors.black),
                  label: const Text("Reklamları Kaldır",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 50)),
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Text("Reklamlar Kaldırıldı",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("COIN PAKETLERİ",
                      style:
                          TextStyle(color: Colors.cyanAccent, fontSize: 14))),
              const Divider(color: Colors.cyanAccent),

              // COIN PAKETİ 1 (Liste Elemanı)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.white10, shape: BoxShape.circle),
                  child: const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 30),
                ),
                title: const Text("1000 Coin",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Hızlı başlangıç",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: ElevatedButton(
                  onPressed: () =>
                      PurchaseManager.buyProduct(PurchaseManager.idCoinPack1),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("₺29.99"),
                ),
              ),

              // STARTER PACK (Liste Elemanı)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.deepPurpleAccent, shape: BoxShape.circle),
                  child: const Icon(Icons.rocket_launch,
                      color: Colors.white, size: 30),
                ),
                title: const Text("Başlangıç Paketi",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Reklamsız + 5k Coin",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: ElevatedButton(
                  onPressed: () {
                    // İleride ID'si eklenince burası çalışacak
                    debugPrint("Starter Pack Tıklandı");
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  child: const Text("₺99.99"),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  game.overlays.remove('Shop');
                  game.overlays.add('AnaMenu');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text("Geri Dön",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

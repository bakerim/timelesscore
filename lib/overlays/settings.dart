import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../core/constants.dart';
import '../core/localization.dart';

class AyarlarOverlay extends StatefulWidget {
  final TimelessGame game;
  const AyarlarOverlay({super.key, required this.game});

  @override
  State<AyarlarOverlay> createState() => _AyarlarOverlayState();
}

class _AyarlarOverlayState extends State<AyarlarOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Tasarim.arkaPlan,
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(Dil.get("secenekler"),
                style: const TextStyle(color: Colors.white, fontSize: 30)),
            const SizedBox(height: 40),
            SwitchListTile(
                title: Text(Dil.get("ses_efektleri"),
                    style: const TextStyle(color: Colors.white)),
                value: widget.game.sesAcik,
                onChanged: (val) {
                  setState(() {
                    widget.game.sesAcik = val;
                  });
                }),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('Ayarlar');
                  widget.game.overlays.add('AnaMenu');
                },
                child: Text(Dil.get("geri_don"))),
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/custom_map.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBarCustom(
        title: 'Mapa',
        onNotificationTap: () {
          debugPrint('Notificaciones tapped');
        },
      ),
      body: CustomMap(),
    );
  }
}
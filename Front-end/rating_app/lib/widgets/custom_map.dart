import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CustomMap extends StatefulWidget {
  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  LatLng? _ubicacionActual;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      debugPrint("🚫 Servicio de ubicación desactivado");
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        debugPrint("🚫 Permiso de ubicación denegado");
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      debugPrint("🚫 Permiso de ubicación denegado permanentemente");
      return;
    }

    Position posicion = await Geolocator.getCurrentPosition();
    setState(() {
      _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ubicacion = _ubicacionActual;

    if (ubicacion == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _ubicacionActual == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: ubicacion,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.rating_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ubicacion,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

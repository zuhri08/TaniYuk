import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialCenter;
  const MapPickerScreen({super.key, this.initialCenter = const LatLng(-7.2575, 112.7521)});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialCenter;
  }

  String _getDetailedAddress(LatLng point) {
    final lat = point.latitude;
    final lon = point.longitude;

    // Strict Surabaya districts mapping
    String zona = '';
    String kecamatan = '';

    if (lat > -7.24) {
      if (lon < 112.73) {
        zona = 'Surabaya Utara';
        kecamatan = 'Kec. Krembangan / Pabean Cantian / Semampir';
      } else if (lon < 112.77) {
        zona = 'Surabaya Pusat / Utara';
        kecamatan = 'Kec. Genteng / Simokerto / Kenjeran';
      } else {
        zona = 'Surabaya Timur';
        kecamatan = 'Kec. Mulyorejo / Bulak / Kenjeran';
      }
    } else if (lat > -7.30) {
      if (lon < 112.72) {
        zona = 'Surabaya Barat';
        kecamatan = 'Kec. Tandes / Sukomanunggal / Asemrowo';
      } else if (lon < 112.76) {
        zona = 'Surabaya Pusat';
        kecamatan = 'Kec. Tegalsari / Gubeng / Wonokromo';
      } else {
        zona = 'Surabaya Timur';
        kecamatan = 'Kec. Sukolilo / Tambaksari / Rungkut';
      }
    } else {
      if (lon < 112.71) {
        zona = 'Surabaya Barat';
        kecamatan = 'Kec. Lakarsantri / Pakal / Benowo';
      } else if (lon < 112.75) {
        zona = 'Surabaya Selatan';
        kecamatan = 'Kec. Wiyung / Karang Pilang / Gayungan / Jambangan';
      } else {
        zona = 'Surabaya Timur / Selatan';
        kecamatan = 'Kec. Gunung Anyar / Rungkut / Tenggilis Mejoyo';
      }
    }
    return '$kecamatan, $zona, Kota Surabaya, Jawa Timur';
  }

  @override
  Widget build(BuildContext context) {
    final detailedAddress = _getDetailedAddress(_currentCenter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Lahan di Surabaya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C5E4A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentCenter = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.TaniYuk',
              ),
            ],
          ),
          // Center Pin / Crosshair
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 48),
            ),
          ),
          // Bottom Confirmation Card strictly for Surabaya
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Lokasi Surabaya:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('Area Surabaya', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detailedAddress,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF132E25), height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lat: ${_currentCenter.latitude.toStringAsFixed(5)}, Lon: ${_currentCenter.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final locationName = '$detailedAddress (${_currentCenter.latitude.toStringAsFixed(3)}, ${_currentCenter.longitude.toStringAsFixed(3)})';
                        Navigator.pop(context, locationName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5E4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Gunakan Lokasi Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/geocoding_places_service.dart';

typedef CariTokoPupukScreen = MapTokoScreen;

class MapTokoScreen extends StatefulWidget {
  const MapTokoScreen({super.key});

  @override
  State<MapTokoScreen> createState() => _MapTokoScreenState();
}

class _MapTokoScreenState extends State<MapTokoScreen> {
  final MapController _mapController = MapController();
  LatLng _userLocation = const LatLng(-7.2575, 112.7521); // Default Surabaya
  String _userAddress = 'Surabaya, Jawa Timur';
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  String? _selectedStoreId;
  bool _isLoadingGps = false;
  bool _isLoadingStores = false;

  List<RealTokoPupuk> _storesList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentGpsLocation();
    });
  }

  Future<void> _getCurrentGpsLocation() async {
    setState(() {
      _isLoadingGps = true;
      _isLoadingStores = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fetchNearbyStores(_userLocation);
        setState(() => _isLoadingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fetchNearbyStores(_userLocation);
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _fetchNearbyStores(_userLocation);
        setState(() => _isLoadingGps = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final realGps = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = realGps;
        _isLoadingGps = false;
      });

      _mapController.move(realGps, 14.5);

      // Reverse Geocoding via Nominatim API
      GeocodingPlacesService.reverseGeocode(
        lat: realGps.latitude,
        lon: realGps.longitude,
      ).then((addr) {
        if (mounted) {
          setState(() {
            _userAddress = addr;
          });
        }
      });

      // Search Places API & Calculate Distances
      await _fetchNearbyStores(realGps);
    } catch (e) {
      debugPrint('GPS Places Error: $e');
      _fetchNearbyStores(_userLocation);
      setState(() => _isLoadingGps = false);
    }
  }

  Future<void> _fetchNearbyStores(LatLng location) async {
    setState(() => _isLoadingStores = true);
    final stores = await GeocodingPlacesService.searchNearbyFertilizerStores(
      userLocation: location,
      query: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _storesList = stores;
        _isLoadingStores = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Memanggil kios: $phoneNumber')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor telepon: $phoneNumber')),
        );
      }
    }
  }

  Future<void> _openGoogleMapsDirections(LatLng storeLoc, String storeName) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${storeLoc.latitude},${storeLoc.longitude}&destination_place_id=$storeName',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rute ke $storeName: ${storeLoc.latitude}, ${storeLoc.longitude}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Maps launch note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _storesList.where((toko) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Buka') return toko.isOpen;
      return toko.availablePupuk.any((p) => p.toLowerCase().contains(_selectedFilter.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toko Pupuk & Pertanian Terdekat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              _userAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C5E4A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _isLoadingGps
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.my_location),
            tooltip: 'GPS Real-Time API',
            onPressed: _getCurrentGpsLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map View (FlutterMap with Mapbox tiles)
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation,
                    initialZoom: 14.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.TaniYuk',
                    ),
                    MarkerLayer(
                      markers: [
                        // Real GPS User Marker
                        Marker(
                          point: _userLocation,
                          width: 45,
                          height: 45,
                          child: const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 36),
                        ),
                        // Store Markers
                        ..._storesList.map((toko) {
                          final isSelected = _selectedStoreId == toko.id;
                          return Marker(
                            point: toko.location,
                            width: isSelected ? 48 : 36,
                            height: isSelected ? 48 : 36,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStoreId = toko.id;
                                });
                                _mapController.move(toko.location, 16);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('📍 Dipilih: ${toko.name} (${toko.distanceKm} km)')),
                                );
                              },
                              child: Icon(
                                Icons.location_on_rounded,
                                color: isSelected
                                    ? Colors.amber.shade700
                                    : (toko.isOpen ? Colors.green.shade700 : Colors.red.shade700),
                                size: isSelected ? 48 : 36,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                // Zoom In / Zoom Out Buttons
                Positioned(
                  right: 12,
                  bottom: 60,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in_map',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2C5E4A),
                        onPressed: () {
                          final zoom = _mapController.camera.zoom + 1;
                          _mapController.move(_mapController.camera.center, zoom);
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out_map',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2C5E4A),
                        onPressed: () {
                          final zoom = _mapController.camera.zoom - 1;
                          _mapController.move(_mapController.camera.center, zoom);
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                // My Location Button
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'my_loc_map',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2C5E4A),
                    elevation: 3,
                    onPressed: _getCurrentGpsLocation,
                    child: _isLoadingGps
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF2C5E4A), strokeWidth: 2))
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter bar
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF132E25),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchNearbyStores(_userLocation);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari toko pupuk / tempat pertanian sekitar GPS...',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2C5E4A), size: 20),
                    suffixIcon: _isLoadingStores
                        ? const SizedBox(width: 16, height: 16, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF132E25))))
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Semua', 'Buka', 'Urea', 'NPK Ponska', 'Organik'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(filter, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2C5E4A),
                          backgroundColor: const Color(0xFF132E25),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF89D7B7),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          onSelected: (selected) => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Store List
          Expanded(
            flex: 5,
            child: _isLoadingStores
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF132E25)),
                  )
                : filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada toko pupuk ditemukan.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final toko = filteredList[index];
                          final isSelected = _selectedStoreId == toko.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: isSelected ? 4 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? Colors.amber.shade700 : const Color(0xFF2C5E4A),
                                width: isSelected ? 1.5 : 0.2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedStoreId = toko.id;
                                });
                                _mapController.move(toko.location, 16);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('📍 Menuju lokasi: ${toko.name}')),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            toko.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.amber.shade800 : const Color(0xFF132E25),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: toko.isOpen ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            toko.isOpen ? 'Buka' : 'Tutup',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: toko.isOpen ? Colors.green.shade700 : Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            toko.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ),
                                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                                        Text(
                                          '${toko.distanceKm} km',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C5E4A)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: toko.availablePupuk.map((p) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF89D7B7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            p,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF132E25),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () => _openGoogleMapsDirections(toko.location, toko.name),
                                          icon: const Icon(Icons.directions_rounded, size: 14),
                                          label: const Text('Rute Maps'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF2C5E4A),
                                            side: const BorderSide(color: Color(0xFF2C5E4A)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _makePhoneCall(toko.phone),
                                          icon: const Icon(Icons.phone, size: 12),
                                          label: Text('Telepon (${toko.phone})'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2C5E4A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            textStyle: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../akun/notifikasi.dart';
import '../services/bmkg_weather_service.dart';
import '../services/market_price_service.dart';
import 'map_picker_screen.dart';

class PeluangScreen extends StatefulWidget {
  const PeluangScreen({super.key});

  @override
  State<PeluangScreen> createState() => _PeluangScreenState();
}

class _PeluangScreenState extends State<PeluangScreen> {
  int _selectedSubTab = 0; // 0: Rekomendasi, 1: Harga Pasar, 2: Cuaca
  String _selectedLocation = 'Kec. Tegalsari / Gubeng / Wonokromo, Surabaya Pusat, Kota Surabaya (-7.258, 112.752)';
  final TextEditingController _luasLahanController = TextEditingController(text: '1.000 m²');
  DateTime _selectedDate = DateTime(2024, 10, 15);

  final List<String> _subTabs = ['Rekomendasi', 'Harga Pasar', 'Cuaca'];

  late Future<BmkgWeatherData> _weatherFuture;
  late Future<List<MarketItem>> _marketFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = BmkgWeatherService.fetchLiveWeather(location: _selectedLocation);
    _marketFuture = MarketPriceService.fetchLiveMarketPrices(region: _selectedLocation);
  }

  @override
  void dispose() {
    _luasLahanController.dispose();
    super.dispose();
  }

  void _changeLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _weatherFuture = BmkgWeatherService.fetchLiveWeather(location: location);
      _marketFuture = MarketPriceService.fetchLiveMarketPrices(region: location);
    });
  }

  String _getDetailedAddress(double lat, double lon) {
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
    return '$kecamatan, $zona, Kota Surabaya (${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)})';
  }

  Future<void> _getGpsLocationForLahan() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Layanan GPS tidak aktif.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final locName = _getDetailedAddress(position.latitude, position.longitude);
      _changeLocation(locName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📍 Lokasi terkini disesuaikan: $locName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Gagal mendeteksi lokasi terkini.')),
        );
      }
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (result != null) {
      _changeLocation(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🗺️ Lokasi lahan dipilih dari peta: $result')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C5E4A),
              onPrimary: Colors.white,
              surface: Color(0xFFFFF4E1),
              onSurface: Color(0xFF132E25),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getSoilTypeForLocation(String location) {
    if (location.toLowerCase().contains('bandung') || location.toLowerCase().contains('lembang')) {
      return 'Andosol / Humus Vulkanik (Sangat Subur)';
    } else if (location.toLowerCase().contains('garut')) {
      return 'Latosol / Humus Dataran Tinggi';
    } else {
      return 'Aluvial / Lempung Berpasir (Dataran Rendah)';
    }
  }

  List<Map<String, dynamic>> _getRecommendationsForLocation(String location) {
    if (location.toLowerCase().contains('bandung') || location.toLowerCase().contains('lembang')) {
      return [
        {
          'cropName': 'Wortel Lokal Super',
          'matchPercentage': 96,
          'duration': '90-100 Hari',
          'profit': 'Tinggi (Rp 18jt/musim)',
          'weatherSuitability': 'Sangat cocok dengan suhu sejuk dataran tinggi Lembang.',
        },
        {
          'cropName': 'Selada Keriting',
          'matchPercentage': 91,
          'duration': '45-50 Hari',
          'profit': 'Cepat Panen (Rp 12jt/musim)',
          'weatherSuitability': 'Optimal pada kelembapan dan suhu sejuk pegunungan.',
        },
      ];
    } else {
      return [
        {
          'cropName': 'Tomat Arthaloka',
          'matchPercentage': 94,
          'duration': '60-70 Hari',
          'profit': 'Tinggi (Rp 15jt/musim)',
          'weatherSuitability': 'Sangat cocok dengan suhu hangat dan irigasi teratur.',
        },
        {
          'cropName': 'Cabai Merah Keriting',
          'matchPercentage': 88,
          'duration': '90-100 Hari',
          'profit': 'Sangat Tinggi (Rp 25jt/musim)',
          'weatherSuitability': 'Cocok di dataran rendah, pastikan drainase lahan terjaga.',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final soilType = _getSoilTypeForLocation(_selectedLocation);
    final recommendations = _getRecommendationsForLocation(_selectedLocation);
    final formattedDate = '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Rencana Tanam',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Rencanakan hari ini, panen lebih baik',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Sub-Tabs
            Row(
              children: List.generate(_subTabs.length, (index) {
                final isSelected = _selectedSubTab == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubTab = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index == _subTabs.length - 1 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF132E25) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF132E25) : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _subTabs[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Tab 0: Rekomendasi Tanam
            if (_selectedSubTab == 0) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C5E4A), width: 0.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Informasi Lahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Icon(Icons.edit_location_alt_outlined, color: Color(0xFF132E25), size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lokasi Lahan dengan 2 Opsi: Sesuaikan Lokasi Terkini & Pilih di Maps
                    const Text('Lokasi Lahan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF2C5E4A), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedLocation,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF132E25), height: 1.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _getGpsLocationForLahan,
                                  icon: const Icon(Icons.my_location, size: 14),
                                  label: const Text('Sesuaikan Lokasi Terkini'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2C5E4A),
                                    side: const BorderSide(color: Color(0xFF2C5E4A)),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _openMapPicker,
                                  icon: const Icon(Icons.map, size: 14),
                                  label: const Text('Pilih di Maps'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C5E4A),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Luas Lahan & Tanggal Tanam (Editable)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Luas Lahan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _luasLahanController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF132E25)),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF2C5E4A), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Tanam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(formattedDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF132E25))),
                                      const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF2C5E4A)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Analyze Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✨ Analisis lahan dan rekomendasi tanam diperbarui!')),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Analisis Kesesuaian Lahan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rekomendasi Tanaman Section
              const Text(
                'Rekomendasi Tanaman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Berdasarkan kondisi cuaca BMKG & wilayah lahanmu',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Soil Type Badge Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5E4A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2C5E4A), width: 0.3),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.terrain_rounded, size: 18, color: Color(0xFF2C5E4A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimasi Jenis Tanah: $soilType',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              ...recommendations.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _recommendationCard(
                    cropName: rec['cropName'],
                    matchPercentage: rec['matchPercentage'],
                    duration: rec['duration'],
                    profit: rec['profit'],
                    weatherSuitability: rec['weatherSuitability'],
                  ),
                );
              }),
            ],

            // Tab 1: Harga Pasar (Live Dynamic Market Prices via MarketPriceService)
            if (_selectedSubTab == 1) ...[
              FutureBuilder<List<MarketItem>>(
                future: _marketFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFF132E25)),
                      ),
                    );
                  }
                  final items = snapshot.data ?? [];
                  final now = DateTime.now();
                  final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} WIB';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C5E4A), width: 0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '📊 Harga Komoditas Pasar Hari Ini',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Live Realtime API • Diperbarui $timeStr',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF2C5E4A)),
                              tooltip: 'Perbarui Harga Realtime',
                              onPressed: () {
                                setState(() {
                                  _marketFuture = MarketPriceService.fetchLiveMarketPrices(region: _selectedLocation);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⚡ Harga komoditas pasar berhasil diperbarui secara realtime!')),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...items.map((item) {
                          return Column(
                            children: [
                              _MarketPriceRow(
                                crop: item.crop,
                                price: item.price,
                                change: item.change,
                                isUp: item.isUp,
                                category: item.category,
                                note: item.marketNote,
                              ),
                              if (item != items.last) const Divider(height: 20),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ],

            // Tab 2: Cuaca (Polished Weather Tab with Gradient Card & Live BMKG data)
            if (_selectedSubTab == 2) ...[
              FutureBuilder<BmkgWeatherData>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFF132E25)),
                      ),
                    );
                  }
                  final weather = snapshot.data ?? BmkgWeatherData.fallback(location: _selectedLocation);
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF132E25), Color(0xFF2C5E4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFF89D7B7), size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      weather.location,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              tooltip: 'Perbarui Cuaca',
                              onPressed: () {
                                setState(() {
                                  _weatherFuture = BmkgWeatherService.fetchLiveWeather(location: _selectedLocation);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🌤️ Memperbarui data cuaca BMKG terkini...')),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${weather.temperature.toStringAsFixed(1)}°C',
                                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weather.condition,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF89D7B7)),
                                ),
                              ],
                            ),
                            const Icon(Icons.wb_sunny_rounded, color: Colors.amberAccent, size: 64),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _weatherMetricItem(Icons.water_drop_outlined, 'Kelembapan', '${weather.humidity}%'),
                            _weatherMetricItem(Icons.air_rounded, 'Kecepatan Angin', '${weather.windSpeed} km/j'),
                            _weatherMetricItem(Icons.update_rounded, 'Pembaruan', 'Live BMKG'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF89D7B7).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF89D7B7), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  weather.recommendation,
                                  style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Widget _recommendationCard({
    required String cropName,
    required int matchPercentage,
    required String duration,
    required String profit,
    required String weatherSuitability,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C5E4A), width: 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cropName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132E25))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF89D7B7), borderRadius: BorderRadius.circular(8)),
                child: Text('$matchPercentage% Cocok', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF132E25))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.trending_up_rounded, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(profit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Text(weatherSuitability, style: const TextStyle(fontSize: 11, color: Color(0xFF428475), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _weatherMetricItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF89D7B7), size: 20),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _MarketPriceRow extends StatelessWidget {
  final String crop;
  final String price;
  final String change;
  final bool isUp;
  final String? category;
  final String? note;

  const _MarketPriceRow({
    required this.crop,
    required this.price,
    required this.change,
    required this.isUp,
    this.category,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(crop, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              if (note != null || category != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${category ?? 'Hortikultura'} • ${note ?? 'Harga Terkini'}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132E25))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isUp ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isUp ? Colors.green.shade200 : Colors.red.shade200),
              ),
              child: Text(
                change,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUp ? Colors.green.shade700 : Colors.red.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

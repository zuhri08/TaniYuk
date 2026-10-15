import 'package:flutter/material.dart';
import '../akun/uang_tani.dart';
import '../akun/catatan_aktivitas.dart';
import '../akun/pasar_tani.dart';
import '../akun/notifikasi.dart';
import '../services/bmkg_weather_service.dart';

class BerandaScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const BerandaScreen({super.key, this.onNavigateToTab});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final String _selectedLocation = '📍 Lokasi Saya (GPS)';
  late Future<BmkgWeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _loadBmkgWeather();
  }

  void _loadBmkgWeather() {
    setState(() {
      _weatherFuture = BmkgWeatherService.fetchLiveWeather(location: _selectedLocation);
    });
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.contains('Hujan')) return Icons.water_drop_rounded;
    if (condition.contains('Berawan')) return Icons.cloud_queue_rounded;
    if (condition.contains('Kabut')) return Icons.blur_on_rounded;
    return Icons.wb_sunny_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Halo, Pak Budi 👋',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Semangat, hari baru untuk bertani!',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1F2937)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
                  );
                },
              ),
              Positioned(
                right: 12,
                top: 14,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F623F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // BMKG Live Weather Card
            FutureBuilder<BmkgWeatherData>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F623F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text('Menghubungkan ke API BMKG...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                final weather = snapshot.data ?? BmkgWeatherData.fallback(location: _selectedLocation);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F623F), Color(0xFF15803D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F623F).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_getWeatherIcon(weather.condition), color: Colors.amber, size: 38),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather.temperature.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${weather.condition} • ${weather.location}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.water_drop_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${weather.humidity}% kelembapan',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Angin ${weather.windSpeed.toStringAsFixed(1)} km/jam',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  weather.isLive ? 'API BMKG Realtime' : 'Data BMKG Terkini',
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Peluang Tani Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Peluang Tani',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                  },
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F623F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tanaman yang cocok ditanam bulan ini',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),

            // Crop Horizontal List
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _cropCard('Wortel', 'Potensi panen tinggi', 'Rp8.000/kg', Colors.orange.shade100, Icons.grass),
                  const SizedBox(width: 12),
                  _cropCard('Cabai', 'Potensi panen tinggi', 'Rp35.000/kg', Colors.red.shade100, Icons.local_fire_department),
                  const SizedBox(width: 12),
                  _cropCard('Tomat', 'Kecocokan 95%', 'Rp12.000/kg', Colors.red.shade50, Icons.eco),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Teman Bertanimu Section
            const Text(
              'Teman Bertanimu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),

            // Feature Grid (6 items)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _featureItem(
                  context,
                  title: 'Peluang Tani',
                  icon: Icons.eco_outlined,
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF0F623F),
                  onTap: () {
                    if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                  },
                ),
                _featureItem(
                  context,
                  title: 'TaniCare',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFFE0F2FE),
                  iconColor: Colors.blue.shade700,
                  onTap: () {
                    if (widget.onNavigateToTab != null) widget.onNavigateToTab!(2);
                  },
                ),
                _featureItem(
                  context,
                  title: 'Ruang Tani',
                  icon: Icons.forum_outlined,
                  color: const Color(0xFFFEF3C7),
                  iconColor: Colors.amber.shade800,
                  onTap: () {
                    if (widget.onNavigateToTab != null) widget.onNavigateToTab!(3);
                  },
                ),
                _featureItem(
                  context,
                  title: 'Uang Tani',
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFDCFCE7),
                  iconColor: Colors.green.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UangTaniScreen()),
                    );
                  },
                ),
                _featureItem(
                  context,
                  title: 'Catatan Tani',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFFF3E8FF),
                  iconColor: Colors.purple.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatatanAktivitasScreen()),
                    );
                  },
                ),
                _featureItem(
                  context,
                  title: 'Pasar Tani',
                  icon: Icons.storefront_outlined,
                  color: const Color(0xFFFFE4E6),
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PasarTaniScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weather Alert Banner with Real BMKG Advice
            FutureBuilder<BmkgWeatherData>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                final weather = snapshot.data ?? BmkgWeatherData.fallback(location: _selectedLocation);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_sync, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekomendasi Pertanian BMKG (${weather.condition})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather.recommendation,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E40AF),
                                height: 1.3,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _cropCard(String title, String status, String price, Color bgColor, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0F623F), size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          Text(
            status,
            style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F623F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

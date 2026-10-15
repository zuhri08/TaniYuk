import 'package:flutter/material.dart';
import '../services/bmkg_weather_service.dart';

class PeluangScreen extends StatefulWidget {
  const PeluangScreen({super.key});

  @override
  State<PeluangScreen> createState() => _PeluangScreenState();
}

class _PeluangScreenState extends State<PeluangScreen> {
  int _selectedSubTab = 0; // 0: Rekomendasi, 1: Harga Pasar, 2: Cuaca
  String _selectedCrop = 'Pilih tanaman';
  String _selectedLocation = 'Bandung, Jawa Barat';
  String _selectedSoil = 'Lempung';
  bool _isAnalyzed = false;

  final List<String> _subTabs = ['Rekomendasi', 'Harga Pasar', 'Cuaca'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F623F),
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
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F623F) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F623F) : Colors.grey.shade300,
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

            // Card Informasi Lahan
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                    children: const [
                      Text(
                        'Informasi Lahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Icon(Icons.edit_location_alt_outlined, color: Color(0xFF0F623F), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Jenis Tanaman
                  _buildDropdownField(
                    label: 'Jenis Tanaman',
                    value: _selectedCrop,
                    items: ['Pilih tanaman', 'Tomat', 'Cabai', 'Wortel', 'Selada', 'Jagung'],
                    onChanged: (val) => setState(() => _selectedCrop = val!),
                  ),
                  const SizedBox(height: 12),

                  // Lokasi Lahan
                  _buildDropdownField(
                    label: 'Lokasi Lahan',
                    value: _selectedLocation,
                    items: ['Bandung, Jawa Barat', 'Lembang, Jawa Barat', 'Garut, Jawa Barat'],
                    onChanged: (val) => setState(() => _selectedLocation = val!),
                  ),
                  const SizedBox(height: 12),

                  // Luas Lahan & Jenis Tanah
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Luas Lahan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text('1.000 m²', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Jenis Tanah',
                          value: _selectedSoil,
                          items: ['Lempung', 'Liat', 'Berpasir', 'Humus'],
                          onChanged: (val) => setState(() => _selectedSoil = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tanggal Tanam
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal Tanam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('15 Oktober 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Button Analisis
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAnalyzed = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isAnalyzed ? 'Analisis lahan selesai!' : ''),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F623F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Analisis Sekarang',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rekomendasi Tanaman Section
            if (_selectedSubTab == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Rekomendasi Tanaman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'Untuk lahanmu',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _recommendationCard(
                name: 'Tomat',
                matchRate: 'Kecocokan 95%',
                trend: '+12%',
                price: 'Rp12.000/kg',
                harvestDays: 'Panen 60-90 hari',
                iconBg: Colors.red.shade50,
                iconColor: Colors.red.shade700,
              ),
              const SizedBox(height: 12),
              _recommendationCard(
                name: 'Wortel',
                matchRate: 'Kecocokan 92%',
                trend: '+8%',
                price: 'Rp8.000/kg',
                harvestDays: 'Panen 60-90 hari',
                iconBg: Colors.orange.shade50,
                iconColor: Colors.orange.shade700,
              ),
              const SizedBox(height: 12),
              _recommendationCard(
                name: 'Selada',
                matchRate: 'Kecocokan 89%',
                trend: '+6%',
                price: 'Rp15.000/kg',
                harvestDays: 'Panen 30-40 hari',
                iconBg: Colors.green.shade50,
                iconColor: Colors.green.shade700,
              ),
            ] else if (_selectedSubTab == 1) ...[
              // Market Price View
              const Text(
                'Update Harga Pasar Pertanian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              _priceCard('Cabai Merah Keriting', 'Rp35.000/kg', '+5% dari kemarin', Colors.red),
              const SizedBox(height: 10),
              _priceCard('Tomat Segar', 'Rp12.000/kg', 'Stabil', Colors.green),
              const SizedBox(height: 10),
              _priceCard('Bawang Merah', 'Rp28.000/kg', '-2% dari kemarin', Colors.orange),
            ] else ...[
              // Weather View
              Text(
                'Prakiraan Cuaca BMKG Realtime - $_selectedLocation',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              FutureBuilder<BmkgWeatherData>(
                future: BmkgWeatherService.fetchLiveWeather(location: _selectedLocation),
                builder: (context, snapshot) {
                  final weather = snapshot.data ?? BmkgWeatherData.fallback(location: _selectedLocation);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _weatherRow('Hari Ini', weather.condition, '${weather.temperature.toStringAsFixed(1)}°C', Icons.wb_sunny_outlined),
                        const Divider(),
                        _weatherRow('Besok', 'Cerah Berawan', '${(weather.temperature - 1).toStringAsFixed(1)}°C', Icons.cloud_outlined),
                        const Divider(),
                        _weatherRow('Lusa', 'Hujan Ringan', '${(weather.temperature - 2).toStringAsFixed(1)}°C', Icons.grain),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
              onChanged: onChanged,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recommendationCard({
    required String name,
    required String matchRate,
    required String trend,
    required String price,
    required String harvestDays,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trend,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  matchRate,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F623F),
                      ),
                    ),
                    Text(
                      harvestDays,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(String title, String price, String info, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F623F))),
              Text(info, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherRow(String day, String cond, String temp, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 10),
              Text(day, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          Text(cond, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(temp, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

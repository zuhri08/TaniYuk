import 'package:flutter/material.dart';

class TipsTrikScreen extends StatefulWidget {
  const TipsTrikScreen({super.key});

  @override
  State<TipsTrikScreen> createState() => _TipsTrikScreenState();
}

class _TipsTrikScreenState extends State<TipsTrikScreen> {
  int _selectedChip = 0;
  final List<String> _categories = ['Semua', 'Budidaya', 'Perawatan', 'Hama'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Tips & Trik',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ilmu baru untuk hasil panen lebih baik',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Temukan tips bertani...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF0F623F)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Categories Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedChip == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F623F),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: Colors.grey.shade200),
                      onSelected: (selected) {
                        setState(() {
                          _selectedChip = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Panduan Pilihan Featured Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F623F), Color(0xFF166534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PANDUAN PILIHAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rahasia Tanaman Subur\ndan Panen Melimpah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.menu_book_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Tim TaniYuk • 5 menit baca',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Artikel Terbaru Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Artikel Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Lihat semua',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0F623F), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _articleCard(
              title: 'Cara Membuat Pupuk Organik Sendiri',
              readTime: 'Hama & Penyakit • 5 menit baca',
              color: Colors.green.shade50,
              icon: Icons.eco_outlined,
            ),
            const SizedBox(height: 12),

            _articleCard(
              title: 'Kenali Hama Sebelum Menyerang',
              readTime: 'Hama & Penyakit • 4 menit baca',
              color: Colors.amber.shade50,
              icon: Icons.bug_report_outlined,
            ),
            const SizedBox(height: 12),

            _articleCard(
              title: 'Teknik Penyiraman yang Tepat',
              readTime: 'Budidaya • 3 menit baca',
              color: Colors.blue.shade50,
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _articleCard({
    required String title,
    required String readTime,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0F623F), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  readTime,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border_rounded, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}

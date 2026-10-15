import 'package:flutter/material.dart';

class KontenTersimpanScreen extends StatelessWidget {
  const KontenTersimpanScreen({super.key});

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
        title: const Text(
          'Konten Tersimpan',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _savedCard(
            title: 'Cara Membuat Pupuk Organik Sendiri',
            category: 'Tips & Artikel',
            savedDate: 'Disimpan 3 hari yang lalu',
          ),
          const SizedBox(height: 12),
          _savedCard(
            title: 'Diskusi: Mencegah Hama Ulat saat Musim Hujan',
            category: 'Ruang Tani',
            savedDate: 'Disimpan 1 minggu yang lalu',
          ),
          const SizedBox(height: 12),
          _savedCard(
            title: 'Rekomendasi Budidaya Cabai Keriting',
            category: 'Peluang Tani',
            savedDate: 'Disimpan 2 minggu yang lalu',
          ),
        ],
      ),
    );
  }

  Widget _savedCard({
    required String title,
    required String category,
    required String savedDate,
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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_rounded, color: Color(0xFF0F623F), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0F623F), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(savedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

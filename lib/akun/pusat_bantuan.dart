import 'package:flutter/material.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

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
          'Pusat Bantuan',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pertanyaan Populer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),

            _faqExpansionTile(
              question: 'Bagaimana cara AI mendiagnosis penyakit tanaman?',
              answer: 'AI TaniYuk menganalisis pola visual pada foto daun atau bagian tanaman yang bermasalah dan mencocokkannya dengan ribuan data penyakit pertanian.',
            ),
            _faqExpansionTile(
              question: 'Apakah data cuaca diperbarui secara realtime?',
              answer: 'Ya, TaniYuk terhubung dengan stasiun meteorologi lokal untuk memberikan estimasi dan peringatan cuaca yang akurat.',
            ),
            _faqExpansionTile(
              question: 'Bagaimana cara menambahkan transaksi di Uang Tani?',
              answer: 'Buka menu Uang Tani di Beranda atau Akun, lalu tekan tombol "Catat Transaksi" di bagian bawah layar.',
            ),
            const SizedBox(height: 24),

            const Text(
              'Hubungi Kami',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),

            _contactTile(
              icon: Icons.chat,
              title: 'Layanan WhatsApp CS TaniYuk',
              subtitle: 'Respon cepat 08.00 - 17.00 WIB',
            ),
            const SizedBox(height: 10),
            _contactTile(
              icon: Icons.email_outlined,
              title: 'Email Dukungan',
              subtitle: 'bantuan@taniyuk.id',
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqExpansionTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            child: Icon(icon, color: const Color(0xFF0F623F), size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'identifikasi_tanaman_screen.dart';

class TaniCareScreen extends StatelessWidget {
  const TaniCareScreen({super.key});

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
              'TaniCare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Asisten pintar untuk tanaman sehat',
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
            // Top Header Banner Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F623F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Rawat tanamanmu dengan mudah',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F623F),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dari mengenali penyakit hingga tips perawatan, TaniCare siap membantu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Action List
            _actionCard(
              context,
              title: 'Kenali Penyakit Tanaman',
              subtitle: 'Foto tanamanmu, temukan solusinya',
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFFE0F2FE),
              iconColor: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IdentifikasiTanamanScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _actionCard(
              context,
              title: 'Tanya Tani',
              subtitle: 'Asisten pintar untuk masalah pertanian',
              icon: Icons.smart_toy_outlined,
              color: const Color(0xFFFEF3C7),
              iconColor: Colors.amber.shade800,
              onTap: () {
                _showTanyaTaniDialog(context);
              },
            ),
            const SizedBox(height: 12),

            _actionCard(
              context,
              title: 'Riwayat Pemindaian',
              subtitle: 'Lihat kembali hasil pemindaianmu',
              icon: Icons.history_rounded,
              color: const Color(0xFFF3E8FF),
              iconColor: Colors.purple.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IdentifikasiTanamanScreen()),
                );
              },
            ),
            const SizedBox(height: 28),

            // Prompt Suggestions Section
            const Text(
              'Coba pertanyaan ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _promptChip(context, 'Apa penyebab daun tomat menguning?'),
            _promptChip(context, 'Bagaimana cara mengatasi hama ulat?'),
            _promptChip(context, 'Kapan waktu terbaik memberi pupuk?'),
            _promptChip(context, 'Cara menjaga tanaman saat musim hujan?'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _promptChip(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        _showTanyaTaniDialog(context, initialQuery: text);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.north_east_rounded, size: 16, color: Color(0xFF0F623F)),
          ],
        ),
      ),
    );
  }

  void _showTanyaTaniDialog(BuildContext context, {String? initialQuery}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.smart_toy_outlined, color: Color(0xFF0F623F)),
                      SizedBox(width: 8),
                      Text(
                        'Tanya Tani AI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (initialQuery != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pertanyaan: "$initialQuery"',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F623F), fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Halo Pak Budi! Penyakit bercak daun atau hama ulat bisa ditangani dengan menjaga sanitasi lahan, pemangkasan daun terinfeksi, serta pemberian pestisida organik ramah lingkungan.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF374151)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ketik pertanyaan lainnya...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF0F623F)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

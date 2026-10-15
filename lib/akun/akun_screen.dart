import 'package:flutter/material.dart';
import 'kelola_profil.dart';
import 'data_lahan.dart';
import 'catatan_aktivitas.dart';
import 'konten_tersimpan.dart';
import 'notifikasi.dart';
import 'keamanan_akun.dart';
import 'pusat_bantuan.dart';
import '../awal/login_screen.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F623F),
        elevation: 0,
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Color(0xFF0F623F), size: 36),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Budi Santoso',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Petani • Bandung',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bergabung sejak Januari 2026',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 8),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('3', 'Lahan'),
                      Container(height: 24, width: 1, color: Colors.grey.shade300),
                      _statItem('12', 'Postingan'),
                      Container(height: 24, width: 1, color: Colors.grey.shade300),
                      _statItem('128', 'Pengikut'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Menu List Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _menuTile(
                    context,
                    title: 'Kelola Profil',
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KelolaProfilScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Data Lahan',
                    icon: Icons.landscape_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataLahanScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Catatan Aktivitas',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CatatanAktivitasScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Konten Tersimpan',
                    icon: Icons.bookmark_border_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KontenTersimpanScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Notifikasi',
                    icon: Icons.notifications_none_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Keamanan Akun',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KeamananAkunScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Pusat Bantuan',
                    icon: Icons.help_outline_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PusatBantuanScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    context,
                    title: 'Keluar',
                    icon: Icons.logout_rounded,
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F623F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF374151),
    Color iconColor = const Color(0xFF0F623F),
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}

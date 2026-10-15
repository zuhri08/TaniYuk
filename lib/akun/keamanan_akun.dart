import 'package:flutter/material.dart';

class KeamananAkunScreen extends StatefulWidget {
  const KeamananAkunScreen({super.key});

  @override
  State<KeamananAkunScreen> createState() => _KeamananAkunScreenState();
}

class _KeamananAkunScreenState extends State<KeamananAkunScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

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
          'Keamanan Akun',
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Color(0xFF0F623F)),
                  title: const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  value: _biometricEnabled,
                  activeTrackColor: const Color(0xFF0F623F),
                  secondary: const Icon(Icons.fingerprint, color: Color(0xFF0F623F)),
                  title: const Text('Masuk dengan Sidik Jari / Face ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onChanged: (val) {
                    setState(() {
                      _biometricEnabled = val;
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  value: _twoFactorEnabled,
                  activeTrackColor: const Color(0xFF0F623F),
                  secondary: const Icon(Icons.phonelink_lock, color: Color(0xFF0F623F)),
                  title: const Text('Verifikasi 2 Langkah (2FA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  onChanged: (val) {
                    setState(() {
                      _twoFactorEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

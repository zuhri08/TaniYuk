import 'package:flutter/material.dart';
import '../util/permission_helper.dart';

class NotifikasiItem {
  final String title;
  final String desc;
  final String time;
  final IconData icon;
  final Color color;
  bool isNew;

  NotifikasiItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.icon,
    required this.color,
    this.isNew = true,
  });
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _notificationPermissionGranted = true;

  final List<NotifikasiItem> _notifList = [
    NotifikasiItem(
      title: 'Peringatan Cuaca',
      desc: 'Prakiraan hujan deras sore ini di wilayah Bandung. Siapkan drainase lahanmu.',
      time: '10 menit lalu',
      icon: Icons.thunderstorm_outlined,
      color: Colors.blue,
      isNew: true,
    ),
    NotifikasiItem(
      title: 'Peluang Tanam Baru',
      desc: 'Harga tomat naik 12% di Pasar Bandung. Waktu yang bagus untuk panen!',
      time: '2 jam lalu',
      icon: Icons.trending_up_rounded,
      color: Colors.green,
      isNew: true,
    ),
    NotifikasiItem(
      title: 'Komentar Baru',
      desc: 'Pak Joko mengomentari postinganmu di Ruang Tani.',
      time: 'Yesterday',
      icon: Icons.chat_bubble_outline_rounded,
      color: Colors.orange,
      isNew: false,
    ),
  ];

  void _sendTestNotification() {
    PermissionHelper.requestNotificationPermission(
      context,
      onGranted: () {
        final newNotif = NotifikasiItem(
          title: '🔔 Notifikasi Langsung HP',
          desc: 'Sistem TaniYuk: Perizinan notifikasi aktif! Pengingat jadwal penyiraman lahan sore ini.',
          time: 'Baru saja',
          icon: Icons.notifications_active_rounded,
          color: const Color(0xFF0F623F),
          isNew: true,
        );

        setState(() {
          _notifList.insert(0, newNotif);
          _notificationPermissionGranted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F623F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: const [
                Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔔 Notifikasi TaniYuk Diterima!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      Text(
                        'Perizinan aktif • Pengingat penyiraman lahan sore ini',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF0F623F)),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              setState(() {
                for (var item in _notifList) {
                  item.isNew = false;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Permission status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF0F623F), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Status Perizinan Notifikasi HP',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Izin POST_NOTIFICATIONS Aktif di HP',
                            style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationPermissionGranted,
                      activeTrackColor: const Color(0xFF0F623F),
                      onChanged: (val) {
                        setState(() {
                          _notificationPermissionGranted = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Tes Kirim Notifikasi Langsung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F623F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Pemberitahuan Terbaru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),

          ..._notifList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _notifItem(
                  title: item.title,
                  desc: item.desc,
                  time: item.time,
                  icon: item.icon,
                  color: item.color,
                  isNew: item.isNew,
                ),
              )),
        ],
      ),
    );
  }

  Widget _notifItem({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required Color color,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? Colors.green.shade50.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNew ? const Color(0xFFA7F3D0) : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

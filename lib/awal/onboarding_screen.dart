import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Peluang Tanam\nTerbaik untukmu',
      description:
          'Temukan tanaman yang paling cocok untuk lahanmu. Rencanakan musim tanam dengan rekomendasi cuaca dan harga pasar.',
      icon: Icons.agriculture_rounded,
      iconBgColor: const Color(0xFFE8F5E9),
    ),
    OnboardingItem(
      title: 'Kenali Musuh\nTanaman dengan AI',
      description:
          'Kenali penyakit tanaman hanya dengan satu foto. Dapatkan solusi perawatan yang tepat agar tanamanmu tetap sehat.',
      icon: Icons.qr_code_scanner_rounded,
      iconBgColor: const Color(0xFFE0F2FE),
    ),
    OnboardingItem(
      title: 'Terhubung dengan\nPetani Lain',
      description:
          'Berbagi pengalaman, bertanya, dan belajar bersama komunitas petani. Karena tumbuh bersama selalu lebih mudah.',
      icon: Icons.groups_rounded,
      iconBgColor: const Color(0xFFFEF3C7),
    ),
    OnboardingItem(
      title: 'Kelola Keuangan\nPertanianmu',
      description:
          'Catat pemasukan dan pengeluaran dengan mudah. Pantau keuntungan setiap panen untuk usaha tani yang lebih terencana.',
      icon: Icons.account_balance_wallet_rounded,
      iconBgColor: const Color(0xFFDCFCE7),
    ),
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _goToLogin,
            child: const Text(
              'Lewati',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Circle Container
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 90,
                            color: const Color(0xFF0F623F),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF0F623F)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == _pages.length - 1) {
                      _goToLogin();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F623F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentIndex == _pages.length - 1
                        ? 'Mulai Sekarang'
                        : 'Lanjut',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

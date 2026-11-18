import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappCommerceService {
  /// Membuka obrolan WhatsApp dengan pesan pesanan terstruktur langsung ke HP Petani / Penjual
  static Future<bool> sendOrderToFarmerWhatsApp({
    required String farmerPhone,
    required String farmerName,
    required List<Map<String, dynamic>> orderItems,
    required double totalPrice,
    String deliveryAddress = 'Jl. Raya Ketintang No. 45, Surabaya',
  }) async {
    final cleanPhone = farmerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : (cleanPhone.isEmpty ? '6281234567890' : cleanPhone);

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Halo *$farmerName* (Petani TaniYuk), saya ingin memesan hasil pertanian:');
    buffer.writeln('');
    buffer.writeln('📦 *Rincian Pesanan:*');

    for (var item in orderItems) {
      final name = item['name'];
      final qty = item['qty'];
      final price = item['price'];
      final subtotal = (price is num) ? price * (qty is num ? qty : 1) : 0;
      buffer.writeln('• $name ($qty) = Rp ${subtotal.toInt()}');
    }

    buffer.writeln('');
    buffer.writeln('💰 *Total Pembayaran:* Rp ${totalPrice.toInt()}');
    buffer.writeln('📍 *Alamat Pengiriman:* $deliveryAddress');
    buffer.writeln('🚚 *Metode:* Kirim Langsung / Kurir Lokal');
    buffer.writeln('');
    buffer.writeln('Apakah stok masih tersedia? Terima kasih!');

    final String encodedText = Uri.encodeComponent(buffer.toString());
    final Uri waUri = Uri.parse('https://wa.me/$formattedPhone?text=$encodedText');

    try {
      if (await canLaunchUrl(waUri)) {
        return await launchUrl(waUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp launch note: $e');
    }

    return false;
  }
}

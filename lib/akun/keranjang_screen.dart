import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../services/order_service.dart';
import '../services/whatsapp_commerce_service.dart';
import '../util/formatters.dart';
import 'daftar_pesanan_screen.dart';

class KeranjangScreen extends StatelessWidget {
  const KeranjangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final entries = store.cart.entries
            .where((entry) => store.productById(entry.key) != null)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFFF4E1),
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${store.cartCount} item dari Pasar Tani',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          body: entries.isEmpty
              ? _emptyCart(context)
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final product = store.productById(entry.key)!;
                    final quantity = entry.value;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: product.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(product.icon, color: const Color(0xFF132E25), size: 30),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${formatRupiah(product.price)} / ${product.unit}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _quantityButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () => store.setCartQuantity(product.id, quantity - 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _quantityButton(
                                      icon: Icons.add_rounded,
                                      onTap: () => store.setCartQuantity(product.id, quantity + 1),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatRupiah(product.price * quantity),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF132E25),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                            onPressed: () => store.removeFromCart(product.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          bottomNavigationBar: entries.isEmpty ? null : _checkoutBar(context, store),
        );
      },
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF89D7B7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_basket_outlined, size: 44, color: Color(0xFF132E25)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Yuk cari hasil panen segar dan kebutuhan tani di Pasar Tani.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Kembali ke Pasar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132E25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF132E25)),
      ),
    );
  }

  Widget _checkoutBar(BuildContext context, AppStore store) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  formatRupiah(store.cartTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E25),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmCheckout(context, store),
                      icon: const Icon(Icons.payments_outlined, size: 18),
                      label: const Text(
                        'Checkout Aplikasi',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF132E25),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final itemsList = <Map<String, dynamic>>[];
                        store.cart.forEach((pid, qty) {
                          final p = store.productById(pid);
                          if (p != null) {
                            itemsList.add({
                              'name': p.name,
                              'qty': qty,
                              'price': p.price,
                            });
                          }
                        });

                        final total = store.checkout();

                        WhatsappCommerceService.sendOrderToFarmerWhatsApp(
                          farmerPhone: '081234567890',
                          farmerName: 'Pak Joko (Petani TaniYuk)',
                          orderItems: itemsList,
                          totalPrice: total,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('💬 Membuka WhatsApp! Rincian pesanan keranjang berhasil dikirim ke HP Petani.'),
                            backgroundColor: Color(0xFF075E54),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text(
                        'Checkout via WA',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCheckout(BuildContext context, AppStore store) {
    final total = store.cartTotal;
    final addressController = TextEditingController(text: 'Jl. Raya Ketintang No. 45, Surabaya');
    String selectedCourier = 'J&T Express Reguler';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      const Text(
                        'Informasi Pengiriman Pesanan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Alamat Tujuan Pengiriman:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: 'Ketik alamat lengkap pengiriman...',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Pilih Ekspedisi / Kurir Pengiriman:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['J&T Express Reguler', 'JNE Reguler', 'GrabExpress Instan', 'Kurir Tani'].map((courier) {
                      final isSelected = selectedCourier == courier;
                      return ChoiceChip(
                        label: Text(courier, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF132E25),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setModalState(() => selectedCourier = courier),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran (COD):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(formatRupiah(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132E25))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final address = addressController.text.trim();
                        if (address.isEmpty) return;

                        final cartProducts = store.cart.entries
                            .map((e) => store.productById(e.key))
                            .whereType<ProductModel>()
                            .toList();

                        final cartQuantities = Map<String, int>.from(store.cart);

                        final newOrder = OrderService.createOrder(
                          products: cartProducts,
                          quantities: cartQuantities,
                          totalPrice: total,
                          shippingAddress: address,
                          courierName: selectedCourier,
                        );

                        store.checkout();
                        Navigator.pop(dialogContext);

                        _showSuccess(context, newOrder);
                      },
                      icon: const Icon(Icons.local_shipping_rounded, size: 18),
                      label: const Text('Buat Pesanan & Kirim Paket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF132E25),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccess(BuildContext context, OrderItem order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF89D7B7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 36, color: Color(0xFF132E25)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Pesanan Berhasil Dibuat!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 6),
            Text(
              'Paket senilai ${formatRupiah(order.totalPrice)} sedang disiapkan oleh penjual dan akan dikirim via ${order.courierName}.\nNomor Resi: ${order.trackingNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DaftarPesananScreen()),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Lacak Status Pengiriman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF132E25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

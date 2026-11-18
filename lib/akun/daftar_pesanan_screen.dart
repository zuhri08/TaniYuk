import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../util/formatters.dart';

class DaftarPesananScreen extends StatefulWidget {
  const DaftarPesananScreen({super.key});

  @override
  State<DaftarPesananScreen> createState() => _DaftarPesananScreenState();
}

class _DaftarPesananScreenState extends State<DaftarPesananScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Semua', 'Perlu Diproses', 'Dikirim', 'Selesai'];

  void _showTrackingModal(OrderItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                  Expanded(
                    child: Text(
                      '🚚 Lacak Pengiriman: ${order.trackingNumber}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Kurir: ${order.courierName} • Alamat Tujuan: ${order.shippingAddress}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const Divider(height: 20),

              // Timeline Status Pengiriman
              _timelineStep(
                title: 'Pesanan Berhasil Dibuat',
                subtitle: 'Pembeli telah melakukan pemesanan dan pembayaran.',
                time: '${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')} WIB',
                isCompleted: true,
              ),
              _timelineStep(
                title: 'Penjual Mengemas Barang & Siap Dikirim',
                subtitle: 'Barang dikemas rapi dan diserahkan ke gerai kurir ${order.courierName}.',
                time: '${order.orderDate.add(const Duration(minutes: 45)).hour}:${order.orderDate.add(const Duration(minutes: 45)).minute.toString().padLeft(2, '0')} WIB',
                isCompleted: order.status == 'Dikirim' || order.status == 'Selesai',
              ),
              _timelineStep(
                title: 'Paket Dalam Perjalanan Kurir',
                subtitle: 'Kurir sedang mengantarkan paket menuju alamat pengiriman.',
                time: '${order.orderDate.add(const Duration(hours: 2)).hour}:${order.orderDate.add(const Duration(hours: 2)).minute.toString().padLeft(2, '0')} WIB',
                isCompleted: order.status == 'Dikirim' || order.status == 'Selesai',
              ),
              _timelineStep(
                title: 'Paket Tiba & Diterima Pembeli',
                subtitle: 'Paket telah sampai di alamat tujuan dan diterima oleh Pembeli.',
                time: order.status == 'Selesai' ? 'Selesai' : 'Estimasi hari ini',
                isCompleted: order.status == 'Selesai',
                isLast: true,
              ),

              const SizedBox(height: 16),
              if (order.status == 'Perlu Diproses')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        OrderService.updateOrderStatus(order.orderId, 'Dikirim');
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('📦 Pesanan ${order.orderId} diserahkan ke kurir dan status diubah menjadi DIKIRIM!')),
                      );
                    },
                    icon: const Icon(Icons.local_shipping_rounded),
                    label: const Text('Kirim Paket (Serahkan ke Kurir)', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132E25),
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else if (order.status == 'Dikirim')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        OrderService.updateOrderStatus(order.orderId, 'Selesai');
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🎉 Pesanan ${order.orderId} dikonfirmasi DITERIMA pembeli!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Konfirmasi Pesanan Diterima Pembeli', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF132E25) : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: isCompleted ? const Color(0xFF132E25) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isCompleted ? const Color(0xFF1F2937) : Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: isCompleted ? const Color(0xFF0369A1) : Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = OrderService.userOrders;
    final currentTab = _tabs[_selectedTab];

    final filteredOrders = allOrders.where((o) {
      if (currentTab == 'Semua') return true;
      return o.status == currentTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF132E25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pesanan Saya & Status Pengiriman',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (idx) {
                final isSelected = _selectedTab == idx;
                return ChoiceChip(
                  label: Text(_tabs[idx]),
                  selected: isSelected,
                  selectedColor: const Color(0xFF132E25),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedTab = idx),
                );
              }),
            ),
          ),

          // Order List
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pesanan pada status ini.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    Color statusColor;
    IconData statusIcon;

    if (order.status == 'Selesai') {
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (order.status == 'Dikirim') {
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.local_shipping_outlined;
    } else {
      statusColor = Colors.amber.shade800;
      statusIcon = Icons.inventory_2_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF132E25)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.status,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Products
            ...order.products.map((p) {
              final qty = order.quantities[p.id] ?? 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: p.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(p.icon, color: const Color(0xFF132E25), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${formatRupiah(p.price)} x $qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      formatRupiah(p.price * qty),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF132E25)),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF2C5E4A)),
                      const SizedBox(width: 6),
                      Text('Kurir: ${order.courierName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('Resi: ${order.trackingNumber}', style: const TextStyle(fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Alamat Kirim: ${order.shippingAddress}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      formatRupiah(order.totalPrice),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showTrackingModal(order),
                      icon: const Icon(Icons.alt_route_rounded, size: 14),
                      label: const Text('Lacak Resi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF132E25),
                        side: const BorderSide(color: Color(0xFF132E25)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (order.status == 'Dikirim') ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            OrderService.updateOrderStatus(order.orderId, 'Selesai');
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Terima kasih! Pesanan telah dikonfirmasi diterima.')),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('Diterima'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/app_store.dart';

class OrderItem {
  final String orderId;
  final String trackingNumber;
  final List<ProductModel> products;
  final Map<String, int> quantities;
  final double totalPrice;
  final String shippingAddress;
  final String courierName;
  final DateTime orderDate;
  String status;

  OrderItem({
    required this.orderId,
    required this.trackingNumber,
    required this.products,
    required this.quantities,
    required this.totalPrice,
    required this.shippingAddress,
    required this.courierName,
    required this.orderDate,
    required this.status,
  });
}

class OrderService {
  static final List<OrderItem> _userOrders = [
    OrderItem(
      orderId: 'TN-20261117-001',
      trackingNumber: 'RESI-JT-991820192',
      products: [
        const ProductModel(
          id: 'p-tomat',
          name: 'Tomat Segar',
          seller: 'Pak Joko • Bandung',
          unit: 'kg',
          price: 12000,
          category: 'Hasil Panen',
          icon: Icons.eco_outlined,
          backgroundColor: Color(0xFFFEF2F2),
          rating: 4.8,
        ),
      ],
      quantities: {'p-tomat': 5},
      totalPrice: 60000.0,
      shippingAddress: 'Jl. Raya Ketintang No. 45, Surabaya',
      courierName: 'J&T Express Reguler',
      orderDate: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Dikirim',
    ),
  ];

  static List<OrderItem> get userOrders => List.unmodifiable(_userOrders);

  static OrderItem createOrder({
    required List<ProductModel> products,
    required Map<String, int> quantities,
    required double totalPrice,
    required String shippingAddress,
    required String courierName,
  }) {
    final now = DateTime.now();
    final newOrder = OrderItem(
      orderId: 'TN-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_userOrders.length + 101}',
      trackingNumber: 'RESI-${courierName.contains('J&T') ? 'JT' : 'JNE'}-${now.millisecondsSinceEpoch ~/ 1000}',
      products: products,
      quantities: quantities,
      totalPrice: totalPrice,
      shippingAddress: shippingAddress,
      courierName: courierName,
      orderDate: now,
      status: 'Perlu Diproses',
    );

    _userOrders.insert(0, newOrder);
    return newOrder;
  }

  static void updateOrderStatus(String orderId, String newStatus) {
    final idx = _userOrders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _userOrders[idx].status = newStatus;
    }
  }
}

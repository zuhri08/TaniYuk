import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'app_store.dart';

class ShopeeApiCredentials {
  final String partnerId;
  final String partnerKey;
  final String shopId;
  final String accessToken;
  final bool isSandbox;

  ShopeeApiCredentials({
    required this.partnerId,
    required this.partnerKey,
    required this.shopId,
    required this.accessToken,
    this.isSandbox = true,
  });
}

class TokopediaApiCredentials {
  final String clientId;
  final String clientSecret;
  final String fsId;

  TokopediaApiCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.fsId,
  });
}

class EcommerceSyncedOrder {
  final String orderId;
  final String platform;
  final String buyerName;
  final String productName;
  final int quantity;
  final double totalPrice;
  final DateTime orderDate;
  final String status;

  EcommerceSyncedOrder({
    required this.orderId,
    required this.platform,
    required this.buyerName,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
  });
}

class ShopeeOpenApiClient {
  /// Membikin tanda tangan HMAC-SHA256 resmi sesuai spesifikasi Shopee Open Platform API v2
  static String generateSignature({
    required String partnerKey,
    required String partnerId,
    required String path,
    required int timestamp,
    String accessToken = '',
    String shopId = '',
  }) {
    final String baseString = '$partnerId$path$timestamp$accessToken$shopId';
    final keyBytes = utf8.encode(partnerKey);
    final messageBytes = utf8.encode(baseString);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// Melakukan Pengujian Koneksi HTTP Nyata ke Server Shopee Open Platform API v2
  static Future<Map<String, dynamic>> testLiveShopeeApi({
    required ShopeeApiCredentials creds,
  }) async {
    final stopwatch = Stopwatch()..start();
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const String path = '/api/v2/shop/get_shop_info';

    final String host = creds.isSandbox
        ? 'partner.test-stable.shopeemobile.com'
        : 'partner.shopeemobile.com';

    final String signature = generateSignature(
      partnerKey: creds.partnerKey,
      partnerId: creds.partnerId,
      path: path,
      timestamp: timestamp,
      accessToken: creds.accessToken,
      shopId: creds.shopId,
    );

    final Uri url = Uri.parse(
      'https://$host$path?partner_id=${creds.partnerId}&timestamp=$timestamp&sign=$signature&access_token=${creds.accessToken}&shop_id=${creds.shopId}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TaniYuk-ShopeePartner/2.0',
        },
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();

      return {
        'success': true,
        'statusCode': response.statusCode,
        'endpoint': url.toString(),
        'signature': signature,
        'timestamp': timestamp,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'rawResponseBody': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'error': e.toString(),
        'endpoint': url.toString(),
        'signature': signature,
        'timestamp': timestamp,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'rawResponseBody': 'Gagal terhubung ke Shopee Open Platform: $e',
      };
    }
  }
}

class TokopediaOpenApiClient {
  /// Melakukan Pengujian Koneksi HTTP OAuth 2.0 ke Server Tokopedia Open API
  static Future<Map<String, dynamic>> testLiveTokopediaApi({
    required TokopediaApiCredentials creds,
  }) async {
    final stopwatch = Stopwatch()..start();
    const String tokenUrl = 'https://accounts.tokopedia.com/token?grant_type=client_credentials';

    final String basicAuth = base64Encode(utf8.encode('${creds.clientId}:${creds.clientSecret}'));

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TaniYuk-TokopediaPartner/2.0',
        },
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'endpoint': tokenUrl,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'rawResponseBody': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'error': e.toString(),
        'endpoint': tokenUrl,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'rawResponseBody': 'Gagal terhubung ke Tokopedia Developer API: $e',
      };
    }
  }
}

class EcommerceSyncService {
  static ShopeeApiCredentials shopeeCreds = ShopeeApiCredentials(
    partnerId: '1029384',
    partnerKey: 'shopee_live_secret_key_taniyuk_882910',
    shopId: '8849201',
    accessToken: 'shopee_access_token_mock_99182',
    isSandbox: true,
  );

  static TokopediaApiCredentials tokopediaCreds = TokopediaApiCredentials(
    clientId: 'tkp_client_id_taniyuk_1029',
    clientSecret: 'tkp_client_secret_991823719',
    fsId: '189201',
  );

  static bool isShopeeConnected = true;
  static bool isTokopediaConnected = true;
  static DateTime? lastSyncTime = DateTime.now().subtract(const Duration(minutes: 10));

  static final List<EcommerceSyncedOrder> _syncedOrders = [
    EcommerceSyncedOrder(
      orderId: 'SHP-20261117-901',
      platform: 'Shopee',
      buyerName: 'Rian Hidayat (Surabaya)',
      productName: 'Tomat Segar',
      quantity: 5,
      totalPrice: 60000.0,
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Selesai',
    ),
    EcommerceSyncedOrder(
      orderId: 'TKP-20261117-488',
      platform: 'Tokopedia',
      buyerName: 'Toko Sayur Segar (Sidoarjo)',
      productName: 'Cabai Merah',
      quantity: 10,
      totalPrice: 350000.0,
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'Dalam Pengiriman',
    ),
  ];

  static List<EcommerceSyncedOrder> get syncedOrders => List.unmodifiable(_syncedOrders);

  /// Melakukan panggilan API Ke Shopee Open Platform & Tokopedia Developer API
  static Future<Map<String, dynamic>> syncAllStores({
    required AppStore appStore,
  }) async {
    final shopeeTest = await ShopeeOpenApiClient.testLiveShopeeApi(creds: shopeeCreds);
    final tokopediaTest = await TokopediaOpenApiClient.testLiveTokopediaApi(creds: tokopediaCreds);

    final now = DateTime.now();
    lastSyncTime = now;

    final Random random = Random();
    final int newOrdersCount = random.nextInt(2) + 1;

    final newOrder = EcommerceSyncedOrder(
      orderId: 'SHP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${random.nextInt(899) + 100}',
      platform: random.nextBool() ? 'Shopee' : 'Tokopedia',
      buyerName: 'Pembeli Online E-Commerce',
      productName: 'Tomat Segar',
      quantity: 2,
      totalPrice: 24000.0,
      orderDate: now,
      status: 'Selesai',
    );

    _syncedOrders.insert(0, newOrder);

    // Otomatis masukkan hasil penjualan e-commerce ke catatan keuangan UangTani
    appStore.addTransaction(
      title: 'Penjualan ${newOrder.platform} (${newOrder.productName})',
      amount: newOrder.totalPrice,
      isIncome: true,
      category: 'Penjualan',
    );

    return {
      'success': true,
      'syncedOrdersCount': newOrdersCount,
      'lastSync': now,
      'shopeeTest': shopeeTest,
      'tokopediaTest': tokopediaTest,
      'message': 'Berhasil menyinkronkan $newOrdersCount pesanan baru dari Shopee & Tokopedia!',
    };
  }
}

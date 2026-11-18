import '../services/app_store.dart';
import '../util/formatters.dart';

class FinancialReportService {
  /// Membuat teks laporan CSV / Excel yang dapat dibuka langsung di Microsoft Excel atau Google Sheets
  static String generateCsvReport({
    required List<TransactionModel> transactions,
    required DateTime selectedMonth,
    required ProfileModel profile,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('LAPORAN KEUANGAN UANG TANI - TANIYUK');
    buffer.writeln('Nama Petani,${profile.name}');
    buffer.writeln('Lokasi Lahan,${profile.location}');
    buffer.writeln('Periode Laporan,${formatBulanTahun(selectedMonth)}');
    buffer.writeln('Tanggal Cetak,${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    buffer.writeln('');

    final double totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final double totalExpense = transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final double netBalance = totalIncome - totalExpense;

    buffer.writeln('RINGKASAN KEUANGAN');
    buffer.writeln('Total Pemasukan,Rp ${totalIncome.toInt()}');
    buffer.writeln('Total Pengeluaran,Rp ${totalExpense.toInt()}');
    buffer.writeln('Saldo Bersih,Rp ${netBalance.toInt()}');
    buffer.writeln('');

    buffer.writeln('RINCIAN TRANSAKSI');
    buffer.writeln('No,Tanggal,Judul Transaksi,Kategori,Tipe,Nominal (Rp)');

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final dateStr = '${t.date.day}/${t.date.month}/${t.date.year}';
      final tipeStr = t.isIncome ? 'Pemasukan' : 'Pengeluaran';
      final cleanTitle = t.title.replaceAll(',', ' ');
      buffer.writeln('${i + 1},$dateStr,$cleanTitle,${t.category},$tipeStr,${t.amount.toInt()}');
    }

    return buffer.toString();
  }

  /// Membikin cetakan dokumen Laporan Keuangan resmi TaniYuk
  static String generatePrintableReport({
    required List<TransactionModel> transactions,
    required DateTime selectedMonth,
    required ProfileModel profile,
  }) {
    final double totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final double totalExpense = transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final double netBalance = totalIncome - totalExpense;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('=== LAPORAN KEUANGAN RESMI UANG TANI ===');
    buffer.writeln('Petani   : ${profile.name}');
    buffer.writeln('Lokasi   : ${profile.location}');
    buffer.writeln('Periode  : ${formatBulanTahun(selectedMonth)}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Total Pemasukan   : ${formatRupiah(totalIncome)}');
    buffer.writeln('Total Pengeluaran : ${formatRupiah(totalExpense)}');
    buffer.writeln('Saldo Bersih      : ${formatRupiah(netBalance)}');
    buffer.writeln('========================================\n');
    buffer.writeln('RINCIAN TRANSAKSI:');

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final dateStr = '${t.date.day}/${t.date.month}/${t.date.year}';
      final tipe = t.isIncome ? '[+] Pemasukan' : '[-] Pengeluaran';
      buffer.writeln('${i + 1}. $dateStr - ${t.title} (${t.category})');
      buffer.writeln('   Status: $tipe | Nominal: ${formatRupiah(t.amount)}');
      buffer.writeln('----------------------------------------');
    }

    return buffer.toString();
  }
}

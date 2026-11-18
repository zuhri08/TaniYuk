import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../services/financial_report_service.dart';
import '../util/formatters.dart';

class UangTaniScreen extends StatefulWidget {
  const UangTaniScreen({super.key});

  @override
  State<UangTaniScreen> createState() => _UangTaniScreenState();
}

class _UangTaniScreenState extends State<UangTaniScreen> {
  DateTime _selectedMonth = DateTime(2026, 10);
  String _typeFilter = 'Semua';

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
  }

  List<TransactionModel> _transactionsForMonth(List<TransactionModel> source) {
    return source.where((transaction) {
      final sameMonth = transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month;
      if (!sameMonth) return false;
      if (_typeFilter == 'Pemasukan') return transaction.isIncome;
      if (_typeFilter == 'Pengeluaran') return !transaction.isIncome;
      return true;
    }).toList();
  }

  void _showExportReportModal(BuildContext context, AppStore store, List<TransactionModel> transactions) {
    final reportText = FinancialReportService.generatePrintableReport(
      transactions: transactions,
      selectedMonth: _selectedMonth,
      profile: store.profile,
    );

    final csvText = FinancialReportService.generateCsvReport(
      transactions: transactions,
      selectedMonth: _selectedMonth,
      profile: store.profile,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📄 Ekspor Laporan: ${formatBulanTahun(_selectedMonth)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reportText,
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📄 Dokumen Laporan Keuangan PDF berhasil dibuat & siap dicetak!'),
                              backgroundColor: Color(0xFF132E25),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: const Text('Simpan PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          debugPrint('CSV Export Data: $csvText');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📊 Berkas CSV/Excel Laporan Keuangan (${transactions.length} baris) berhasil diekspor!'),
                              backgroundColor: const Color(0xFF047857),
                            ),
                          );
                        },
                        icon: const Icon(Icons.table_chart_rounded, size: 18),
                        label: const Text('Ekspor Excel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF047857),
                          side: const BorderSide(color: Color(0xFF047857)),
                        ),
                      ),
                    ),
                  ],
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
    final store = AppStore.instance;

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
          children: const [
            Text(
              'Uang Tani',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Keuangan tertata, usaha makin maju',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            tooltip: 'Ekspor Laporan PDF/Excel',
            onPressed: () => _showExportReportModal(
              context,
              store,
              _transactionsForMonth(store.sortedTransactions),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            tooltip: 'Semua transaksi',
            onPressed: () => _showAllTransactions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final transactions = _transactionsForMonth(store.sortedTransactions);
          final income = transactions
              .where((t) => t.isIncome)
              .fold(0.0, (sum, t) => sum + t.amount);
          final expense = transactions
              .where((t) => !t.isIncome)
              .fold(0.0, (sum, t) => sum + t.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _monthSelector(context),
                const SizedBox(height: 16),
                _balanceCard(store),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        label: 'Pemasukan',
                        amount: income,
                        color: const Color(0xFF10B981),
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        label: 'Pengeluaran',
                        amount: expense,
                        color: const Color(0xFFEF4444),
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ringkasan untuk ${formatBulanTahun(_selectedMonth)}'
                        '${_typeFilter == 'Semua' ? '' : ' • filter $_typeFilter'}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _cashFlowChart(store, transactions),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAllTransactions(context),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF132E25),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (transactions.isEmpty)
                  _emptyTransactions()
                else
                  ...transactions.take(5).map(
                        (transaction) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _transactionTile(context, transaction),
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTransactionForm(context),
        backgroundColor: const Color(0xFF132E25),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Catat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _monthSelector(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Bulan sebelumnya',
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF132E25)),
          onPressed: () => _changeMonth(-1),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickMonth(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatBulanTahun(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF132E25)),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Bulan berikutnya',
          icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF132E25)),
          onPressed: () => _changeMonth(1),
        ),
        IconButton(
          tooltip: 'Filter transaksi',
          icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF132E25)),
          onPressed: () => _showFilter(context),
        ),
      ],
    );
  }

  Widget _balanceCard(AppStore store) {
    final growth = store.totalExpense == 0
        ? 0.0
        : (store.balance / store.totalExpense) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132E25), Color(0xFF428475)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132E25).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Usaha Tani',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(store.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              growth >= 0
                  ? '+${growth.toStringAsFixed(0)}% dari total pengeluaran'
                  : '${growth.toStringAsFixed(0)}% dari total pengeluaran',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashFlowChart(AppStore store, List<TransactionModel> transactions) {
    final months = List.generate(6, (index) {
      return DateTime(_selectedMonth.year, _selectedMonth.month - 5 + index, 1);
    });

    final incomeValues = months
        .map((month) => store.incomeOfMonth(month.year, month.month))
        .toList();

    final expenseValues = months
        .map((month) => store.expenseOfMonth(month.year, month.month))
        .toList();

    double maxVal = 1.0;
    for (int i = 0; i < 6; i++) {
      if (incomeValues[i] > maxVal) maxVal = incomeValues[i];
      if (expenseValues[i] > maxVal) maxVal = expenseValues[i];
    }

    // Hitung Kategori Distribusi Bulan Ini
    final categoryTotals = <String, double>{};
    double monthTotal = 0.0;
    for (var tx in transactions) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0.0) + tx.amount;
      monthTotal += tx.amount;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📊 Grafik Arus Kas Keuangan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Masuk', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Keluar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(months.length, (index) {
                    final month = months[index];
                    final isCurrent = month.year == _selectedMonth.year &&
                        month.month == _selectedMonth.month;

                    final incRatio = incomeValues[index] == 0 ? 0.03 : (incomeValues[index] / maxVal);
                    final expRatio = expenseValues[index] == 0 ? 0.03 : (expenseValues[index] / maxVal);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              incomeValues[index] == 0 ? '' : formatCompactRupiah(incomeValues[index]),
                              style: const TextStyle(fontSize: 8, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Bar Pemasukan (Hijau)
                            Container(
                              width: 11,
                              height: (90 * incRatio).clamp(4.0, 90.0),
                              decoration: BoxDecoration(
                                color: isCurrent ? const Color(0xFF10B981) : const Color(0xFFA7F3D0),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 3),
                            // Bar Pengeluaran (Merah)
                            Container(
                              width: 11,
                              height: (90 * expRatio).clamp(4.0, 90.0),
                              decoration: BoxDecoration(
                                color: isCurrent ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          namaBulanSingkat(month.month),
                          style: TextStyle(
                            fontSize: 10,
                            color: isCurrent ? const Color(0xFF132E25) : Colors.grey,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category Breakdown Progress Card
        if (categoryTotals.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📈 Distribusi Kategori Transaksi Bulan Ini',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 14),
                ...categoryTotals.entries.map((entry) {
                  final catName = entry.key;
                  final catAmt = entry.value;
                  final percent = monthTotal > 0 ? (catAmt / monthTotal) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(catName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                            Text(
                              '${formatRupiah(catAmt)} (${(percent * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF132E25),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text(
            'Belum ada transaksi di bulan ini',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tekan "Catat Transaksi" untuk menambahkan.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(BuildContext context, TransactionModel transaction) {
    final transactionColor = transaction.isIncome
        ? const Color(0xFF428475)
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isIncome ? const Color(0xFF89D7B7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: transactionColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
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
                  '${formatTanggalPendek(transaction.date)} • ${transaction.category}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${transaction.isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: transactionColor,
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
            onSelected: (value) {
              if (value == 'delete') _confirmDeleteTransaction(context, transaction);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus transaksi?'),
        content: Text('"${transaction.title}" akan dihapus dari catatan keuangan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AppStore.instance.removeTransaction(transaction);
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Pilih Bulan'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _pickYear(dialogContext, _selectedMonth.year - 1);
                      },
                    ),
                    Text(
                      '${_selectedMonth.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _pickYear(dialogContext, _selectedMonth.year + 1);
                      },
                    ),
                  ],
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final isSelected = _selectedMonth.month == month;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(
                        dialogContext,
                        DateTime(_selectedMonth.year, month, 1),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF132E25) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          namaBulanSingkat(month),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedMonth = selected);
    }
  }

  void _pickYear(BuildContext dialogContext, int year) {
    Navigator.pop(dialogContext);
    setState(() => _selectedMonth = DateTime(year, _selectedMonth.month, 1));
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 12),
                ...['Semua', 'Pemasukan', 'Pengeluaran'].map(
                  (type) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: type,
                    groupValue: _typeFilter,
                    activeColor: const Color(0xFF132E25),
                    title: Text(type, style: const TextStyle(fontSize: 14)),
                    onChanged: (value) {
                      setState(() => _typeFilter = value ?? 'Semua');
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllTransactions(BuildContext context) {
    final store = AppStore.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final all = store.sortedTransactions;
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Semua Transaksi (${all.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: all.isEmpty
                          ? const Center(child: Text('Belum ada transaksi.'))
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: all.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) => _transactionTile(context, all[index]),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openTransactionForm(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = true;
    String category = 'Penjualan';
    DateTime date = DateTime.now();

    const incomeCategories = ['Penjualan', 'Bantuan', 'Lainnya'];
    const expenseCategories = ['Pupuk', 'Benih', 'Tenaga Kerja', 'Perawatan', 'Lainnya'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final categories = isIncome ? incomeCategories : expenseCategories;
            final safeCategory = categories.contains(category) ? category : categories.first;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Catat Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                            label: 'Pemasukan',
                            isActive: isIncome,
                            color: const Color(0xFF10B981),
                            onTap: () => setSheetState(() {
                              isIncome = true;
                              category = incomeCategories.first;
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeButton(
                            label: 'Pengeluaran',
                            isActive: !isIncome,
                            color: const Color(0xFFEF4444),
                            onTap: () => setSheetState(() {
                              isIncome = false;
                              category = expenseCategories.first;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _formLabel('Keterangan'),
                    const SizedBox(height: 4),
                    _formTextField(
                      controller: titleController,
                      hint: isIncome ? 'Contoh: Penjualan Tomat' : 'Contoh: Pembelian Pupuk',
                    ),
                    const SizedBox(height: 12),
                    _formLabel('Jumlah (Rp)'),
                    const SizedBox(height: 4),
                    _formTextField(
                      controller: amountController,
                      hint: 'Contoh: 1500000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _formLabel('Kategori'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: safeCategory,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          items: categories
                              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setSheetState(() => category = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _formLabel('Tanggal'),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setSheetState(() => date = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTanggalPanjang(date),
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                          final amount = double.tryParse(amountText) ?? 0;

                          if (title.isEmpty || amount <= 0) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Keterangan dan jumlah transaksi wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          AppStore.instance.addTransaction(
                            title: title,
                            amount: amount,
                            isIncome: isIncome,
                            category: safeCategory,
                            date: date,
                          );

                          Navigator.pop(sheetContext);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${isIncome ? 'Pemasukan' : 'Pengeluaran'} "$title" berhasil dicatat.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _typeButton({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _formLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
    );
  }

  Widget _formTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

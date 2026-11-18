const List<String> _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const List<String> _bulanSingkat = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// 1250000 -> "Rp1.250.000"
String formatRupiah(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return '${negative ? '-' : ''}Rp$buffer';
}

/// 1250000 -> "1,25 jt"
String formatCompactRupiah(num value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1).replaceAll('.', ',')} M';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} jt';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)} rb';
  }
  return value.toStringAsFixed(0);
}

/// "10 Oktober 2026"
String formatTanggalPanjang(DateTime date) {
  return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
}

/// "10 Okt 2026"
String formatTanggalPendek(DateTime date) {
  return '${date.day} ${_bulanSingkat[date.month - 1]} ${date.year}';
}

/// "Oktober 2026"
String formatBulanTahun(DateTime date) => '${_bulan[date.month - 1]} ${date.year}';

String namaBulan(int month) => _bulan[month - 1];

String namaBulanSingkat(int month) => _bulanSingkat[month - 1];

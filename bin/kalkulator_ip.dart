import 'dart:io';

/// Satu mata kuliah: nama, SKS, nilai huruf (Record).
typedef MataKuliah = ({String nama, int sks, String nilai});

/// Membaca satu baris input; null dianggap string kosong.
String baca(String label) {
  stdout.write('$label : ');
  return (stdin.readLineSync() ?? '').trim();
}

/// Validasi SKS: melempar FormatException bila bukan angka 1-6.
int validasiSks(String teks) {
  final sks = int.tryParse(teks);
  if (sks == null || sks < 1 || sks > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$teks".');
  }
  return sks;
}

/// Validasi nilai huruf: melempar FormatException bila bukan A-E.
String validasiNilai(String teks) {
  final huruf = teks.toUpperCase();
  if (!const ['A', 'B', 'C', 'D', 'E'].contains(huruf)) {
    throw FormatException('Nilai harus A, B, C, D, atau E, bukan "$teks".');
  }
  return huruf;
}

/// Mengubah nilai huruf menjadi bobot (switch expression).
int bobot(String huruf) => switch (huruf) {
  'A' => 4,
  'B' => 3,
  'C' => 2,
  'D' => 1,
  _ => 0,
};

/// IP = (jumlah SKS x bobot) / jumlah SKS, dihitung dengan fold.
double hitungIp(List<MataKuliah> data) {
  final totalSks = data.fold<int>(0, (jumlah, m) => jumlah + m.sks);
  if (totalSks == 0) return 0;
  final totalMutu = data.fold<int>(
    0,
    (jumlah, m) => jumlah + m.sks * bobot(m.nilai),
  );
  return totalMutu / totalSks;
}

/// Predikat berdasarkan IP (skala contoh, sesuaikan pedoman akademik).
String predikat(double ip) => switch (ip) {
  >= 3.5 => 'Sangat Memuaskan',
  >= 3.0 => 'Memuaskan',
  >= 2.0 => 'Cukup',
  _ => 'Kurang',
};

/// Mencetak KHS. Parameter bernama [urutkan]: urut dari nilai tertinggi.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  final tampil = [...data]; // salinan, supaya daftar asli tidak berubah
  if (urutkan) {
    // sort memakai fungsi pembanding (higher-order function)
    tampil.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }

  print('\n${'Mata Kuliah'.padRight(26)}${'SKS'.padLeft(4)} Nilai');
  print('-' * 38);
  for (final m in tampil) {
    print('${m.nama.padRight(26)}${m.sks.toString().padLeft(4)} ${m.nilai}');
  }
  print('-' * 38);

  final totalSks = data.fold<int>(0, (jumlah, m) => jumlah + m.sks);
  final ip = hitungIp(data);
  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');

  // where: ambil mata kuliah berbobot di bawah 2
  final perbaiki = data
      .where((m) => bobot(m.nilai) < 2)
      .map((m) => m.nama)
      .toList();
  if (perbaiki.isNotEmpty) {
    print('Perlu diperbaiki: ${perbaiki.join(', ')}');
  }
}

void main() {
  final List<MataKuliah> data = [];
  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.\n');

  while (true) {
    final nama = baca('Nama MK');
    if (nama.isEmpty) break; // nama kosong -> selesai

    try {
      final sks = validasiSks(baca('SKS'));
      final nilai = validasiNilai(baca('Nilai'));
      data.add((nama: nama, sks: sks, nilai: nilai));
    } on FormatException catch (e) {
      // Exception dari fungsi validasi ditangkap di sini,
      // data diabaikan dan program tetap berjalan.
      print('Data diabaikan: ${e.message}');
    }
  }

  if (data.isEmpty) {
    print('Tidak ada data yang valid.');
    return;
  }
  cetakKhs(data, urutkan: true);
}

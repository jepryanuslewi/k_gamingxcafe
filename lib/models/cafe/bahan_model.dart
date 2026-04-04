class Bahan {
  final int? id;
  final String nama;
  final String kategori;
  final String satuan;
  final double stokSaatIni;

  Bahan({
    this.id,
    required this.nama,
    required this.kategori,
    required this.satuan,
    required this.stokSaatIni,
  });

  // Konversi dari Map (Database) ke Objek
  factory Bahan.fromMap(Map<String, dynamic> map) {
    return Bahan(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      satuan: map['satuan'],
      stokSaatIni: (map['stok_saat_ini'] as num).toDouble(),
    );
  }

  // Konversi dari Objek ke Map (untuk Simpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'satuan': satuan,
      'stok_saat_ini': stokSaatIni,
    };
  }
}

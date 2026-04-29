class Bahan {
  final int? id;
  final String nama;
  final String kategori;
  final String satuan;
  final double stokSaatIni;
  final double isiPerQty;

  Bahan({
    this.id,
    required this.nama,
    required this.kategori,
    required this.satuan,
    required this.stokSaatIni,
    required this.isiPerQty,
  });

  factory Bahan.fromMap(Map<String, dynamic> map) {
    return Bahan(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      satuan: map['satuan'],
      stokSaatIni: (map['stok_saat_ini'] as num).toDouble(),
      isiPerQty: (map['isi_per_qty'] as num? ?? 1).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'satuan': satuan,
      'stok_saat_ini': stokSaatIni,
      'isi_per_qty': isiPerQty,
    };
  }
}

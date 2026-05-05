class MenuBahan {
  final int bahanId;
  final double jumlah; // kebutuhan per 1 menu

  MenuBahan({
    required this.bahanId,
    required this.jumlah,
  });

  factory MenuBahan.fromMap(Map<String, dynamic> map) {
    return MenuBahan(
      bahanId: map['bahan_id'],
      jumlah: (map['jumlah'] as num).toDouble(),
    );
  }
}
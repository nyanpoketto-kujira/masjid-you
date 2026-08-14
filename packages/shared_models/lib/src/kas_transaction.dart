import 'dart:convert';

enum KasType { masuk, keluar }

class KasTransaction {
  final String id;
  final KasType type;
  final int amount;
  final String description;
  final DateTime date;

  const KasTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory KasTransaction.fromMap(Map<String, dynamic> map) {
    return KasTransaction(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: KasType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => KasType.masuk,
      ),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory KasTransaction.fromJson(String source) =>
      KasTransaction.fromMap(json.decode(source));
}

class KasSummary {
  final int totalMasuk;
  final int totalKeluar;
  final int saldo;

  const KasSummary({
    this.totalMasuk = 0,
    this.totalKeluar = 0,
    this.saldo = 0,
  });

  factory KasSummary.fromTransactions(List<KasTransaction> transactions) {
    var masuk = 0;
    var keluar = 0;
    for (final t in transactions) {
      if (t.type == KasType.masuk) {
        masuk += t.amount;
      } else {
        keluar += t.amount;
      }
    }
    return KasSummary(
      totalMasuk: masuk,
      totalKeluar: keluar,
      saldo: masuk - keluar,
    );
  }
}

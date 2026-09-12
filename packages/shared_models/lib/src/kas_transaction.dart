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
    final rawId = map['id'];
    final rawDescription = map['description'];
    final rawDate = map['date'];
    return KasTransaction(
      id: rawId is String
          ? rawId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      type: KasType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => KasType.masuk,
      ),
      // Amount di-hardening: nilai non-numerik (mis. String) dianggap 0.
      amount: map['amount'] is num ? (map['amount'] as num).toInt() : 0,
      description: rawDescription is String ? rawDescription : '',
      date: rawDate is String ? (DateTime.tryParse(rawDate) ?? DateTime.now()) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory KasTransaction.fromJson(String source) =>
      KasTransaction.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KasTransaction &&
          other.id == id &&
          other.type == type &&
          other.amount == amount &&
          other.description == description &&
          other.date == date;

  @override
  int get hashCode => Object.hash(id, type, amount, description, date);

  @override
  String toString() =>
      'KasTransaction(id: $id, type: ${type.name}, amount: $amount, '
      'description: $description, date: $date)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KasSummary &&
          other.totalMasuk == totalMasuk &&
          other.totalKeluar == totalKeluar &&
          other.saldo == saldo;

  @override
  int get hashCode => Object.hash(totalMasuk, totalKeluar, saldo);

  @override
  String toString() =>
      'KasSummary(totalMasuk: $totalMasuk, totalKeluar: $totalKeluar, saldo: $saldo)';
}

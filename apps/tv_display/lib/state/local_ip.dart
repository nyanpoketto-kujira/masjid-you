import 'dart:io';

/// Ringkasan satu antarmuka jaringan — bentuk sederhana dari
/// [NetworkInterface] agar pemilih IP bisa diuji tanpa perangkat asli.
typedef NetworkInterfaceInfo = ({
  String name,
  List<InternetAddress> addresses,
});

/// Pilih alamat IPv4 lokal TV untuk ditampilkan di menu admin (ADR-029),
/// agar DKM bisa memasukkannya ke Remote untuk koneksi jalur IP/Wi-Fi.
///
/// Aturan pilih:
/// - Hanya IPv4 yang bukan loopback dan bukan link-local (169.254.x.x).
/// - Antarmuka Wi-Fi diutamakan, lalu ethernet/LAN, lalu sisanya —
///   berdasarkan nama antarmuka (wlan/wifi/eth/en).
/// - `null` bila tidak ada alamat yang layak (tidak ada jaringan).
String? pickLocalIpv4(List<NetworkInterfaceInfo> interfaces) {
  final candidates = [
    for (final iface in interfaces)
      for (final address in iface.addresses)
        if (address.type == InternetAddressType.IPv4 &&
            !address.isLoopback &&
            !address.isLinkLocal)
          (score: _interfaceScore(iface.name), address: address.address),
  ];
  if (candidates.isEmpty) return null;
  // Urutkan berdasarkan skor antarmuka; urutan asli dipertahankan untuk
  // skor yang sama (List.sort tidak stabil, jadi sertakan indeks awal).
  final indexed = [
    for (var i = 0; i < candidates.length; i++) (i, candidates[i]),
  ]..sort((a, b) {
      final byScore = a.$2.score.compareTo(b.$2.score);
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
  return indexed.first.$2.address;
}

int _interfaceScore(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('wlan') ||
      lower.contains('wifi') ||
      lower.contains('wi-fi')) {
    return 0;
  }
  if (lower.contains('eth') || lower.startsWith('en')) return 1;
  return 2;
}

/// Muat alamat IPv4 lokal dari antarmuka aktif perangkat ini.
/// `null` bila gagal membaca antarmuka atau tidak ada jaringan.
Future<String?> loadLocalIpv4() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return pickLocalIpv4([
      for (final iface in interfaces)
        (name: iface.name, addresses: iface.addresses),
    ]);
  } catch (_) {
    return null;
  }
}

/// Teks IP untuk menu admin TV: alamatnya, atau status tanpa jaringan.
String formatTvIpText(String? ip) =>
    (ip == null || ip.isEmpty) ? 'IP TV: tidak ada jaringan' : 'IP TV: $ip';

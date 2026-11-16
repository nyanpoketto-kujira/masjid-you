# Masjid You

Sistem Tampilan Masjid (TV Kiosk) + Remote HP pendamping — monorepo Flutter, berjalan **offline** tanpa internet/router.

## ⚠️ Peringatan: Proyek Vibe Coding

> [!WARNING]
> Repo ini **mayoritas dihasilkan lewat vibe coding** (dibangun cepat bersama AI agent, bukan hasil engineering manual penuh). Status saat ini: **prototipe / alfa** — bukan software produksi.
>
> - ✅ **Yang sudah oke:** suite test hijau (lihat tabel status di bawah), analyzer tanpa error, build universal APK sukses.
> - ⚠️ **Yang belum:** audit keamanan, review manusia baris-per-baris, signing release (APK masih **debug-signed**), dan uji lapangan di perangkat TV/HP sungguhan.
> - 🧪 Pakai dengan risiko sendiri. **Review kodenya dulu** sebelum dipakai di masjid sungguhan; bug dan keanehan adalah hal yang wajar — lapor via issue.
> - 📖 Konteks keputusan & batasan yang diketahui: [docs/DECISIONS.md](docs/DECISIONS.md).

## Aplikasi

| App | Path | Peran |
|---|---|---|
| **tv_display** | [`apps/tv_display`](apps/tv_display) | Kiosk di Google TV / Android TV: jam, jadwal sholat, running text, info masjid, kas. Bertindak sebagai server WebSocket `:8080` + host Bluetooth Classic (RFCOMM). |
| **mobile_remote** | [`apps/mobile_remote`](apps/mobile_remote) | Remote di HP Android: 5 tab editor (Pengaturan, Running Text, Info Masjid, Kas, Konektivitas). Client WebSocket + Bluetooth Classic. |
| **shared_models** | [`packages/shared_models`](packages/shared_models) | Paket bersama: protokol `SyncPacket`, model data, dan perhitungan jadwal sholat offline (`adhan`). |
| **bluetooth_sync** | [`packages/bluetooth_sync`](packages/bluetooth_sync) | Plugin Bluetooth Classic (RFCOMM): host di TV, client di Remote. Framing 4-byte big-endian + channel event.

## Status Build & Test

| Workspace | Analyze | Test | APK Universal |
|---|---|---|---|
| `packages/shared_models` | ✅ bersih | ✅ 70 pass | — |
| `packages/bluetooth_sync` | ✅ bersih | ✅ 30 pass | — |
| `apps/tv_display` | ✅ bersih | ✅ 67 pass | ✅ debug APK sukses |
| `apps/mobile_remote` | ✅ bersih | ✅ 68 pass | ✅ debug APK sukses |

## Fitur Utama

- Sinkronisasi lokal via **WebSocket** (`ws://<ip-TV>:8080`) — tanpa cloud.
- Koneksi **Bluetooth Classic (RFCOMM)** via `packages/bluetooth_sync` — jalur sync utama tanpa router. Host di TV diaktifkan lewat toggle menu admin (bukan auto-start), discoverable (re-arm tiap 110 detik), dan diamankan PIN challenge-response; Remote scan lalu sambung.
- **WiFi Direct sudah dicabut.** Jalurnya tidak dibawa `mobile_remote`, dan kode host-nya di `tv_display` (`P2pHostService` / `P2pMode`) sudah dihapus. Jalur tanpa router yang aktif adalah Bluetooth Classic di atas.
- Jadwal sholat **offline** dari koordinat (manual / GPS), dengan offset per sholat & simulasi.
- Indikator **Unsaved Changes** + tombol "Kirim Ke TV" di Remote.
- Fallback UI saat konten kosong (banner "Jagalah Shaf", running text "Tidak ada informasi").

## Dokumentasi

- [**📚 MAP.md**](docs/MAP.md) — Master codebase map, peta arsitektur, & peta fungsi per-file.
- [bt_rfcomm_rough_plan.md](docs/bt_rfcomm_rough_plan.md) — Rencana kasar perbaikan Bluetooth RFCOMM + status tiap item.
- [DECISIONS.md](docs/DECISIONS.md) — Architectural Decision Records (ADR).
- [tv_display/widget_mapping.md](docs/tv_display/widget_mapping.md) — Bedah widget sisi TV.
- [mobile_remote/tab_mapping.md](docs/mobile_remote/tab_mapping.md) — Bedah tab sisi Remote.

## Perintah Singkat

```bash
flutter pub get                      # workspace: install deps semua paket
flutter analyze                      # (di masing-masing app/paket)
flutter test                         # (di masing-masing app/paket)

# Build APK universal (berisi semua ABI: arm64-v8a, armeabi-v7a, x86_64)
flutter build apk --release          # (di apps/tv_display atau apps/mobile_remote)
# Output: build/app/outputs/flutter-apk/app-release.apk
# Catatan: masih debug-signed. Untuk distribusi resmi, pasang keystore release dulu.
# Butuh APK lebih kecil per-ABI? Pakai: flutter build apk --split-per-abi
```

## Komando Lokal (opencode)

```
/save-doc <nama>   → buat/update docs/<nama>.md + refresh link di MAP.md
/load-doc          → muat MAP.md + DECISIONS.md sebagai konteks
/read-doc <nama>   → baca docs/<nama>.md sebagai rujukan tugas
```


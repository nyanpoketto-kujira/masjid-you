# Masjid You

Sistem Tampilan Masjid (TV Kiosk) + Remote HP pendamping — monorepo Flutter, berjalan **offline** tanpa internet/router.

## Aplikasi

| App | Path | Peran |
|---|---|---|
| **tv_display** | [`apps/tv_display`](apps/tv_display) | Kiosk di Google TV / Android TV: jam, jadwal sholat, running text, info masjid, kas. Bertindak sebagai server WebSocket `:8080` + host WiFi Direct. |
| **mobile_remote** | [`apps/mobile_remote`](apps/mobile_remote) | Remote di HP Android: 5 tab editor (Pengaturan, Running Text, Info Masjid, Kas, Konektivitas). Client WebSocket + WiFi Direct/BLE. |
| **shared_models** | [`packages/shared_models`](packages/shared_models) | Paket bersama: protokol `SyncPacket`, model data, dan perhitungan jadwal sholat offline (`adhan`). |

## Fitur Utama

- Sinkronisasi lokal via **WebSocket** (`ws://<ip-TV>:8080`) — tanpa cloud.
- Koneksi **WiFi Direct + BLE** (`flutter_p2p_connection`) — tanpa router.
- Jadwal sholat **offline** dari koordinat (manual / GPS), dengan offset per sholat & simulasi.
- Indikator **Unsaved Changes** + tombol "Kirim Ke TV" di Remote.
- Fallback UI saat konten kosong (banner "Jagalah Shaf", running text "Tidak ada informasi").

## Dokumentasi

- [**📚 MAP.md**](docs/MAP.md) — Master codebase map, peta arsitektur, & peta fungsi per-file.
- [DECISIONS.md](docs/DECISIONS.md) — Architectural Decision Records (ADR).
- [tv_display/widget_mapping.md](docs/tv_display/widget_mapping.md) — Bedah widget sisi TV.
- [mobile_remote/tab_mapping.md](docs/mobile_remote/tab_mapping.md) — Bedah tab sisi Remote.

## Perintah Singkat

```bash
flutter pub get                      # workspace: install deps semua paket
flutter analyze                      # (di masing-masing app/paket)
flutter test                         # (di masing-masing app/paket)
flutter build apk --debug --target-platform android-x64
```

## Komando Lokal (opencode)

```
/save-doc <nama>   → buat/update docs/<nama>.md + refresh link di MAP.md
/load-doc          → muat MAP.md + DECISIONS.md sebagai konteks
/read-doc <nama>   → baca docs/<nama>.md sebagai rujukan tugas
```

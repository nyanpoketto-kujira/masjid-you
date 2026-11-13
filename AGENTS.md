# AGENTS.md — Panduan untuk AI Coding di Masjid You

Repositori monorepo Flutter/Dart (`masjid-you`) dengan dua app dan paket shared.
Sebelum memulai tugas apa pun yang menyentuh kode, baca panduan ini dan ikuti
**skill lokal** di bawah agar pencarian tidak memaksa membaca seluruh codebase.

## Skill Lokal (selalu update)

| Skill | Lokasi | Untuk apa |
|---|---|---|
| `codebase-lookup` | `.agents/skills/codebase-lookup/SKILL.md` | **Mencari simbol** (fungsi/class/enum) via indeks, tanpa membaca semua file |
| `doc-management` | `.agents/skills/doc-management/SKILL.md` | Membaca/memperbarui `docs/MAP.md`, `docs/DECISIONS.md`, sub-dokumen |

## Aturan Cari Simbol (MUST)

1. **Jangan scan file satu per satu.** Buka indeks `docs/codebase_index.md` (atau pakai
   MCP `codebase-index` → tool `search_code`). Indeks berisi `file:baris` + signature.
2. Baca hanya ±30 baris di sekitar `file:baris` yang dihasilkan indeks.
3. **Setiap perubahan di `lib/` wajib regenerasi indeks** sebelum commit:

   ```bash
   dart run tools/codebase_index.dart
   ```

   Commit `docs/codebase_index.json` + `docs/codebase_index.md` bersama kodenya.
   Jangan edit kedua file itu manual.

   Pasang sekali untuk otomasi (pre-commit hook menjalankan generator saat `lib/` berubah):

   ```bash
   tools/install-git-hooks.sh
   ```

`tools/mcp_codebase_server.dart` menyajikan indeks sebagai MCP server `codebase-index`
(stdio, `search_code` / `get_symbol` / `reindex`). Terdaftar di `opencode.json`.

## Konvensi & Dokumen Kunci

- `docs/MAP.md` — peta arsitektur & widget (ikuti saat bekerja di TV / Remote / shared_models).
- `docs/DECISIONS.md` — ADR; baca sebelum mengubah keputusan desain (mis. fallback UI, transport).
- `docs/bt_rfcomm_rough_plan.md` — daftar bug/status jalur Bluetooth RFCOMM.
- `docs/PLAN.md` — rencana implementasi & status checklist (update saat selesai).
- Bahasa dokumen: **Indonesia**. Commit message: konvensi conventional (feat/fix/refactor/docs).
- Analisis/uji: `flutter analyze` dan `flutter test` di `apps/*` dan `packages/*` (lihat `docs/MAP.md` §7).

## Alur Kerja Ringkas

1. Baca `docs/MAP.md` (konteks arsitektur).
2. Cari simbol target lewat `codebase-lookup` (indeks/MCP), bukan `read` seluruh file.
3. Edit hanya file yang relevan; regenerasi indeks jika `lib/` berubah.
4. Verifikasi dengan `flutter analyze` / `flutter test` di package terkait.
5. Update `docs/MAP.md` + `docs/DECISIONS.md` untuk perubahan arsitektur (skill `doc-management`).

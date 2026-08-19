---
name: doc-management
description: |-
  Mengelola, membaca, memperbarui, dan menginisialisasi dokumentasi proyek Masjid You.
  Gunakan skill ini saat diminta membaca dokumentasi, menginisialisasi konteks proyek (/init-doc),
  membuka dokumen spesifik (/read-doc), atau menyimpan/memperbarui dokumen (/save-doc).
license: MIT
---

# Doc Management Skill — Masjid You

Skill ini memandu AI untuk menginisialisasi konteks arsitektur, membaca dokumen referensi, dan memperbarui/menyimpan dokumen arsitektur proyek `masjid-you`.

---

## 1. Alur Kerja Komando Dokumentasi

### 🚀 `/init-doc` — Inisialisasi Konteks Dokumentasi Proyek
Gunakan alur ini saat memulai tugas baru atau ketika diminta membaca/menginisialisasi konteks proyek terlebih dahulu.

**Langkah-langkah:**
1. Baca file peta utama:
   - `docs/MAP.md` (Master Codebase Map)
   - `docs/DECISIONS.md` (Architectural Decision Records)
2. Pahami struktur monorepo:
   - `apps/tv_display` (Kiosk Android TV)
   - `apps/mobile_remote` (Remote HP Android)
   - `packages/shared_models` (Model & perhitungan jadwal shalat)
3. Rangkum status terkini proyek, arsitektur, dan aturan/keputusan penting yang relevan sebelum mengeksekusi perubahan kode.

---

### 📖 `/read-doc <nama>` — Membaca Dokumen Tertentu
Gunakan alur ini ketika pengguna atau tugas membutuhkan rujukan dari dokumen spesifik di dalam direktori `docs/`.

**Aturan Pembacaan:**
- Jika `<nama>` adalah `MAP` atau `DECISIONS`, baca langsung `docs/MAP.md` atau `docs/DECISIONS.md`.
- Jika `<nama>` menunjuk ke sub-dokumen (misal `tv_display/widget_mapping`, `mobile_remote/tab_mapping`, `m3_shapes`, `prayer_state_machine`, `theme_shapes`), cari dan baca file terkait di bawah `docs/`.
- Sertakan rangkuman poin-poin utama dari dokumen yang dibaca sebagai konteks kerja.

---

### 💾 `/save-doc <nama>` — Menyimpan / Memperbarui Dokumentasi
Gunakan alur ini ketika ada perubahan arsitektur, penambahan fitur, perbaikan bug major, atau perubahan UI/shape.

**Langkah-langkah:**
1. **Buat atau Edit File Dokumen Target**:
   - Tulis/perbarui file di `docs/<nama>.md` (atau subfolder `docs/tv_display/<nama>.md` / `docs/mobile_remote/<nama>.md`).
   - Gunakan format ringkas, jelas, dan berstruktur (Konteks → Keputusan/Perubahan → Detail Implementasi).
2. **Perbarui `docs/MAP.md`**:
   - Tambahkan/perbarui entri dokumen baru di tabel *Daftar Isi & Navigasi* pada `docs/MAP.md`.
   - Pastikan link relatif markdown (`[nama](path.md)`) valid.
3. **Perbarui `docs/DECISIONS.md` (jika ada keputusan arsitektur baru)**:
   - Tambahkan entri ADR baru (misal `ADR-013 — ...`) mengikuti format yang ada.

---

## 2. Struktur Referensi Dokumen

```
docs/
├── MAP.md                       # Master codebase map & indeks navigasi
├── DECISIONS.md                 # Architectural Decision Records (ADR)
├── tv_display/
│   ├── widget_mapping.md        # Pemetaan widget sisi TV
│   ├── m3_shapes.md             # Catatan shape & tema M3 TV
│   └── prayer_state_machine.md  # Arsitektur state machine waktu shalat
└── mobile_remote/
    ├── tab_mapping.md           # Pemetaan tab & form sisi Remote
    └── theme_shapes.md          # Catatan revert tema Material 3 Remote
```

---
name: codebase-lookup
description: |-
  Mencari simbol (fungsi/class/enum/field) di codebase Masjid You tanpa membaca ulang
  seluruh file. Gunakan skill ini setiap kali diminta "cari fungsi X", "di mana class Y",
  "apa yang memanggil Z", atau saat indeks `docs/codebase_index.*` perlu dibuat/diperbarui.
  Skill ini juga mengatur server MCP `codebase-index` dan kapan regenerasi indeks diwajibkan.
license: MIT
---

# Codebase Lookup Skill — Masjid You

Indeks simbol (`docs/codebase_index.md` + `docs/codebase_index.json`) adalah **titik masuk pertama**
untuk mencari apa pun di codebase. Baca indeks, lalu buka hanya bagian file yang relevan.

---

## 1. Aturan Utama (MUST)

1. **Jangan membaca semua file** saat mencari simbol. Selalu mulai dari indeks:
   - `docs/codebase_index.md` — manusia/AI, dikelompokkan per file + baris.
   - `docs/codebase_index.json` — programatik, field `kind`, `name`, `file`, `line`, `parent`, `signature`.
2. Setelah indeks memberi `file:baris`, baca **hanya ±30 baris** di sekitar baris itu.
3. **Setiap perubahan kode di `lib/` membuat indeks basi.** Regenerasi sebelum commit:

   ```bash
   dart run tools/codebase_index.dart
   ```

4. Jangan mengedit `docs/codebase_index.md` / `.json` secara manual — keduanya hasil generator.

---

## 2. `/find <nama>` — Mencari Simbol

Urutan keputusan:

1. **MCP tersedia?** Jika tool `search_code` (server `codebase-index`) ada, panggil:
   ```
   search_code(query: "<nama>", kind: "method")
   ```
   Kind yang didukung: `class`, `method`, `function`, `constructor`, `getter`, `setter`,
   `operator`, `field`, `enum`, `mixin`, `extension`, `typedef`.
2. **Tanpa MCP** → cari substring di indeks:
   ```bash
   # nama persis
   grep -n '"name": "_initLocalServer"' docs/codebase_index.json
   grep -n "_initLocalServer" docs/codebase_index.md
   ```
3. **Tidak ketemu** → regenerasi indeks dulu (langkah 3 di bawah), lalu ulangi pencarian.
4. **Masih tidak ada** → grep langsung ke sumber (`apps/*/lib`, `packages/*/lib`) — indeks
   hanya mencakup deklarasi, bukan string/arbitrary teks.

Output indeks memberi `file:baris` + `parent` (class enclosing) + signature, jadi tidak perlu
menebak nama class.

### Contoh

```
$ grep -n "startDiscovery" docs/codebase_index.md
apps/mobile_remote/lib/services/bluetooth_client_service.dart:139  method  startDiscovery (BluetoothClientService)
```

→ Buka `apps/mobile_remote/lib/services/bluetooth_client_service.dart:125-180`, bukan seluruh file.

---

## 3. Update Indeks (WAJIB Setelah Mengubah `lib/`)

```bash
# Jalankan dari root repo
dart run tools/codebase_index.dart
# Index regenerated: NNN symbols.
#   docs/codebase_index.json
#   docs/codebase_index.md
```

Kapan regenerasi:

- Menambah/menghapus/mengubah nama class, enum, method, getter, setter, operator, field.
- Memindahkan file Dart (path berubah).
- Sebelum commit jika pesan "Index regenerated" belum muncul setelah edit terakhir.

Commitkan dua file hasil generator **bersama** kode yang diubah:

```bash
git add docs/codebase_index.json docs/codebase_index.md <kode>
```

Indeks juga punya timestamp `generatedAt`; jika `generatedAt` lebih lama dari commit terakhir,
regenerasi dulu sebelum mengandalkan isi indeks.

**Otomasi (disarankan):** pasang pre-commit hook sekali saja —

```bash
tools/install-git-hooks.sh
```

Hook menjalankan generator otomatis saat file `lib/` yang di-`git add` berubah, lalu
men-stage `docs/codebase_index.json` + `.md`, sehingga indeks tidak mungkin basi saat commit.
Tetap boleh regenerasi manual kapan pun (perintah di atas).

---

## 4. Server MCP `codebase-index` (opsional tapi disarankan)

Implementasi: `tools/mcp_codebase_server.dart` (stdio JSON-RPC, `dart run`, tanpa dependency).
Terdaftar di `opencode.json` → `mcp.codebase-index`.

Tool yang terekspos:

| Tool | Argumen | Fungsi |
|---|---|---|
| `search_code` | `query`, `kind?`, `file?`, `max?` | Cari simbol berdasarkan nama/signature |
| `get_symbol` | `file`, `line` | Ambil simbol tepat di `file:baris` |
| `reindex` | — | Jalankan generator indeks lalu muat ulang |

Jalankan manual (tidak perlu MCP) bila ingin cek cepat:

```bash
dart run tools/mcp_codebase_server.dart
# lalu kirim JSON-RPC via stdin, contoh:
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | dart run tools/mcp_codebase_server.dart
```

Catatan protokol: pakai `stdout.writeln` **tanpa** `stdout.flush()` — `flush()` pada Dart 3.12
membuat `stdout` crash saat ditulisi lagi.

---

## 5. Batasan Indeks (PENTING)

Indeks bersifat heuristik (parser regex + brace depth), bukan analisis semantik penuh.

- Menangkap deklarasi di `lib/` hanya: class, enum, mixin, extension, typedef, function top-level,
  method, getter/setter, operator, field.
- **Tidak** mencakup: isi body function, string literal, nama di XML/JSON/AndroidManifest,
  dependency package eksternal, atau file di luar `lib/`.
- Signature multi-baris hanya menampilkan baris deklarasi pertama.
- Bila hasil terasa aneh, verifikasi langsung ke sumber di `file:baris` yang diberikan.

---

## 6. Navigasi Lintas Skill

- Butuh **alasan desain** (kenapa ditulis begini) → [`docs/DECISIONS.md`](../../../docs/DECISIONS.md) + skill `doc-management`.
- Butuh **peta arsitektur/widget** → [`docs/MAP.md`](../../../docs/MAP.md).
- Butuh **jalur Bluetooth** → `docs/bt_rfcomm_rough_plan.md`.
- Butuh **simbol spesifik** → skill ini (indeks) dulu, baru sumber.

// Generates docs/codebase_index.json + docs/codebase_index.md from the
// monorepo's lib/ sources. Run from repo root:
//
//   dart run tools/codebase_index.dart
//
// Pure dart:core — no external dependencies. The index is a symbol map used
// by the `codebase-lookup` skill so search never requires reading every file.
library;

import 'dart:convert';
import 'dart:io';

const _roots = <String>[
  'apps/tv_display/lib',
  'apps/mobile_remote/lib',
  'packages/shared_models/lib',
  'packages/bluetooth_sync/lib',
  'packages/flutter_p2p_connection/lib',
];

const _controlKeywords = {
  'if', 'for', 'while', 'switch', 'catch', 'return', 'assert', 'throw',
  'factory', 'await', 'case', 'else', 'do', 'yield', 'try', 'finally',
};
final _enumRe = RegExp(r'^enum\s+(\w+)');
final _mixinRe = RegExp(r'^mixin\s+(\w+)');
final _extensionRe = RegExp(r'^extension\s+(\w+)\s+on\b');
final _typedefRe = RegExp(r'^typedef\s+(\w+)');


class Symbol {
  final String kind; // class|enum|mixin|extension|typedef|function|constructor|method|getter|setter|operator|field
  final String name;
  final String file;
  final int line;
  final String? parent;
  final String signature;
  Symbol(
    this.kind,
    this.name,
    this.file,
    this.line,
    this.parent,
    this.signature,
  );
}

String _stripCommentsAndStrings(String src) {
  final sb = StringBuffer();
  var i = 0;
  final n = src.length;
  while (i < n) {
    final c = src[i];
    final next = i + 1 < n ? src[i + 1] : '';
    if (c == '/' && next == '/') {
      while (i < n && src[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && next == '*') {
      i += 2;
      while (i < n && !(src[i] == '*' && i + 1 < n && src[i + 1] == '/')) {
        if (src[i] == '\n') sb.write('\n');
        i++;
      }
      i += 2;
      continue;
    }
    if (c == "'" || c == '"') {
      final triple = next == c && i + 2 < n && src[i + 2] == c;
      final delim = triple ? c * 3 : c;
      i += delim.length;
      while (i < n && !src.startsWith(delim, i)) {
        if (src[i] == '\\') {
          i++;
        } else if (src[i] == '\n' && !triple) {
          break;
        }
        if (src[i] == '\n') sb.write('\n');
        i++;
      }
      i += delim.length;
      // Preserve a placeholder of the same length so line numbers stay exact.
      for (var k = 0; k < delim.length; k++) {
        sb.write(' ');
      }
      continue;
    }
    sb.write(c);
    i++;
  }
  return sb.toString();
}


/// Matches `[returnType] name(...) [initializer] =>|{|;` declarations.
final _methodRe = RegExp(
  r'^(?:[\w<>,\[\]?&.\s]+\s+)?(\w+)\s*\([^;{}()]*\)\s*(?::[^{;]*)?\s*(?:async\*?\s*)?(?:=>|\{|;)',
);

/// Matches `get name =>|{|;` / `set name(...)` / fields `Type name = |;`.
final _accessorRe = RegExp(
  r'^(?:[\w<>,\[\]?&.\s]+\s+)?\b(get|set)\s+(\w+)\s*\(?[^;{}()]*\)?\s*(?:=>|\{|;)',
);
final _fieldRe = RegExp(
  r'^(?:static\s+|final\s+|const\s+|late\s+|var\s+|[\w<>,\[\]?&.\s]+\s+)(\w+)\s*(?:=|;)',
);

(String name, String signature)? _matchMethod(String line) {
  final m = _methodRe.firstMatch(line);
  if (m == null) return null;
  final name = m.group(1)!;
  if (_controlKeywords.contains(name)) return null;
  return (name, line.trimRight());
}

final _operatorRe = RegExp(
  r'^(?:[\w<>,\[\]?&.\s]+\s+)?operator\s+(\S+?)\s*\([^;{}()]*\)\s*(?::[^{;]*)?\s*(?:async\*?\s*)?(?:=>|\{|;)',
);

List<Symbol> parseFile(String path) {
  final text = File(path).readAsStringSync();
  final rawTextLines = text.split('\n');
  final clean = _stripCommentsAndStrings(text);
  final fileLabel = path;
  final symbols = <Symbol>[];
  final lines = clean.split('\n');

  var depth = 0;
  var currentClass = '';
  var inArrowBody = false;

  for (var li = 0; li < lines.length; li++) {
    final rawLine = lines[li];
    final trimmed = rawLine.trimLeft();

    // Skip continuation lines of a multi-line `=>` body (depth stays 1),
    // otherwise they are mis-detected as members.
    final lineEnds =
        trimmed.endsWith(';') || trimmed.endsWith('}') || trimmed.endsWith('{');
    if (inArrowBody && !lineEnds) {
      for (var i = 0; i < rawLine.length; i++) {
        if (rawLine[i] == '{') depth++;
        if (rawLine[i] == '}') depth--;
      }
      continue;
    }
    // Update enclosing class name for top-level class declarations.
    if (depth == 0) {
      final cls = RegExp(
        r'^(?:abstract\s+|base\s+|final\s+|sealed\s+|interface\s+)?class\s+(\w+)',
      ).firstMatch(trimmed);
      final en = _enumRe.firstMatch(trimmed);
      final mx = _mixinRe.firstMatch(trimmed);
      final ex = _extensionRe.firstMatch(trimmed);
      final td = _typedefRe.firstMatch(trimmed);
      if (cls != null) {
        currentClass = cls.group(1)!;
        symbols.add(Symbol('class', cls.group(1)!, fileLabel, li + 1, null,
            rawTextLines[li].trimRight()));
      } else if (en != null) {
        currentClass = en.group(1)!;
        symbols.add(Symbol('enum', en.group(1)!, fileLabel, li + 1, null,
            rawTextLines[li].trimRight()));
      } else if (mx != null) {
        currentClass = mx.group(1)!;
        symbols.add(Symbol('mixin', mx.group(1)!, fileLabel, li + 1, null,
            rawTextLines[li].trimRight()));
      } else if (ex != null) {
        symbols.add(Symbol('extension', ex.group(1)!, fileLabel, li + 1, null,
            rawTextLines[li].trimRight()));
      } else if (td != null) {
        symbols.add(Symbol('typedef', td.group(1)!, fileLabel, li + 1, null,
            rawTextLines[li].trimRight()));
      } else if (!trimmed.startsWith('import') &&
          !trimmed.startsWith('export') &&
          !trimmed.startsWith('part ') &&
          !trimmed.startsWith('library') &&
          !trimmed.startsWith('using') &&
          !trimmed.contains('//') &&
          !trimmed.isEmpty) {
        // Top-level function.
        final fn = _matchMethod(trimmed);
        if (fn != null) {
          symbols.add(Symbol('function', fn.$1, fileLabel, li + 1, null,
              rawTextLines[li].trimRight()));
          if (fn.$2.endsWith('=>') && !fn.$2.endsWith('=> {')) {
            inArrowBody = true;
          }
        }
      }
    } else if (depth == 1 && currentClass.isNotEmpty) {
      // Direct member of the enclosing class/enum/mixin.
      final fn = _matchMethod(trimmed);
      final accessor = _accessorRe.firstMatch(trimmed);
      final op = _operatorRe.firstMatch(trimmed);
      if (op != null) {
        final opName = 'operator ${op.group(1)}';
        symbols.add(Symbol('operator', opName, fileLabel, li + 1,
            currentClass, rawTextLines[li].trimRight()));
        if (trimmed.trimRight().endsWith('=>')) inArrowBody = true;
      } else if (accessor != null && !_controlKeywords.contains(accessor.group(2)!)) {
        final kind = accessor.group(1) == 'get' ? 'getter' : 'setter';
        symbols.add(Symbol(kind, accessor.group(2)!, fileLabel, li + 1,
            currentClass, rawTextLines[li].trimRight()));
        if (trimmed.trimRight().endsWith('=>')) inArrowBody = true;
      } else if (fn != null) {
        final name = fn.$1;
        final kind =
            name == currentClass || trimmed.startsWith(currentClass)
                ? 'constructor'
                : trimmed.startsWith('operator ')
                    ? 'operator'
                    : 'method';
        symbols.add(Symbol(kind, name, fileLabel, li + 1, currentClass,
            rawTextLines[li].trimRight()));
        if (fn.$2.endsWith('=>') && !fn.$2.endsWith('=> {')) {
          inArrowBody = true;
        }
      } else {
        final field = _fieldRe.firstMatch(trimmed);
        if (field != null) {
          symbols.add(Symbol('field', field.group(1)!, fileLabel, li + 1,
              currentClass, rawTextLines[li].trimRight()));
        }
      }
    }

    // Update brace depth across the whole line.
    for (var i = 0; i < rawLine.length; i++) {
      if (rawLine[i] == '{') depth++;
      if (rawLine[i] == '}') {
        depth--;
        if (depth <= 0) currentClass = '';
      }
    }
    if (trimmed.endsWith(';') || trimmed.endsWith('}')) {
      inArrowBody = false;
    }
  }

  return symbols;
}

void main() {
  final all = <Symbol>[];
  for (final root in _roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        all.addAll(parseFile(entity.path));
      }
    }
  }

  all.sort((a, b) {
    final c = a.file.compareTo(b.file);
    if (c != 0) return c;
    return a.line.compareTo(b.line);
  });

  final seen = <String>{};
  final symbols = <Map<String, Object?>>[];
  for (final s in all) {
    final key = '${s.kind}|${s.name}|${s.file}|${s.parent}';
    if (!seen.add(key)) continue;
    symbols.add({
      'kind': s.kind,
      'name': s.name,
      'file': s.file,
      'line': s.line,
      if (s.parent != null) 'parent': s.parent,
      'signature': s.signature,
    });
  }

  final json = {
    'generatedAt': DateTime.now().toIso8601String(),
    'roots': _roots,
    'symbolCount': symbols.length,
    'symbols': symbols,
  };

  Directory('docs').createSync(recursive: true);
  File('docs/codebase_index.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(json),
  );

  final byKind = <String, int>{};
  for (final s in symbols) {
    byKind[s['kind'] as String] = (byKind[s['kind'] as String] ?? 0) + 1;
  }

  final b = StringBuffer()
    ..writeln('# Codebase Index — Masjid You')
    ..writeln()
    ..writeln(
      '> Dibuat otomatis oleh `dart run tools/codebase_index.dart`. '
      'Jangan edit manual — regenerate setelah perubahan kode.',
    )
    ..writeln()
    ..writeln('Total simbol: **${symbols.length}**')
    ..writeln()
    ..writeln('| Kategori | Jumlah |')
    ..writeln('|---|---:|');
  byKind.forEach((k, v) {
    b.writeln('| `$k` | $v |');
  });
  b.writeln();

  String? lastFile;
  for (final s in symbols) {
    final file = s['file'] as String;
    if (file != lastFile) {
      lastFile = file;
      b.writeln('\n### `$file`');
    }
    final parent = s['parent'];
    final name = parent == null
        ? s['name']
        : '${s['name']} (${s['parent']})';
    b.writeln(
      '- `${s['kind']}` **$name** — baris ${s['line']} — `${s['signature']}`',
    );
  }

  File('docs/codebase_index.md').writeAsStringSync(b.toString());

  stdout.writeln('Index regenerated: ${symbols.length} symbols.');
  stdout.writeln('  docs/codebase_index.json');
  stdout.writeln('  docs/codebase_index.md');
}

// Minimal stdio MCP server exposing the generated codebase index.
//
// Start it (e.g. from opencode.json) with:
//   dart run tools/mcp_codebase_server.dart
//
// Tools:
//   search_code(query, [kind, file, max]) — substring search over symbol names
//   get_symbol(file, line)                 — exact file+line lookup
//   reindex()                              — regenerate docs/codebase_index.*
//
// Speaks the MCP streamable stdio transport (newline-delimited JSON-RPC).
library;

import 'dart:convert';
import 'dart:io';

const _serverName = 'masjid-you-codebase-index';
const _version = '1.0.0';
const _protocolVersion = '2025-03-26';
const _indexPath = 'docs/codebase_index.json';

late List<dynamic> _symbols;

List<dynamic> _loadIndex() {
  final f = File(_indexPath);
  if (!f.existsSync()) return const [];
  final data = jsonDecode(f.readAsStringSync());
  return (data as Map)['symbols'] as List<dynamic>? ?? const [];
}

Map<String, Object?> _tool(String name, String description, Map<String, Object?> schema) =>
    {'name': name, 'description': description, 'inputSchema': schema};

void _send(Map<String, Object?> msg) {
  stdout.writeln(jsonEncode(msg));
}

void _handleToolsCall(Map<String, Object?> req) {
  final id = req['id'];
  final params = (req['params'] as Map?)?['arguments'] as Map<String, Object?>? ?? {};
  final name = ((req['params'] as Map?)?['name'] ?? '') as String;
  var text = '';

  switch (name) {
    case 'search_code':
      final query = (params['query'] ?? '').toString().toLowerCase();
      final kind = (params['kind'] ?? '').toString();
      final fileFilter = (params['file'] ?? '').toString();
      final max = params['max'] is num
          ? (params['max'] as num).toInt()
          : 40;
      if (query.isEmpty) {
        text = 'Query required.';
        break;
      }
      final hits = _symbols.where((s) {
        final m = s as Map;
        final name2 = (m['name'] ?? '').toString().toLowerCase();
        final sig = (m['signature'] ?? '').toString().toLowerCase();
        final file = (m['file'] ?? '').toString();
        final matchesText = name2.contains(query) || sig.contains(query);
        final matchesKind = kind.isEmpty || (m['kind'] as String) == kind;
        final matchesFile = fileFilter.isEmpty || file.contains(fileFilter);
        return matchesText && matchesKind && matchesFile;
      }).take(max).toList();
      if (hits.isEmpty) {
        text = 'No matches for "$query".';
      } else {
        final b = StringBuffer()
          ..writeln('${hits.length} match(es) for "$query":')
          ..writeln();
        for (final h in hits) {
          final m = h as Map;
          final parent = m['parent'] == null ? '' : ' (${m['parent']})';
          b.writeln(
            '${m['file']}:${m['line']}  ${m['kind']}  ${m['name']}$parent',
          );
          b.writeln('    ${m['signature']}');
        }
        text = b.toString();
      }
    case 'get_symbol':
      final file = (params['file'] ?? '').toString();
      final line = params['line'] is num
          ? (params['line'] as num).toInt()
          : 0;
      final hits = _symbols.where((s) {
        final m = s as Map;
        return m['file'] == file && m['line'] == line;
      }).toList();
      if (hits.isEmpty) {
        text = 'No symbol at $file:$line.';
      } else {
        final b = StringBuffer();
        for (final h in hits) {
          final m = h as Map;
          b.writeln(jsonEncode(m));
        }
        text = b.toString();
      }
    case 'reindex':
      final res = Process.runSync(
        Platform.resolvedExecutable,
        ['run', 'tools/codebase_index.dart'],
        workingDirectory: Directory.current.path,
      );
      _symbols = _loadIndex();
      text = '${res.stdout}\n${res.stderr}'.trim();
    default:
      text = 'Unknown tool: $name';
  }

  _send({
    'jsonrpc': '2.0',
    'id': id,
    'result': {'content': [
      {'type': 'text', 'text': text},
    ]},
  });
}

void main() {
  _symbols = _loadIndex();
  stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.trim().isEmpty) return;
    final Map<String, Object?> msg;
    try {
      msg = (jsonDecode(line) as Map).cast<String, Object?>();
    } catch (_) {
      return;
    }
    final method = msg['method'];
    if (method == 'initialize') {
      _send({
        'jsonrpc': '2.0',
        'id': msg['id'],
        'result': {
          'protocolVersion': _protocolVersion,
          'capabilities': {'tools': {'listChanged': false}},
          'serverInfo': {'name': _serverName, 'version': _version},
        },
      });
    } else if (method == 'notifications/initialized') {
      // No-op.
    } else if (method == 'tools/list') {
      _send({
        'jsonrpc': '2.0',
        'id': msg['id'],
        'result': {
          'tools': [
            _tool(
              'search_code',
              'Cari simbol (class/method/function/enum/field) di codebase Masjid You.',
              {
                'type': 'object',
                'properties': {
                  'query': {'type': 'string'},
                  'kind': {
                    'type': 'string',
                    'enum': [
                      'class', 'method', 'function', 'constructor', 'getter',
                      'setter', 'operator', 'field', 'enum', 'mixin',
                      'extension', 'typedef',
                    ],
                  },
                  'file': {'type': 'string'},
                  'max': {'type': 'number'},
                },
                'required': ['query'],
              },
            ),
            _tool(
              'get_symbol',
              'Ambil simbol tepat di file:baris.',
              {
                'type': 'object',
                'properties': {
                  'file': {'type': 'string'},
                  'line': {'type': 'number'},
                },
                'required': ['file', 'line'],
              },
            ),
            _tool(
              'reindex',
              'Regenerasi docs/codebase_index.json & .md dari sumber.',
              {'type': 'object', 'properties': {}},
            ),
          ],
        },
      });
    } else if (method == 'tools/call') {
      _handleToolsCall(msg);
    } else if (method == 'ping') {
      _send({'jsonrpc': '2.0', 'id': msg['id'], 'result': {}});
    }
  });
}

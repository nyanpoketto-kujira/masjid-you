import 'dart:convert';

import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_remote/main.dart';

/// Fake platform plugin Bluetooth — dipakai agar app di dalam widget test
/// memakai `BluetoothClientService` sungguhan (challenge -> dialog PIN),
/// tanpa radio Bluetooth asli.
class _FakeBtPlatform {
  final List<String> calls = <String>[];

  /// Paket JSON yang dikirim Remote ke "TV" (method `send`).
  final List<String> sentPayloads = <String>[];

  MockStreamHandlerEventSink? sink;

  late final MethodChannel channel =
      const MethodChannel('com.masjidyou/bluetooth_sync');
  late final EventChannel events =
      const EventChannel('com.masjidyou/bluetooth_sync/events');

  TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void install() {
    _messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'send') {
        final args = call.arguments as Map;
        final raw = args['bytes'];
        if (raw is List<int>) {
          sentPayloads.add(String.fromCharCodes(raw));
        }
      }
      switch (call.method) {
        // Method yang mengembalikan boolean.
        case 'hasPermission':
        case 'requestPermission':
        case 'isEnabled':
        case 'enable':
        case 'isLocationEnabled':
        case 'isSupported':
        case 'startDiscovery':
        case 'stopDiscovery':
        case 'connect':
        case 'disconnect':
        case 'send':
        case 'startHost':
        case 'stopHost':
          return true;
        default:
          return null;
      }
    });
    _messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        // Body blok, bukan panah: kerangka tes memakai nilai kembalian
        // `onListen` sebagai respons panggilan `listen`
        // (test_default_binary_messenger). `=> sink = events` mengembalikan
        // sink itu sehingga codec StandardMethodCodec memuntahkan
        // PlatformException "Invalid argument: Instance of
        // MockStreamHandlerEventSink" saat stream diaktifkan.
        onListen: (arguments, events) {
          sink = events;
        },
        onCancel: (arguments) => sink = null,
      ),
    );
  }

  void uninstall() {
    _messenger.setMockMethodCallHandler(channel, null);
    // Handler stream sengaja TETAP dipasang (bukan `null`): pembongkaran widget
    // tree di teardown mengirim `cancel` secara asinkron ke EventChannel.
    // Tanpa handler, `cancel` itu memuntahkan MissingPluginException yang
    // menjadi artefak kegagalan tes (kerangka flutter_test mereset semua mock
    // handler sendiri setelah setiap test).
    _messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          sink = events;
        },
        onCancel: (arguments) => sink = null,
      ),
    );
    sink = null;
  }

  void emit(Map<String, Object?> event) => sink?.success(event);
}

/// Tunggu kondisi sambil memompa frame — aman di widget test (async zone
/// FakeAsync tidak menjalankan Future.delayed tanpa pump).
Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() predicate, {
  String? reason,
  int maxFrames = 60,
}) async {
  for (var i = 0; i < maxFrames; i++) {
    if (predicate()) return;
    await tester.pump(const Duration(milliseconds: 16));
  }
  fail('kondisi tidak terpenuhi${reason == null ? '' : ' ($reason)'}');
}

Future<void> _pump(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}


/// Emit event plugin + flush pesan platform. `runAsync` menjalankan async
/// nyata (di luar FakeAsync) supaya `MockStreamHandlerEventSink.success()`
/// benar-benar terkirim ke stream Dart.
Future<void> _emitAndFlush(
  WidgetTester tester,
  _FakeBtPlatform platform,
  Map<String, Object?> event,
) async {
  await tester.runAsync(() async {
    platform.emit(event);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });
  await _pump(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBtPlatform platform;

  setUp(() {
    BluetoothSync.debugResetEvents();
    platform = _FakeBtPlatform()..install();
  });

  tearDown(() => platform.uninstall());

  testWidgets(
      'PIN Bluetooth: PIN salah lalu Batal tidak crash & kembali ke gateway',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await _pump(tester);

    // Gatekeeper tampil.
    expect(find.text('Selamat Datang di Remote Masjid'), findsOneWidget);
    expect(find.text('Cari TV'), findsOneWidget);

    // Mulai discovery lewat UI.
    await tester.tap(find.text('Cari TV'));
    await _pump(tester);
    await _waitUntil(tester, () => platform.sink != null);

    // TV ditemukan.
    await _emitAndFlush(tester, platform, {
      'type': 'discovered',
      'address': 'AA:BB:CC:DD:EE:01',
      'name': 'Masjid You TV',
      'bonded': false,
    });
    await _waitUntil(
      tester,
      () => find.text('Masjid You TV').evaluate().isNotEmpty,
      reason: 'TV harus muncul di daftar gateway',
    );

    // Klik perangkat TV -> connect lalu TV mengirim authChallenge.
    await tester.tap(find.text('Masjid You TV'));
    await _pump(tester);
    await _waitUntil(tester, () => platform.calls.contains('connect'));
    await _emitAndFlush(tester, platform, {
      'type': 'connected',
      'name': 'Masjid You TV',
      'address': 'AA:BB:CC:DD:EE:01',
    });

    // TV meminta PIN: dialog harus muncul.
    await _emitAndFlush(tester, platform, {
      'type': 'data',
      'bytes': utf8.encode(
        '{"action":"authChallenge","payload":{"nonce":"a1b2c3d4e5f60718"}}',
      ),
    });
    expect(find.text('Masukkan PIN TV'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    // PIN salah: snackbar error muncul.
    await _emitAndFlush(tester, platform, {
      'type': 'data',
      'bytes': utf8.encode(
        '{"action":"authFailure","payload":{"error":"PIN salah."}}',
      ),
    });
    expect(find.textContaining('PIN salah'), findsWidgets);

    // Tekan Batal: dialog tertutup, kembali ke gateway, TANPA crash
    // '_dependents.isEmpty'.
    await tester.tap(find.text('Batal'));
    await _pump(tester, 40);

    // Tidak boleh ada assertion framework — khususnya crash Red Screen
    // '_dependents.isEmpty' (dan regresi controller/overflow yang menyertai).
    // Catatan: mock platform channel bisa meninggalkan PlatformException
    // artefak tes; itu bukan kegagalan produksi.
    final recorded = tester.takeException()?.toString() ?? '';
    expect(
      recorded.contains('_dependents.isEmpty'),
      isFalse,
      reason: 'crash _dependents.isEmpty muncul saat dialog PIN ditutup',
    );
    expect(
      recorded.contains('used after being disposed'),
      isFalse,
      reason: 'TextEditingController dialog dipakai setelah dispose',
    );
    expect(recorded.contains('overflowed by'), isFalse,
        reason: 'layout dialog PIN overflow');

    expect(find.text('Masukkan PIN TV'), findsNothing);
    expect(find.text('Selamat Datang di Remote Masjid'), findsOneWidget);

    // Root navigator & messenger tetap hidup.
    expect(appNavigatorKey.currentState, isNotNull);
    expect(appMessengerKey.currentState, isNotNull);
  });

  testWidgets(
      'nonce tidak hilang walau event connected datang SETELAH authChallenge',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await _pump(tester);

    await tester.tap(find.text('Cari TV'));
    await _pump(tester);
    await _waitUntil(tester, () => platform.sink != null);

    await _emitAndFlush(tester, platform, {
      'type': 'discovered',
      'address': 'AA:BB:CC:DD:EE:01',
      'name': 'Masjid You TV',
      'bonded': false,
    });
    await _waitUntil(
      tester,
      () => find.text('Masjid You TV').evaluate().isNotEmpty,
      reason: 'TV harus muncul di daftar gateway',
    );

    await tester.tap(find.text('Masjid You TV'));
    await _pump(tester);
    await _waitUntil(tester, () => platform.calls.contains('connect'));

    // RACE: TV mengirim challenge LEBIH DULU, event `connected` menyusul
    // kemudian. Sebelum perbaikan, handler `connected` membuang nonce yang
    // sudah masuk sehingga PIN tidak pernah diterima TV.
    await _emitAndFlush(tester, platform, {
      'type': 'data',
      'bytes': utf8.encode(
        '{"action":"authChallenge","payload":{"nonce":"deadbeefcafe1234"}}',
      ),
    });
    await _emitAndFlush(tester, platform, {
      'type': 'connected',
      'name': 'Masjid You TV',
      'address': 'AA:BB:CC:DD:EE:01',
    });

    expect(find.text('Masukkan PIN TV'), findsOneWidget);

    // PIN benar: ketik lalu kirim.
    // Field IP gatekeeper juga memakai TextField dan lebih dulu di pohon;
    // ketik ke field di dalam dialog PIN.
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '4838',
    );
    await _pump(tester);
    // Ada dua tombol "Hubungkan" di pohon widget (gatekeeper + dialog PIN);
    // targetkan yang di dalam dialog PIN.
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Hubungkan'),
    ));
    await _pump(tester, 40);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });

    // Paket authResponse benar-benar terkirim dengan pin + nonce challenge.
    final response = platform.sentPayloads
        .map((raw) {
          try {
            return jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        })
        .firstWhere(
          (p) => p != null && p['action'] == 'authResponse',
      orElse: () => null,
    );
    expect(response, isNotNull,
        reason: 'authResponse harus terkirim setelah PIN dimasukkan');
    final payload = response!['payload'] as Map<String, dynamic>;
    expect(payload['pin'], '4838');
    expect(payload['nonce'], 'deadbeefcafe1234');

    // TV menerima PIN: authSuccess -> dialog tertutup.
    await _emitAndFlush(tester, platform, {
      'type': 'data',
      'bytes': utf8.encode('{"action":"authSuccess","payload":{}}'),
    });
    expect(find.text('Masukkan PIN TV'), findsNothing);
  });
}

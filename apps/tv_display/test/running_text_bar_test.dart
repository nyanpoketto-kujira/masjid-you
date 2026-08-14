import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

import 'package:tv_display/widgets/running_text_bar.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 800, height: 60, child: child)),
      ),
    );
  }

  testWidgets('Empty/inactive running texts shows full-width static badge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const RunningTextBar(messages: [])));
    await tester.pump();

    expect(find.text('Tidak ada informasi'), findsOneWidget);
    expect(find.text('INFORMASI'), findsOneWidget);

    // Static text must NOT be inside a scrolling marquee list.
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Tidak ada informasi'),
      ),
      findsNothing,
    );

    // Container fills the width (800 wide test surface).
    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('INFORMASI'),
        matching: find.byType(Container),
      ).first,
    );
    expect(tester.getSize(find.byWidget(container)).width, 800);
  });

  testWidgets('Inactive (all off) messages behave like empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const RunningTextBar(
        messages: [
          RunningTextMessage(
            id: '1',
            content: 'Kajian rutin',
            category: 'Kajian',
            isActive: false,
          ),
        ],
      )),
    );
    await tester.pump();

    expect(find.text('Tidak ada informasi'), findsOneWidget);
  });

  testWidgets('Active messages show running marquee with badge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const RunningTextBar(
        messages: [
          RunningTextMessage(
            id: '1',
            content: 'Kajian rutin Subuh',
            category: 'Kajian',
          ),
        ],
      )),
    );
    await tester.pump();

    expect(find.text('INFORMASI'), findsOneWidget);
    expect(find.textContaining('Kajian rutin Subuh'), findsOneWidget);
    expect(find.text('Tidak ada informasi'), findsNothing);

    // Marquee runs inside a horizontal ListView.
    expect(find.byType(ListView), findsOneWidget);
  });
}

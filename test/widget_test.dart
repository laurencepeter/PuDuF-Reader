import 'package:flutter_test/flutter_test.dart';
import 'package:puduf_reader/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PuDuFApp());
    expect(find.byType(PuDuFApp), findsOneWidget);
  });
}

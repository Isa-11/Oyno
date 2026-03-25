import 'package:flutter_test/flutter_test.dart';
import 'package:oyno_sports/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OynoApp());
    expect(find.byType(OynoApp), findsOneWidget);
  });
}

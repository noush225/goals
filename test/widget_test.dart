import 'package:flutter_test/flutter_test.dart';
import 'package:goals/main.dart';

void main() {
  testWidgets('Counter increment smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoalsApp());

    // Verify that our app starts.
    expect(find.byType(GoalsApp), findsOneWidget);
  });
}

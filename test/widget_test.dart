import 'package:flutter_test/flutter_test.dart';
import 'package:src/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Smart Lamp'), findsOneWidget);
  });
}

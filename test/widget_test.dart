import 'package:flutter_test/flutter_test.dart';
import 'package:src/app.dart';

void main() {
  testWidgets('renders login title', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Smart Lamp'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

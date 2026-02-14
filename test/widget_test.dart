import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('MasrSpacesApp builds without crashing', (tester) async {
    await tester.pumpWidget(const MasrSpacesApp());
    await tester.pumpAndSettle();

    // Basic sanity: app renders something
    expect(find.byType(MasrSpacesApp), findsOneWidget);
  });
}

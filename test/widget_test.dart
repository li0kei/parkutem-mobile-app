import 'package:flutter_test/flutter_test.dart';
import 'package:parkutem_app/app.dart';

// =====================================================
// WIDGET TEST
// =====================================================

void main() {
  testWidgets('ParkUTeM app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkUTeMApp());

    expect(find.text('Smart Campus Parking'), findsOneWidget);
  });
}
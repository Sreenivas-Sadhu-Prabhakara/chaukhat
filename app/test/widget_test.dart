import 'package:flutter_test/flutter_test.dart';

import 'package:chaukhat_app/main.dart';

void main() {
  test('quote combines perimeter and area pricing', () {
    final q = quote(h: 40, w: 50, moldingRate: 120, glassRate: 800, mountRate: 300, labour: 150);
    expect(q.total, closeTo(586, 1e-9));
  });

  testWidgets('renders the itemised quote', (tester) async {
    await tester.pumpWidget(const ChaukhatApp());
    expect(find.text('Itemised quote'), findsOneWidget);
  });
}

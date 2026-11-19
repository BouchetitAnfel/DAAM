import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daam_app/main.dart';

void main() {
  testWidgets('DaamApp démarre sur l\'écran de chargement (splash)', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DaamApp()));
    await tester.pump();

    expect(find.text('DAAM'), findsOneWidget);
  });
}

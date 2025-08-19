// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_chatapp/app/app.dart';

void main() {
  testWidgets('App starts with home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: NixtioApp(),
      ),
    );

    // Verify that our app shows the greeting text.
    expect(find.text('Hi Nixtio, How can I help you today?'), findsOneWidget);
    
    // Verify that the feature cards are present.
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chatapp/features/scanner/presentation/pages/scanner_page.dart';

void main() {
  group('ScannerPage Widget Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: ScannerPage(),
        ),
      );
    }

    testWidgets('renders scanner page with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Document Scanner'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('shows help dialog when help icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap help icon
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Scanner Tips'), findsOneWidget);
      expect(find.text('Position the document within the guide lines for best results. '
          'Ensure good lighting and avoid shadows. '
          'The scanner will automatically detect edges and correct perspective.'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('shows correct app bar styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.black87));
      expect(appBar.foregroundColor, equals(Colors.white));
      expect(appBar.title, isA<Text>());
    });

    testWidgets('has black background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });

    testWidgets('renders scanner page without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // The page should render without throwing errors
      expect(find.byType(ScannerPage), findsOneWidget);
      
      // Should have required UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows circular progress indicator or permission error initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow one frame to pass

      // Since camera initialization might fail in test environment,
      // we should see either loading indicator or permission handling UI
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty || 
        find.text('Choose from Gallery').evaluate().isNotEmpty ||
        find.text('Try Camera').evaluate().isNotEmpty,
        isTrue,
      );
      
      // Pump and settle to allow any pending timers to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  group('EdgeDetectionOverlayPainter Tests', () {
    test('shouldRepaint returns false for same painter instance', () {
      final painter = EdgeDetectionOverlayPainter();
      expect(painter.shouldRepaint(painter), isFalse);
    });

    test('paint method does not throw errors', () {
      final painter = EdgeDetectionOverlayPainter();
      final canvas = MockCanvas();
      const size = Size(300, 400);

      // Should not throw
      expect(() => painter.paint(canvas, size), isNot(throwsA(anything)));
    });
  });
}

// Simple mock canvas for testing
class MockCanvas implements Canvas {
  @override
  void noSuchMethod(Invocation invocation) {
    // Do nothing - just prevent errors during testing
  }
}
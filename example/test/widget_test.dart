import 'package:flutter_test/flutter_test.dart';
import 'package:native_theme_mode_example/main.dart';

void main() {
  testWidgets('shows current theme mode and toggles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('native_theme_mode'), findsOneWidget);
    expect(find.textContaining('Current mode:'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });
}

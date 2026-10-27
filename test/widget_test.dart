import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/app/app.dart';
import 'package:inzar/app/di.dart';

void main() {
  setUp(() {
    setupServiceLocator();
  });

  testWidgets('Inzar App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const InzarApp());
    await tester.pumpAndSettle();

    expect(find.text('INZAR'), findsOneWidget);
    expect(find.text('+ Report'), findsOneWidget);
  });
}

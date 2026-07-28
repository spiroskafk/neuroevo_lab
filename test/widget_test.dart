import 'package:flutter_test/flutter_test.dart';
import 'package:neuroevo_lab/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NeuroEvoApp());
    expect(find.text('NeuroEvo Lab'), findsOneWidget);
    expect(find.text('Self-driving Cars'), findsOneWidget);
  });
}

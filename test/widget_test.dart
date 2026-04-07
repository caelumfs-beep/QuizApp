import 'package:flutter_test/flutter_test.dart';
import 'package:trad_reviewer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CFSQuizApp());
  });
}

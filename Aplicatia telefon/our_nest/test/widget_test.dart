import 'package:flutter_test/flutter_test.dart';
import 'package:our_nest/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OurNestAdminApp());
  });
}
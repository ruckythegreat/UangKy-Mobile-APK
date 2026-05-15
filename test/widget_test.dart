import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uangky/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('UangKy memuat layar utama', (tester) async {
    await tester.pumpWidget(const UangKyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Beranda'), findsWidgets);
  });
}

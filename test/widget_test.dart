import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_management_kh/core/localizations/language_controller.dart';
import 'package:business_management_kh/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  testWidgets('App boots up successfully with Khmer localization', (WidgetTester tester) async {
    final languageController = Get.put(LanguageController(), permanent: true);
    await languageController.initLanguage();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify MyApp is mounted and language controller is active
    expect(languageController.isKhmer, true);
  });
}

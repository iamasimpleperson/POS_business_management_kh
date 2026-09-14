import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_management_kh/core/localizations/app_translations.dart';
import 'package:business_management_kh/core/localizations/language_controller.dart';
import 'package:business_management_kh/core/localizations/translations/km_kh.dart';
import 'package:business_management_kh/core/localizations/translations/en_us.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  test('AppTranslations contains km_KH and en_US maps with valid keys', () {
    final translations = AppTranslations();
    final keys = translations.keys;

    expect(keys.containsKey('km_KH'), true);
    expect(keys.containsKey('en_US'), true);

    // Verify critical keys exist in both languages
    final commonKeys = [
      'nav_home',
      'nav_stock',
      'nav_sales',
      'nav_customer',
      'nav_more',
      'language',
      'select_language',
      'choose_preferred_language',
      'khmer',
      'english',
      'more_title',
      'sec_management',
      'sec_settings',
      'menu_staff',
      'menu_expenses',
      'menu_debts',
      'menu_suppliers',
      'menu_purchases',
      'menu_reports',
      'menu_language',
      'btn_logout',
      'logout_confirm_title',
      'logout_confirm_desc',
      'greeting',
      'welcome_dashboard',
      'low_stock_warning',
      'view_all',
      'quick_actions',
      'revenue_today',
      'revenue',
      'total_sales_today',
      'sales_on',
      'orders',
      'orders_unit',
      'customer_debts',
      'debtors_unit',
      'best_seller',
      'none_yet',
      'sold_qty',
      'items_low_stock',
      'default_city',
    ];

    for (final key in commonKeys) {
      expect(kmKH.containsKey(key), true, reason: 'kmKH missing $key');
      expect(enUS.containsKey(key), true, reason: 'enUS missing $key');
    }
  });

  test('LanguageController initializes with default Khmer', () async {
    final controller = LanguageController();
    await controller.initLanguage();

    expect(controller.currentLocale.value, const Locale('km', 'KH'));
    expect(controller.isKhmer, true);
    expect(controller.isEnglish, false);
    expect(controller.currentLanguageName, 'ភាសាខ្មែរ');
    expect(controller.currentFlag, '🇰🇭');
  });

  test('LanguageController loads English when saved in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});

    final controller = LanguageController();
    await controller.initLanguage();

    expect(controller.currentLocale.value, const Locale('en', 'US'));
    expect(controller.isKhmer, false);
    expect(controller.isEnglish, true);
    expect(controller.currentLanguageName, 'English');
    expect(controller.currentFlag, '🇬🇧');
  });
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.isRegistered<LanguageController>()
      ? Get.find<LanguageController>()
      : Get.put(LanguageController(), permanent: true);

  static const String _prefKey = 'selected_language';

  static const Locale khmerLocale = Locale('km', 'KH');
  static const Locale englishLocale = Locale('en', 'US');

  final Rx<Locale> currentLocale = khmerLocale.obs;

  bool get isKhmer => currentLocale.value.languageCode == 'km';
  bool get isEnglish => currentLocale.value.languageCode == 'en';

  String get currentLanguageName => isKhmer ? 'ភាសាខ្មែរ' : 'English';
  String get currentFlag => isKhmer ? '🇰🇭' : '🇬🇧';

  @override
  void onInit() {
    super.onInit();
    initLanguage();
  }

  Future<void> initLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode == 'en') {
        currentLocale.value = englishLocale;
      } else {
        currentLocale.value = khmerLocale;
      }
    } catch (e) {
      debugPrint('Error loading language preference: $e');
    }
  }

  Future<void> changeLanguage(String langCode) async {
    final newLocale = langCode == 'en' ? englishLocale : khmerLocale;
    currentLocale.value = newLocale;
    await Get.updateLocale(newLocale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_language'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'choose_preferred_language'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Khmer Option
                Obx(
                  () => _buildLanguageItem(
                    title: 'ភាសាខ្មែរ',
                    subtitle: 'Khmer',
                    flagEmoji: '🇰🇭',
                    isSelected: isKhmer,
                    onTap: () {
                      changeLanguage('km');
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // English Option
                Obx(
                  () => _buildLanguageItem(
                    title: 'English',
                    subtitle: 'អង់គ្លេស',
                    flagEmoji: '🇬🇧',
                    isSelected: isEnglish,
                    onTap: () {
                      changeLanguage('en');
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem({
    required String title,
    required String subtitle,
    required String flagEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(flagEmoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

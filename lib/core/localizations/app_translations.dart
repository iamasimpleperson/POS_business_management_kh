import 'package:get/get.dart';
import 'translations/km_kh.dart';
import 'translations/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'km_KH': kmKH,
        'en_US': enUS,
      };
}

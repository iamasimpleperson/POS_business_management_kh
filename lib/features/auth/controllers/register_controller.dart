import 'package:get/get.dart';
import '../auth_model/register_model.dart';
import '../../../services/api_service.dart';

class RegisterController extends GetxController {
  final model = RegisterModel();
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();
  var passwordWarning = RxnString();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void updateName(String value) => model.name = value;
  void updateEmail(String value) => model.email = value;
  void updatePhone(String value) => model.phone = value;
  void updatePassword(String value) {
    model.password = value;
    passwordWarning.value = _checkPasswordStrength(value);
  }

  String? _checkPasswordStrength(String password) {
    if (password.isEmpty) return null;
    if (password.length < 8) {
      return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរ';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return 'ពាក្យសម្ងាត់គួរតែរួមបញ្ចូលទាំងអក្សរ និងលេខ';
    }
    return null;
  }

  Future<bool> register() async {
    if (model.name.isEmpty || model.email.isEmpty || model.password.isEmpty) {
      errorMessage.value = 'សូមបំពេញព័ត៌មានចាំបាច់ទាំងអស់';
      return false;
    }

    if (model.password.length < 8) {
      errorMessage.value = 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរដើម្បីសុវត្ថិភាពខ្ពស់';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await ApiService.instance.register(
      name: model.name,
      email: model.email,
      password: model.password,
      phone: model.phone,
    );

    if (result.success) {
      // Automatically log in after registration
      await ApiService.instance.login(
        username: model.email,
        password: model.password,
      );
    }

    isLoading.value = false;
    errorMessage.value = result.success ? null : result.error;
    return result.success;
  }
}

import 'package:get/get.dart';
import '../auth_model/login_model.dart';
import '../../../services/api_service.dart';

class LoginController extends GetxController {
  final model = LoginModel();
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void updateEmail(String value) {
    model.username = value;
  }

  void updatePassword(String value) {
    model.password = value;
  }

  Future<bool> login() async {
    if (model.username.isEmpty || model.password.isEmpty) {
      errorMessage.value = 'សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await ApiService.instance.login(
      username: model.username,
      password: model.password,
    );

    isLoading.value = false;
    errorMessage.value = result.success ? null : result.error;

    return result.success;
  }
}

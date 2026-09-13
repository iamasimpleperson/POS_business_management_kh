import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_model/register_model.dart';

import '../../../services/api_service.dart';

class RegisterState {
  final RegisterModel model;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final String? passwordWarning;

  RegisterState({
    required this.model,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
    this.passwordWarning,
  });

  RegisterState copyWith({
    RegisterModel? model,
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    String? passwordWarning,
  }) {
    return RegisterState(
      model: model ?? this.model,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      passwordWarning: passwordWarning,
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return RegisterState(model: RegisterModel());
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void updateName(String value) => state.model.name = value;
  void updateEmail(String value) => state.model.email = value;
  void updatePhone(String value) => state.model.phone = value;
  void updatePassword(String value) {
    state.model.password = value;
    final warning = _checkPasswordStrength(value);
    state = state.copyWith(passwordWarning: warning);
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
    if (state.model.name.isEmpty || state.model.email.isEmpty || state.model.password.isEmpty) {
      state = state.copyWith(errorMessage: 'សូមបំពេញព័ត៌មានចាំបាច់ទាំងអស់');
      return false;
    }

    if (state.model.password.length < 8) {
      state = state.copyWith(
        errorMessage: 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរដើម្បីសុវត្ថិភាពខ្ពស់',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ApiService.instance.register(
      name: state.model.name,
      email: state.model.email,
      password: state.model.password,
      phone: state.model.phone,
    );

    if (result.success) {
      // Automatically log in after registration
      await ApiService.instance.login(
        username: state.model.email,
        password: state.model.password,
      );
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.error,
    );
    return result.success;
  }
}

final registerProvider = NotifierProvider<RegisterNotifier, RegisterState>(() {
  return RegisterNotifier();
});

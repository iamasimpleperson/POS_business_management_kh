import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_model/login_model.dart';
import '../../../services/api_service.dart';

class LoginState {
  final LoginModel model;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;

  LoginState({
    required this.model,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    LoginModel? model,
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      model: model ?? this.model,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    return LoginState(model: LoginModel());
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void updateEmail(String value) {
    state.model.username = value;
  }

  void updatePassword(String value) {
    state.model.password = value;
  }

  Future<bool> login() async {
    if (state.model.username.isEmpty || state.model.password.isEmpty) {
      state = state.copyWith(errorMessage: 'សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ApiService.instance.login(
      username: state.model.username,
      password: state.model.password,
    );

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.error,
    );

    return result.success;
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(() {
  return LoginNotifier();
});

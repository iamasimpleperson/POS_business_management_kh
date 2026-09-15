import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_management_kh/services/api_service.dart';
import 'package:business_management_kh/routes/app_route.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await ApiService.instance.logout();
  });

  group('Auth Persistence & Auto-Login Tests', () {
    test('tryAutoLogin returns false when SharedPreferences has no token', () async {
      SharedPreferences.setMockInitialValues({});
      final result = await ApiService.instance.tryAutoLogin();
      expect(result, false);
      expect(ApiService.instance.isAuthenticated, false);
    });

    test('logout clears both in-memory state and SharedPreferences storage', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'test_token_123',
        'current_business_id': 42,
      });

      ApiService.instance.setToken('test_token_123');
      ApiService.instance.setCurrentBusinessId(42);
      expect(ApiService.instance.isAuthenticated, true);

      await ApiService.instance.logout();

      expect(ApiService.instance.isAuthenticated, false);
      expect(ApiService.instance.token, isNull);
      expect(ApiService.instance.currentBusinessId, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getInt('current_business_id'), isNull);
    });

    test('AppRoute creates router with /home when user is logged in', () {
      final router = AppRoute.createRouter(initialLocation: '/home');
      expect(router.routeInformationProvider.value.uri.toString(), '/home');
    });

    test('AppRoute creates router with /login by default when not logged in', () {
      final router = AppRoute.createRouter(initialLocation: '/login');
      expect(router.routeInformationProvider.value.uri.toString(), '/login');
    });

    test('tryAutoLogin instantly restores cached user and business data from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'saved_jwt_xyz',
        'current_business_id': 99,
        'cached_user_data': '{"id":99,"name":"Vannak","email":"vannak@business.kh"}',
        'cached_business_data': '{"id":99,"name":"Vannak Mart","currency":"USD"}',
      });

      final success = await ApiService.instance.tryAutoLogin();
      expect(success, true);
      expect(ApiService.instance.isAuthenticated, true);
      expect(ApiService.instance.token, 'saved_jwt_xyz');
      expect(ApiService.instance.currentBusinessId, 99);
      expect(ApiService.instance.currentUser?['name'], 'Vannak');
      expect(ApiService.instance.currentBusiness?['name'], 'Vannak Mart');
    });
  });
}

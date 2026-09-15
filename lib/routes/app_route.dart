import 'package:get/get.dart';
import 'package:business_management_kh/routes/modules/auth_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:business_management_kh/routes/modules/home_routes.dart';
import 'package:business_management_kh/services/api_service.dart';

class AppRoute {
  static GoRouter? _router;

  static GoRouter get router => _router ??= createRouter();

  static GoRouter createRouter({String? initialLocation}) {
    final isAuth = ApiService.instance.isAuthenticated;
    final defaultLocation = initialLocation ?? (isAuth ? '/home' : '/login');

    _router = GoRouter(
      navigatorKey: Get.key,
      initialLocation: defaultLocation,
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) {
            return ApiService.instance.isAuthenticated ? '/home' : '/login';
          },
        ),
        ...homeRoutes,
        ...authRoutes,
      ],
      redirect: (context, state) {
        final authenticated = ApiService.instance.isAuthenticated;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/register';

        // Protected routes: redirect unauthenticated users to login
        if (!authenticated && !isAuthRoute) {
          return '/login';
        }

        // Auth routes: redirect already-authenticated users straight to home
        if (authenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
    );
    return _router!;
  }
}

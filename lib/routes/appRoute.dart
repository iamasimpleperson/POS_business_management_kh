import 'package:business_management_kh/routes/modules/auth_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:business_management_kh/routes/modules/home_routes.dart';

class AppRoute {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [...homeRoutes, ...authRoutes],
  );
}

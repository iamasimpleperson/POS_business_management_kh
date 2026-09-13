import 'package:business_management_kh/features/auth/auth_view/login_screen.dart';
import 'package:business_management_kh/features/auth/auth_view/register_screen.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    name: 'register',
    builder: (context, state) => const RegisterScreen(),
  ),
];

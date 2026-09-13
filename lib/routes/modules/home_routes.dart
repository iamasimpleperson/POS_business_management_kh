import 'package:go_router/go_router.dart';
import '../../features/home/home_views/home_screen.dart';

final List<RouteBase> homeRoutes = [
  GoRoute(
    path: '/home',
    name: 'home',
    builder: (context, state) => const HomeScreen(),
  ),
];

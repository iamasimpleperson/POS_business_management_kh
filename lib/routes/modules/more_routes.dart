import 'package:business_management_kh/features/more/more_view/more_view.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> moreRoutes = [
  GoRoute(
    path: '/MoreView',
    name: 'MoreView',
    builder: (context, state) => const MoreView(),
  ),
];

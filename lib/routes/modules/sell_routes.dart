import 'package:business_management_kh/features/sell/sell_view/sell_view.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> sellRoutes = [
  GoRoute(
    path: '/SellView',
    name: 'SellView',
    builder: (context, state) => const SellView(),
  ),
];

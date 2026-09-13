import 'package:business_management_kh/features/stock/stock_view/stock_view.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> stockRoutes = [
  GoRoute(
    path: '/StockView',
    name: 'StockView',
    builder: (context, state) => const StockView(),
  ),
];

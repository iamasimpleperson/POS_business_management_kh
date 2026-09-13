import 'package:business_management_kh/features/customer/customer_views/customer_view.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> customerRoutes = [
  GoRoute(
    path: '/CustomerView',
    name: 'CustomerView',
    builder: (context, state) => const CustomerView(),
  ),
];

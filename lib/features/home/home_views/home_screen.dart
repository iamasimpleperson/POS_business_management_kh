import 'package:business_management_kh/features/customer/customer_views/customer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_controller.dart';
import 'home_dashboard_view.dart';
import '../../stock/stock_view/stock_view.dart';
import '../../sales/sales_view/sales_view.dart';
import '../../more/more_view/more_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final controller = ref.read(homeProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: IndexedStack(
          index: state.currentIndex,
          children: const [
            HomeDashboardView(),
            StockView(),
            SalesView(),
            CustomerView(),
            MoreView(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.currentIndex,
        onTap: controller.setTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ដើម'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'ទំនិញ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'លក់',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'អតិថិជន',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'បន្ថែម',
          ),
        ],
      ),
    );
  }
}

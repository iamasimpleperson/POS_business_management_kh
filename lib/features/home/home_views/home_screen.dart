import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'home_dashboard_view.dart';
import '../../stock/controllers/stock_controller.dart';
import '../../stock/stock_view/stock_view.dart';
import '../../sales/controllers/sales_controller.dart';
import '../../sales/sales_view/sales_view.dart';
import '../../customer/customer_controllers/customer_controller.dart';
import '../../customer/customer_views/customer_view.dart';
import '../../more/more_view/more_view.dart';
import '../../../core/localizations/language_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    // Eagerly put other feature controllers so they're available
    Get.put(StockController());
    Get.put(SalesController());
    Get.put(CustomerController());
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController(), permanent: true);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeDashboardView(),
              StockView(),
              SalesView(),
              CustomerView(),
              MoreView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        // Observe language change so navigation labels re-render immediately
        LanguageController.to.currentLocale.value;
        return BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.setTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'nav_home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              label: 'nav_stock'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: 'nav_sales'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              label: 'nav_customer'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz),
              label: 'nav_more'.tr,
            ),
          ],
        );
      }),
    );
  }
}

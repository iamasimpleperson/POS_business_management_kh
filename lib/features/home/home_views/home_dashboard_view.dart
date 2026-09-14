import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../home_model/home_model.dart';
import '../widgets/dashboard_date_picker.dart';
import '../../../core/localizations/language_controller.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      // Observe language change
      LanguageController.to.currentLocale.value;
      if (controller.homeData.value == null && controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        );
      }

      final data = controller.homeData.value ??
          HomeDataModel(
            shop: ShopModel(name: 'ABC Coffee Shop', location: 'ភ្នំពេញ'),
            stats: [],
            lowStockCount: 0,
            quickActions: [],
          );

      return RefreshIndicator(
        color: const Color(0xFF2E7D32),
        onRefresh: () => controller.loadDashboardData(showLoading: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isRefreshing.value)
                const LinearProgressIndicator(
                  minHeight: 2.5,
                  color: Color(0xFF2E7D32),
                  backgroundColor: Color(0xFFE8F5E9),
                ),
          // App Bar Area (Menu + Language + Notification)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () {},
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => LanguageController.to.showLanguageBottomSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LanguageController.to.currentFlag,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            LanguageController.to.isKhmer ? 'ខ្មែរ' : 'EN',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting
          Text(
            '${'greeting'.tr}, ${data.shop.name} 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'welcome_dashboard'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Shop Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // CircleAvatar(
                //   child: Image.network(
                //     data.shop.image ?? '',
                //     fit: BoxFit.cover,
                //     errorBuilder: (context, error, stackTrace) {
                //       return const Icon(Icons.store, size: 24);
                //     },
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.shop.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.shop.location.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Picker Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DashboardDatePickerWidget(
                initialDate: controller.selectedDate.value,
                onDateSelected: (date) {
                  controller.onDateChanged(date);
                },
              ),
              if (controller.isRefreshing.value)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: data.stats.length,
            itemBuilder: (context, index) {
              final stat = data.stats[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: stat.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(stat.icon, size: 18, color: stat.color),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stat.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.amount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.percentageText,
                      style: TextStyle(
                        fontSize: 11,
                        color: stat.isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Low Stock Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Light amber
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'low_stock_warning'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'items_low_stock'.trParams({'count': '${data.lowStockCount}'}),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'view_all'.tr,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF2E7D32),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Title
          Text(
            'quick_actions'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.quickActions.map((action) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: action.bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(action.icon, color: action.color, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.title.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
});
  }
}

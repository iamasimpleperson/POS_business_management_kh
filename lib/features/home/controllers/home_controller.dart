import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_model/home_model.dart';
import '../../../services/api_service.dart';

class HomeState {
  final HomeDataModel? homeData;
  final bool isLoading;
  final int currentIndex;

  HomeState({
    this.homeData,
    this.isLoading = true,
    this.currentIndex = 0,
  });

  HomeState copyWith({
    HomeDataModel? homeData,
    bool? isLoading,
    int? currentIndex,
  }) {
    return HomeState(
      homeData: homeData ?? this.homeData,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(() => loadDashboardData());
    return HomeState();
  }

  void setTabIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// Load live analytics from backend API
  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true);

    if (ApiService.instance.isAuthenticated) {
      final dashboardRes = await ApiService.instance.getDashboard();
      
      String shopName = 'ABC Coffee Shop';
      String shopLocation = 'ផ្លូវ 271, ភ្នំពេញ';
      String shopLogo = '';

      // Check current business profile from API
      if (ApiService.instance.currentBusiness != null) {
        final biz = ApiService.instance.currentBusiness!;
        if (biz['name'] != null && biz['name'].toString().isNotEmpty) {
          shopName = biz['name'].toString();
        }
        if (biz['address'] != null && biz['address'].toString().isNotEmpty) {
          shopLocation = biz['address'].toString();
        }
        if (biz['logo'] != null) {
          shopLogo = biz['logo'].toString();
        }
      } else if (ApiService.instance.currentUser != null) {
        final user = ApiService.instance.currentUser!;
        if (user['name'] != null && user['name'].toString().isNotEmpty) {
          shopName = user['name'].toString();
        }
      }

      if (dashboardRes.success && dashboardRes.data != null) {
        final data = dashboardRes.data!;

        final todaySales = data['today_sales']?.toString() ?? '0';
        final newOrders = data['new_orders_count']?.toString() ?? '0';
        final totalDebt = data['total_debt']?.toString() ?? '0';
        final debtCustomerCount = data['debt_customer_count']?.toString() ?? '0';
        final bestSellerName = data['best_seller_name']?.toString() ?? 'មិនទាន់មាន';
        final bestSellerQty = data['best_seller_qty']?.toString() ?? '0';
        final lowStock = int.tryParse(data['low_stock_count']?.toString() ?? '0') ?? 0;

        final shop = ShopModel(
          name: shopName,
          location: shopLocation,
          logoUrl: shopLogo,
        );

        final stats = [
          StatModel(
            title: 'ចំណូលថ្ងៃនេះ',
            amount: '\$$todaySales',
            percentageText: 'ការលក់សរុបថ្ងៃនេះ',
            isPositive: true,
            icon: Icons.attach_money,
            color: const Color(0xFF2E7D32),
          ),
          StatModel(
            title: 'ការបញ្ជាទិញថ្មី',
            amount: newOrders,
            percentageText: 'ការបញ្ជាទិញសរុប',
            isPositive: true,
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFF1976D2),
          ),
          StatModel(
            title: 'បំណុលអតិថិជន',
            amount: '\$$totalDebt',
            percentageText: '$debtCustomerCount នាក់ជំពាក់',
            isPositive: false,
            icon: Icons.people_outline,
            color: const Color(0xFFF57C00),
          ),
          StatModel(
            title: 'ទំនិញលក់ដាច់',
            amount: bestSellerName,
            percentageText: '$bestSellerQty ចំនួនលក់',
            isPositive: true,
            icon: Icons.local_cafe_outlined,
            color: const Color(0xFFC2185B),
          ),
        ];

        final quickActions = [
          QuickActionModel(
            title: 'លក់',
            icon: Icons.shopping_cart_outlined,
            bgColor: const Color(0xFFE8F5E9),
            color: const Color(0xFF2E7D32),
          ),
          QuickActionModel(
            title: 'ទំនិញ',
            icon: Icons.inventory_2_outlined,
            bgColor: const Color(0xFFE3F2FD),
            color: const Color(0xFF1976D2),
          ),
          QuickActionModel(
            title: 'ចំណាយ',
            icon: Icons.money_off_outlined,
            bgColor: const Color(0xFFFFF3E0),
            color: const Color(0xFFF57C00),
          ),
          QuickActionModel(
            title: 'របាយការណ៍',
            icon: Icons.bar_chart_outlined,
            bgColor: const Color(0xFFF3E5F5),
            color: const Color(0xFF7B1FA2),
          ),
        ];

        final dashboard = DashboardResponse.fromJson(data);

        state = state.copyWith(
          isLoading: false,
          homeData: HomeDataModel(
            shop: shop,
            stats: stats,
            lowStockCount: lowStock,
            quickActions: quickActions,
            apiDashboard: dashboard,
          ),
        );
        return;
      }
    }

    // Fallback if not logged in or offline
    await loadMockData();
  }

  Future<void> loadMockData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final shop = ShopModel(
      name: 'ABC Coffee Shop',
      location: 'ផ្លូវ 271, ភ្នំពេញ',
    );

    final stats = [
      StatModel(
        title: 'ចំណូលសរុប',
        amount: '\$1,250.00',
        percentageText: '+15% ធៀបខែមុន',
        isPositive: true,
        icon: Icons.attach_money,
        color: const Color(0xFF2E7D32),
      ),
      StatModel(
        title: 'ការបញ្ជាទិញថ្មី',
        amount: '45',
        percentageText: '+5% ថ្ងៃនេះ',
        isPositive: true,
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF1976D2),
      ),
      StatModel(
        title: 'អតិថិជនសរុប',
        amount: '1,204',
        percentageText: '+12 នាក់ថ្ងៃនេះ',
        isPositive: true,
        icon: Icons.people_outline,
        color: const Color(0xFFF57C00),
      ),
      StatModel(
        title: 'ទំនិញលក់ដាច់',
        amount: 'កាហ្វេទឹកដោះគោ',
        percentageText: '85 កែវ',
        isPositive: true,
        icon: Icons.local_cafe_outlined,
        color: const Color(0xFFC2185B),
      ),
    ];

    final quickActions = [
      QuickActionModel(
        title: 'លក់',
        icon: Icons.shopping_cart_outlined,
        bgColor: const Color(0xFFE8F5E9),
        color: const Color(0xFF2E7D32),
      ),
      QuickActionModel(
        title: 'ទំនិញ',
        icon: Icons.inventory_2_outlined,
        bgColor: const Color(0xFFE3F2FD),
        color: const Color(0xFF1976D2),
      ),
      QuickActionModel(
        title: 'ចំណាយ',
        icon: Icons.money_off_outlined,
        bgColor: const Color(0xFFFFF3E0),
        color: const Color(0xFFF57C00),
      ),
      QuickActionModel(
        title: 'របាយការណ៍',
        icon: Icons.bar_chart_outlined,
        bgColor: const Color(0xFFF3E5F5),
        color: const Color(0xFF7B1FA2),
      ),
    ];

    final homeData = HomeDataModel(
      shop: shop,
      stats: stats,
      quickActions: quickActions,
      lowStockCount: 12,
    );

    state = state.copyWith(
      homeData: homeData,
      isLoading: false,
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() => HomeNotifier());

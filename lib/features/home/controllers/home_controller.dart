import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_model/home_model.dart';
import '../../../services/api_service.dart';
import '../../sales/sales_model/sales_model.dart';
import '../../../models/product_model.dart' as api_models;
import '../../../core/localizations/language_controller.dart';

class HomeController extends GetxController {
  var homeData = Rxn<HomeDataModel>();
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var currentIndex = 0.obs;
  var selectedDate = DateTime.now().obs;

  var allSales = <SaleResponse>[].obs;
  var allProducts = <api_models.ProductModel>[].obs;
  Map<String, dynamic>? _lastDashboardRaw;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    // Reactively refresh dashboard stats when language changes
    ever(LanguageController.to.currentLocale, (_) {
      _updateStatsForDate(selectedDate.value);
    });
  }

  void setTabIndex(int index) {
    currentIndex.value = index;
    if (index == 0) {
      loadDashboardData(showLoading: false);
    }
  }

  /// Handle when user selects a different date in the dashboard
  void onDateChanged(DateTime date) {
    selectedDate.value = date;
    // Instantly update stats for that date in memory (0ms)
    _updateStatsForDate(date);
    // And refresh latest data in background without blocking UI
    loadDashboardData(showLoading: false);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  ShopModel _getShopInfo() {
    String shopName = 'ABC Coffee Shop';
    String shopLocation = 'default_city'.tr;
    String shopLogo = '';

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

    return ShopModel(
      name: shopName,
      location: shopLocation,
      logoUrl: shopLogo,
    );
  }

  List<QuickActionModel> get _quickActions => [
        QuickActionModel(
          title: 'nav_sales'.tr,
          icon: Icons.shopping_cart_outlined,
          bgColor: const Color(0xFFE8F5E9),
          color: const Color(0xFF2E7D32),
        ),
        QuickActionModel(
          title: 'nav_stock'.tr,
          icon: Icons.inventory_2_outlined,
          bgColor: const Color(0xFFE3F2FD),
          color: const Color(0xFF1976D2),
        ),
        QuickActionModel(
          title: 'menu_expenses'.tr,
          icon: Icons.money_off_outlined,
          bgColor: const Color(0xFFFFF3E0),
          color: const Color(0xFFF57C00),
        ),
        QuickActionModel(
          title: 'menu_reports'.tr,
          icon: Icons.bar_chart_outlined,
          bgColor: const Color(0xFFF3E5F5),
          color: const Color(0xFF7B1FA2),
        ),
      ];

  /// Recalculate dashboard stats to match the given date
  void _updateStatsForDate(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final daySales = allSales
        .where((s) => s.saleDate != null && _isSameDay(s.saleDate!, date))
        .toList();

    // 1. Calculate sales amount for the day
    double daySalesAmount = daySales.fold<double>(
      0.0,
      (sum, s) => sum + s.totalAmount,
    );

    int ordersCount = daySales.length;

    // Fallback to dashboard raw data if today and local list is empty
    if (isToday && daySales.isEmpty && _lastDashboardRaw != null) {
      final rawToday = double.tryParse(_lastDashboardRaw!['today_sales']?.toString() ?? '0') ?? 0.0;
      if (rawToday > 0) daySalesAmount = rawToday;
      final rawOrders = int.tryParse(_lastDashboardRaw!['new_orders_count']?.toString() ?? '0') ?? 0;
      if (rawOrders > 0) ordersCount = rawOrders;
    }

    // 2. Best seller for that day
    final Map<int, double> productQtyMap = {};
    for (final s in daySales) {
      for (final item in s.items) {
        if (item.productId != null) {
          productQtyMap[item.productId!] =
              (productQtyMap[item.productId!] ?? 0) + item.quantity;
        }
      }
    }

    String bestSellerName = 'none_yet'.tr;
    String bestSellerQty = '0';

    if (productQtyMap.isNotEmpty) {
      int? topId;
      double maxQty = 0;
      productQtyMap.forEach((pId, qty) {
        if (qty > maxQty) {
          maxQty = qty;
          topId = pId;
        }
      });
      if (topId != null) {
        final found = allProducts.firstWhereOrNull((p) => p.id == topId);
        bestSellerName = found?.name ?? '${'nav_stock'.tr} #$topId';
        bestSellerQty = maxQty.toInt().toString();
      }
    } else if (isToday && _lastDashboardRaw != null) {
      bestSellerName = _lastDashboardRaw!['best_seller_name']?.toString() ?? 'none_yet'.tr;
      bestSellerQty = _lastDashboardRaw!['best_seller_qty']?.toString() ?? '0';
    }

    // 3. Customer Debt
    final totalDebt = _lastDashboardRaw?['total_debt']?.toString() ?? '0.00';
    final debtCustomerCount =
        _lastDashboardRaw?['debt_customer_count']?.toString() ?? '0';
    final lowStock =
        int.tryParse(_lastDashboardRaw?['low_stock_count']?.toString() ?? '0') ?? 0;

    final salesTitle = isToday ? 'revenue_today'.tr : '${'revenue'.tr} (${date.day}/${date.month})';
    final salesSubtitle = isToday
        ? 'total_sales_today'.tr
        : '${'sales_on'.tr} ${date.day}/${date.month}/${date.year}';

    final stats = [
      StatModel(
        title: salesTitle,
        amount: '\$${daySalesAmount.toStringAsFixed(2)}',
        percentageText: salesSubtitle,
        isPositive: true,
        icon: Icons.attach_money,
        color: const Color(0xFF2E7D32),
      ),
      StatModel(
        title: 'orders'.tr,
        amount: '$ordersCount',
        percentageText: '$ordersCount ${'orders_unit'.tr}',
        isPositive: true,
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF1976D2),
      ),
      StatModel(
        title: 'customer_debts'.tr,
        amount: '\$$totalDebt',
        percentageText: '$debtCustomerCount ${'debtors_unit'.tr}',
        isPositive: false,
        icon: Icons.people_outline,
        color: const Color(0xFFF57C00),
      ),
      StatModel(
        title: 'best_seller'.tr,
        amount: bestSellerName == 'មិនទាន់មាន' ? 'none_yet'.tr : bestSellerName,
        percentageText: '$bestSellerQty ${'sold_qty'.tr}',
        isPositive: true,
        icon: Icons.local_cafe_outlined,
        color: const Color(0xFFC2185B),
      ),
    ];

    homeData.value = HomeDataModel(
      shop: _getShopInfo(),
      stats: stats,
      lowStockCount: lowStock,
      quickActions: _quickActions,
      apiDashboard: _lastDashboardRaw != null
          ? DashboardResponse.fromJson(_lastDashboardRaw!)
          : null,
    );
  }

  /// Load live analytics from backend API with parallel requests and non-blocking background refresh
  Future<void> loadDashboardData({bool showLoading = true}) async {
    if (homeData.value == null && showLoading) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }

    if (!ApiService.instance.isAuthenticated) {
      _updateStatsForDate(selectedDate.value);
      isLoading.value = false;
      isRefreshing.value = false;
      return;
    }

    try {
      // Execute network requests in parallel for maximum speed
      final responses = await Future.wait([
        ApiService.instance.getDashboard(),
        ApiService.instance.getSales(limit: 100),
        ApiService.instance.getProducts(),
      ]);

      final dashboardRes = responses[0] as ApiResponse<Map<String, dynamic>>;
      final salesRes = responses[1] as ApiResponse<List<SaleResponse>>;
      final productsRes = responses[2] as ApiResponse<List<api_models.ProductModel>>;

      if (dashboardRes.success && dashboardRes.data != null) {
        _lastDashboardRaw = dashboardRes.data!;
      }

      if (salesRes.success && salesRes.data != null) {
        allSales.assignAll(salesRes.data!);
      }

      if (productsRes.success && productsRes.data != null) {
        allProducts.assignAll(productsRes.data!);
      }

      // Recompute stats for the currently selected date
      _updateStatsForDate(selectedDate.value);
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (homeData.value == null) {
        _updateStatsForDate(selectedDate.value);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
}

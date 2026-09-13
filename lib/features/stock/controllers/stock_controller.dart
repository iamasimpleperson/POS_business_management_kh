import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../stock_model/stock_model.dart';
import '../../../models/product_model.dart' as api_models;
import '../../../services/api_service.dart';

class StockController extends GetxController {
  static const List<Map<String, Color>> _categoryPalettes = [
    {'bg': Color(0xFFE8F5E9), 'text': Color(0xFF2E7D32)},
    {'bg': Color(0xFFE3F2FD), 'text': Color(0xFF1565C0)},
    {'bg': Color(0xFFFFF3E0), 'text': Color(0xFFE65100)},
    {'bg': Color(0xFFF3E5F5), 'text': Color(0xFF7B1FA2)},
    {'bg': Color(0xFFFFEBEE), 'text': Color(0xFFC62828)},
    {'bg': Color(0xFFE0F7FA), 'text': Color(0xFF00838F)},
    {'bg': Color(0xFFFFF8E1), 'text': Color(0xFFF57F17)},
  ];

  var allProducts = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var stats = <ProductStatModel>[].obs;
  var categories = <ProductCategoryModel>[].obs;
  var isLoading = true.obs;
  var selectedFilterTabIndex = 0.obs;
  var searchQuery = ''.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void setFilterTab(int index) {
    selectedFilterTabIndex.value = index;
    _applyFilter();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    List<ProductModel> list = allProducts.toList();

    // 1. Tab filter
    if (selectedFilterTabIndex.value == 1) {
      list = list
          .where((p) => p.status == 'low_stock' || (p.stock <= 15 && p.stock > 0))
          .toList();
    } else if (selectedFilterTabIndex.value == 2) {
      list = list
          .where((p) => p.status == 'out_of_stock' || p.stock == 0)
          .toList();
    } else if (selectedFilterTabIndex.value == 3) {
      list = list.where((p) => p.status == 'inactive').toList();
    }

    // 2. Search query filter
    final cleanQuery = searchQuery.value.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      list = list.where((p) {
        final nameMatch = p.name.toLowerCase().contains(cleanQuery);
        final codeMatch = p.code.toLowerCase().contains(cleanQuery);
        final catMatch = p.category.name.toLowerCase().contains(cleanQuery);
        return nameMatch || codeMatch || catMatch;
      }).toList();
    }

    filteredProducts.assignAll(list);
  }

  /// Load live products and categories directly from backend database API
  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (!ApiService.instance.isAuthenticated) {
      isLoading.value = false;
      errorMessage.value = 'សូមចូលគណនីដើម្បីមើលទិន្នន័យស្តុក';
      allProducts.clear();
      filteredProducts.clear();
      stats.assignAll(_generateStats(0, 0, 0, 0));
      return;
    }

    try {
      // 1. Fetch categories from database
      final catResponse = await ApiService.instance.getCategories();
      final Map<int, ProductCategoryModel> categoryMap = {};
      final List<ProductCategoryModel> loadedCategories = [];

      if (catResponse.success && catResponse.data != null) {
        for (int i = 0; i < catResponse.data!.length; i++) {
          final cat = catResponse.data![i];
          final palette = _categoryPalettes[i % _categoryPalettes.length];
          final catModel = ProductCategoryModel(
            id: cat.id,
            name: cat.name,
            bgColor: palette['bg']!,
            textColor: palette['text']!,
          );
          categoryMap[cat.id] = catModel;
          loadedCategories.add(catModel);
        }
      }

      final defaultCategory = ProductCategoryModel(
        id: null,
        name: 'ទូទៅ',
        bgColor: const Color(0xFFE8F5E9),
        textColor: const Color(0xFF2E7D32),
      );

      // 2. Fetch products from database
      final response = await ApiService.instance.getProducts(includeInactive: true);

      if (response.success && response.data != null) {
        final apiProducts = response.data!;

        final mappedProducts = apiProducts.map((p) {
          String status = 'all';
          if (p.status == api_models.ProductStatus.inactive) {
            status = 'inactive';
          } else if (p.stockQty <= 0) {
            status = 'out_of_stock';
          } else if (p.stockQty <= 15) {
            status = 'low_stock';
          }

          final cat = (p.categoryId != null && categoryMap.containsKey(p.categoryId))
              ? categoryMap[p.categoryId]!
              : defaultCategory;

          return ProductModel(
            id: p.id.toString(),
            name: p.name,
            code: (p.sku != null && p.sku!.isNotEmpty)
                ? p.sku!
                : ((p.barcode != null && p.barcode!.isNotEmpty)
                    ? p.barcode!
                    : 'PROD-${p.id}'),
            category: cat,
            stock: p.stockQty.toInt(),
            price: p.sellPrice,
            costPrice: p.costPrice,
            status: status,
            unit: p.unit,
            image: p.image,
          );
        }).toList();

        final totalCount = mappedProducts.length;
        final lowStockCount = mappedProducts
            .where((p) => p.status != 'inactive' && p.stock > 0 && p.stock <= 15)
            .length;
        final outOfStockCount = mappedProducts
            .where((p) => p.status != 'inactive' && p.stock <= 0)
            .length;
        final inactiveCount =
            mappedProducts.where((p) => p.status == 'inactive').length;

        stats.assignAll(_generateStats(
          totalCount,
          lowStockCount,
          outOfStockCount,
          inactiveCount,
        ));

        categories.assignAll(loadedCategories);
        allProducts.assignAll(mappedProducts);
        _applyFilter();
      } else {
        errorMessage.value = response.error ?? 'មិនអាចទាញយកទិន្នន័យទំនិញបានទេ';
        allProducts.clear();
        filteredProducts.clear();
        stats.assignAll(_generateStats(0, 0, 0, 0));
      }
    } catch (e) {
      errorMessage.value = 'កំហុសក្នុងការភ្ជាប់ទៅកាន់ទិន្នន័យ: $e';
      allProducts.clear();
      filteredProducts.clear();
      stats.assignAll(_generateStats(0, 0, 0, 0));
    } finally {
      isLoading.value = false;
    }
  }

  List<ProductStatModel> _generateStats(
    int total,
    int lowStock,
    int outOfStock,
    int inactive,
  ) {
    return [
      ProductStatModel(
        title: 'សរុប',
        count: total,
        subtitle: 'មុខទំនិញ',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF4CAF50),
      ),
      ProductStatModel(
        title: 'ស្តុកទាប',
        count: lowStock,
        subtitle: 'ទំនិញ',
        icon: Icons.layers_outlined,
        color: const Color(0xFFFF9800),
      ),
      ProductStatModel(
        title: 'អស់',
        count: outOfStock,
        subtitle: 'ទំនិញ',
        icon: Icons.trending_down_outlined,
        color: const Color(0xFF2196F3),
      ),
      ProductStatModel(
        title: 'បិទ',
        count: inactive,
        subtitle: 'ទំនិញ',
        icon: Icons.lock_outline,
        color: Colors.grey,
      ),
    ];
  }

  /// Create a new product in the database
  Future<bool> createProduct({
    required String name,
    required double sellPrice,
    double costPrice = 0.0,
    double stockQty = 0.0,
    String? sku,
    String? barcode,
    String? unit,
    int? categoryId,
  }) async {
    final productCreate = api_models.ProductCreate(
      name: name,
      sellPrice: sellPrice,
      costPrice: costPrice,
      stockQty: stockQty,
      sku: sku,
      barcode: barcode,
      unit: unit,
      categoryId: categoryId,
    );

    final res = await ApiService.instance.createProduct(product: productCreate);
    if (res.success) {
      await loadProducts();
      return true;
    }
    return false;
  }

  /// Adjust stock quantity for a product in the database
  Future<bool> adjustStock({
    required int productId,
    required double quantity,
    required String note,
  }) async {
    final adjustment = api_models.StockAdjustmentCreate(
      productId: productId,
      quantity: quantity,
      note: note,
    );

    final res = await ApiService.instance.adjustStock(adjustment: adjustment);
    if (res.success) {
      await loadProducts();
      return true;
    }
    return false;
  }

  /// Delete a product from the database
  Future<bool> deleteProduct(int productId) async {
    final res = await ApiService.instance.deleteProduct(productId: productId);
    if (res.success) {
      await loadProducts();
      return true;
    }
    return false;
  }

  StockState get state => StockState(
        allProducts: allProducts,
        filteredProducts: filteredProducts,
        stats: stats,
        categories: categories,
        isLoading: isLoading.value,
        selectedFilterTabIndex: selectedFilterTabIndex.value,
        searchQuery: searchQuery.value,
        errorMessage: errorMessage.value,
      );
}

typedef StockNotifier = StockController;

class StockState {
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final List<ProductStatModel> stats;
  final List<ProductCategoryModel> categories;
  final bool isLoading;
  final int selectedFilterTabIndex;
  final String searchQuery;
  final String? errorMessage;

  const StockState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.stats = const [],
    this.categories = const [],
    this.isLoading = true,
    this.selectedFilterTabIndex = 0,
    this.searchQuery = '',
    this.errorMessage,
  });
}

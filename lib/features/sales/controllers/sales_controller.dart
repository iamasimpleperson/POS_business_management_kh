import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stock/stock_model/stock_model.dart';
import '../sales_model/sales_model.dart';
import '../../../services/api_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../customer/customer_controllers/customer_controller.dart';

class SalesController extends GetxController {
  var allProducts = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var categories = <ProductCategoryModel>[].obs;
  var selectedCategory = Rxn<ProductCategoryModel>();
  var searchQuery = ''.obs;
  var cartItems = <CartItemModel>[].obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var selectedPaymentMethod = 'CASH'.obs;
  var selectedCustomerId = RxnInt();
  var discountAmount = 0.0.obs;
  var errorMessage = RxnString();

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discount => discountAmount.value;
  double get grandTotal {
    final total = subtotal - discount;
    return total > 0 ? total : 0.0;
  }
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void addToCart(ProductModel product) {
    final index = cartItems.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      cartItems[index] = cartItems[index].copyWith(quantity: cartItems[index].quantity + 1);
    } else {
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((i) => i.product.id == productId);
  }

  void updateQuantity(String productId, int delta) {
    final index = cartItems.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      final newQuantity = cartItems[index].quantity + delta;
      if (newQuantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    discountAmount.value = 0.0;
    selectedCustomerId.value = null;
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void setCustomer(int? customerId) {
    selectedCustomerId.value = customerId;
  }

  void setDiscount(double discount) {
    discountAmount.value = discount;
  }

  void selectCategory(ProductCategoryModel? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = allProducts.toList();

    if (selectedCategory.value != null &&
        selectedCategory.value!.name != 'ទាំងអស់') {
      filtered = filtered
          .where((p) => p.category.name == selectedCategory.value!.name)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.code.toLowerCase().contains(q))
          .toList();
    }

    filteredProducts.assignAll(filtered);
  }

  /// Load live products and categories from backend API
  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (!ApiService.instance.isAuthenticated) {
      isLoading.value = false;
      allProducts.clear();
      filteredProducts.clear();
      return;
    }

    try {
      // 1. Categories
      final catResponse = await ApiService.instance.getCategories();
      final Map<int, ProductCategoryModel> categoryMap = {};
      final List<ProductCategoryModel> loadedCategories = [
        ProductCategoryModel(
          name: 'ទាំងអស់',
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
        ),
      ];

      if (catResponse.success && catResponse.data != null) {
        for (final cat in catResponse.data!) {
          final catModel = ProductCategoryModel(
            id: cat.id,
            name: cat.name,
            bgColor: const Color(0xFFF1F8E9),
            textColor: const Color(0xFF2E7D32),
          );
          categoryMap[cat.id] = catModel;
          loadedCategories.add(catModel);
        }
      }

      final defaultCategory = loadedCategories.first;

      // 2. Products (active only)
      final prodResponse =
          await ApiService.instance.getProducts(includeInactive: false);

      if (prodResponse.success && prodResponse.data != null) {
        final products = prodResponse.data!.map((p) {
          final cat = (p.categoryId != null && categoryMap.containsKey(p.categoryId))
              ? categoryMap[p.categoryId]!
              : defaultCategory;

          return ProductModel(
            id: p.id.toString(),
            name: p.name,
            code: p.sku?.isNotEmpty == true
                ? p.sku!
                : (p.barcode?.isNotEmpty == true ? p.barcode! : 'PROD-${p.id}'),
            category: cat,
            stock: p.stockQty.toInt(),
            price: p.sellPrice,
            costPrice: p.costPrice,
            status: p.stockQty <= 0 ? 'out_of_stock' : 'all',
            unit: p.unit,
            image: p.image,
          );
        }).toList();

        categories.assignAll(loadedCategories);
        selectedCategory.value = loadedCategories.first;
        allProducts.assignAll(products);
        _applyFilters();
      } else {
        errorMessage.value = prodResponse.error;
      }
    } catch (e) {
      errorMessage.value = 'មានបញ្ហាក្នុងការទាញយកទិន្នន័យ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Create sale checkout
  Future<SaleResponse?> checkout({
    int? customerId,
    String? paymentMethod,
    double? customPaidAmount,
    String? customInvoiceNo,
    bool saveAsDraft = false,
  }) async {
    if (cartItems.isEmpty) {
      errorMessage.value = 'សូមជ្រើសរើសទំនិញដាក់ចូលក្នុងកន្ត្រកជាមុនសិន';
      return null;
    }

    isSubmitting.value = true;
    errorMessage.value = null;

    // Ensure business ID exists
    if (ApiService.instance.currentBusinessId == null) {
      await ApiService.instance.fetchUserBusinesses();
    }
    final businessId = ApiService.instance.currentBusinessId;
    if (businessId == null) {
      isSubmitting.value = false;
      errorMessage.value = 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)';
      return null;
    }

    final selectedMethod = paymentMethod ?? selectedPaymentMethod.value;
    final total = grandTotal;
    final paid = customPaidAmount ??
        (selectedMethod == 'DEBT' ? 0.0 : total);

    final saleItems = cartItems.map((item) {
      final pId = int.tryParse(item.product.id) ?? 0;
      return SaleItemCreate(
        productId: pId,
        quantity: item.quantity.toDouble(),
        price: item.product.price,
        discount: 0.0,
      );
    }).toList();

    final invoice = customInvoiceNo ??
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final saleCreate = SaleCreate(
      businessId: businessId,
      customerId: customerId ?? selectedCustomerId.value,
      invoiceNo: invoice,
      discountAmount: discountAmount.value,
      paidAmount: paid,
      paymentMethod: selectedMethod,
      saleDate: DateTime.now(),
      saveAsDraft: saveAsDraft,
      items: saleItems,
    );

    try {
      final response = await ApiService.instance.createSale(
        businessId: businessId,
        sale: saleCreate,
      );
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        clearCart();
        // Refresh product stocks in background
        loadProducts();

        // Refresh dashboard data immediately!
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadDashboardData();
        }

        // Refresh customer data so their totalSpent & active status update!
        if (Get.isRegistered<CustomerController>()) {
          Get.find<CustomerController>().loadCustomers(showLoading: false);
        }

        return response.data;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការបង្កើតការលក់';
        return null;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុសក្នុងការលក់: $e';
      return null;
    }
  }
}

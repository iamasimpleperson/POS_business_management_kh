import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stock/stock_model/stock_model.dart';
import '../sales_model/sales_model.dart';
import '../../../services/api_service.dart';

class SalesState {
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final List<ProductCategoryModel> categories;
  final ProductCategoryModel? selectedCategory;
  final String searchQuery;
  final List<CartItemModel> cartItems;
  final bool isLoading;
  final bool isSubmitting;
  final String selectedPaymentMethod;
  final int? selectedCustomerId;
  final double discountAmount;
  final String? errorMessage;

  SalesState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.cartItems = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.selectedPaymentMethod = 'CASH',
    this.selectedCustomerId,
    this.discountAmount = 0.0,
    this.errorMessage,
  });

  SalesState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    List<ProductCategoryModel>? categories,
    ProductCategoryModel? selectedCategory,
    String? searchQuery,
    List<CartItemModel>? cartItems,
    bool? isLoading,
    bool? isSubmitting,
    String? selectedPaymentMethod,
    int? selectedCustomerId,
    double? discountAmount,
    String? errorMessage,
  }) {
    return SalesState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedPaymentMethod:
          selectedPaymentMethod ?? (this.selectedPaymentMethod.isNotEmpty ? this.selectedPaymentMethod : 'CASH'),
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      discountAmount: discountAmount ?? (this.discountAmount),
      errorMessage: errorMessage,
    );
  }

  double get subtotal {
    final items = cartItems;
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get discount {
    final d = (discountAmount as dynamic);
    if (d == null || d is! num) return 0.0;
    return d.toDouble();
  }

  double get grandTotal {
    final s = subtotal;
    final d = discount;
    final total = s - d;
    return total > 0 ? total : 0.0;
  }

  int get totalItems {
    final items = cartItems;
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class SalesNotifier extends Notifier<SalesState> {
  @override
  SalesState build() {
    Future.microtask(() => loadProducts());
    return SalesState();
  }

  void addToCart(ProductModel product) {
    final items = List<CartItemModel>.from(state.cartItems);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItemModel(product: product, quantity: 1));
    }

    state = state.copyWith(cartItems: items);
  }

  void removeFromCart(String productId) {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    state = state.copyWith(cartItems: items);
  }

  void updateQuantity(String productId, int delta) {
    final items = List<CartItemModel>.from(state.cartItems);
    final index = items.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      final newQuantity = items[index].quantity + delta;
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: newQuantity);
      }
      state = state.copyWith(cartItems: items);
    }
  }

  void clearCart() {
    state = state.copyWith(
      cartItems: [],
      discountAmount: 0.0,
      selectedCustomerId: null,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setCustomer(int? customerId) {
    state = state.copyWith(selectedCustomerId: customerId);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discountAmount: discount);
  }

  void selectCategory(ProductCategoryModel? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.allProducts;

    if (state.selectedCategory != null &&
        state.selectedCategory!.name != 'ទាំងអស់') {
      filtered = filtered
          .where((p) => p.category.name == state.selectedCategory!.name)
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.code.toLowerCase().contains(q))
          .toList();
    }

    state = state.copyWith(filteredProducts: filtered);
  }

  /// Load live products and categories from backend API
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!ApiService.instance.isAuthenticated) {
      state = state.copyWith(
        isLoading: false,
        allProducts: [],
        filteredProducts: [],
      );
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

        state = state.copyWith(
          isLoading: false,
          categories: loadedCategories,
          selectedCategory: loadedCategories.first,
          allProducts: products,
          filteredProducts: products,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: prodResponse.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'មានបញ្ហាក្នុងការទាញយកទិន្នន័យ: $e',
      );
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
    if (state.cartItems.isEmpty) return null;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final selectedMethod = paymentMethod ?? state.selectedPaymentMethod;
    final total = state.grandTotal;
    final paid = customPaidAmount ??
        (selectedMethod == 'DEBT' ? 0.0 : total);

    final saleItems = state.cartItems.map((item) {
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
      businessId: ApiService.instance.currentBusinessId ?? 0,
      customerId: customerId ?? state.selectedCustomerId,
      invoiceNo: invoice,
      discountAmount: state.discountAmount,
      paidAmount: paid,
      paymentMethod: selectedMethod,
      saleDate: DateTime.now(),
      saveAsDraft: saveAsDraft,
      items: saleItems,
    );

    try {
      final response = await ApiService.instance.createSale(sale: saleCreate);
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        clearCart();
        // Refresh product stocks in background
        loadProducts();
        return response.data;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការបង្កើតការលក់',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'កំហុសក្នុងការលក់: $e',
      );
      return null;
    }
  }
}

final salesProvider =
    NotifierProvider<SalesNotifier, SalesState>(() => SalesNotifier());

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stock/stock_model/stock_model.dart';
import '../../supplier/supplier_models/supplier_model.dart';
import '../purchase_models/purchase_model.dart';
import '../../../services/api_service.dart';

class PurchaseState {
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final List<SupplierModel> suppliers;
  final int? selectedSupplierId;
  final List<PurchaseCartItem> cartItems;
  final List<PurchaseResponse> history;
  final String searchQuery;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  PurchaseState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.suppliers = const [],
    this.selectedSupplierId,
    this.cartItems = const [],
    this.history = const [],
    this.searchQuery = '',
    this.isLoading = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  PurchaseState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    List<SupplierModel>? suppliers,
    int? selectedSupplierId,
    List<PurchaseCartItem>? cartItems,
    List<PurchaseResponse>? history,
    String? searchQuery,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PurchaseState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      suppliers: suppliers ?? this.suppliers,
      selectedSupplierId: selectedSupplierId ?? this.selectedSupplierId,
      cartItems: cartItems ?? this.cartItems,
      history: history ?? this.history,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  double get subtotal {
    final items = cartItems;
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItemCount {
    final items = cartItems;
    return items.fold(0, (sum, item) => sum + item.quantity.toInt());
  }
}

class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    Future.microtask(() => loadData());
    return PurchaseState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!ApiService.instance.isAuthenticated) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      // 1. Fetch suppliers
      final suppRes = await ApiService.instance.getSuppliers();
      final List<SupplierModel> suppliers =
          (suppRes.success && suppRes.data != null) ? suppRes.data! : [];

      // 2. Fetch products
      final prodRes =
          await ApiService.instance.getProducts(includeInactive: false);
      final List<ProductModel> products = [];
      if (prodRes.success && prodRes.data != null) {
        final defaultCat = ProductCategoryModel(
          name: 'ទូទៅ',
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
        );
        for (final p in prodRes.data!) {
          products.add(
            ProductModel(
              id: p.id.toString(),
              name: p.name,
              code: p.sku?.isNotEmpty == true
                  ? p.sku!
                  : (p.barcode?.isNotEmpty == true ? p.barcode! : 'PROD-${p.id}'),
              category: defaultCat,
              stock: p.stockQty.toInt(),
              price: p.sellPrice,
              costPrice: p.costPrice,
              status: p.stockQty <= 0 ? 'out_of_stock' : 'all',
              unit: p.unit,
              image: p.image,
            ),
          );
        }
      }

      // 3. Fetch purchase history
      final historyRes = await ApiService.instance.getPurchases();
      final List<PurchaseResponse> history =
          (historyRes.success && historyRes.data != null) ? historyRes.data! : [];

      state = state.copyWith(
        isLoading: false,
        allProducts: products,
        filteredProducts: products,
        suppliers: suppliers,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'មានបញ្ហាក្នុងការទាញយកទិន្នន័យ: $e',
      );
    }
  }

  void selectSupplier(int? supplierId) {
    state = state.copyWith(selectedSupplierId: supplierId);
  }

  void updateSearch(String query) {
    final clean = query.trim().toLowerCase();
    List<ProductModel> filtered = state.allProducts;
    if (clean.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(clean) ||
                p.code.toLowerCase().contains(clean),
          )
          .toList();
    }
    state = state.copyWith(searchQuery: query, filteredProducts: filtered);
  }

  void addToCart(ProductModel product, {double? customCost}) {
    final items = List<PurchaseCartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == product.id);

    final cost = customCost ?? (product.costPrice > 0 ? product.costPrice : product.price);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1.0);
    } else {
      items.add(
        PurchaseCartItem(
          product: product,
          quantity: 1.0,
          costPrice: cost,
        ),
      );
    }

    state = state.copyWith(cartItems: items);
  }

  void updateQuantity(String productId, double delta) {
    final items = List<PurchaseCartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      final newQty = items[idx].quantity + delta;
      if (newQty <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: newQty);
      }
      state = state.copyWith(cartItems: items);
    }
  }

  void setQuantity(String productId, double quantity) {
    final items = List<PurchaseCartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      if (quantity <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: quantity);
      }
      state = state.copyWith(cartItems: items);
    }
  }

  void updateCostPrice(String productId, double costPrice) {
    final items = List<PurchaseCartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(costPrice: costPrice);
      state = state.copyWith(cartItems: items);
    }
  }

  void removeFromCart(String productId) {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    state = state.copyWith(cartItems: items);
  }

  void clearCart() {
    state = state.copyWith(
      cartItems: [],
      selectedSupplierId: null,
    );
  }

  /// Create purchase
  Future<PurchaseResponse?> createPurchase({
    int? supplierId,
    String? invoiceNo,
    double? paidAmount,
    DateTime? purchaseDate,
  }) async {
    if (state.cartItems.isEmpty) return null;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final sId = supplierId ?? state.selectedSupplierId;
    final total = state.subtotal;
    final paid = paidAmount ?? total;
    final invoice = invoiceNo?.trim().isNotEmpty == true
        ? invoiceNo!.trim()
        : 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final items = state.cartItems.map((c) {
      final pId = int.tryParse(c.product.id) ?? 0;
      return PurchaseItemCreate(
        productId: pId,
        quantity: c.quantity,
        costPrice: c.costPrice,
      );
    }).toList();

    final payload = PurchaseCreate(
      businessId: ApiService.instance.currentBusinessId ?? 0,
      supplierId: sId,
      invoiceNo: invoice,
      paidAmount: paid,
      purchaseDate: purchaseDate ?? DateTime.now(),
      items: items,
    );

    try {
      final response =
          await ApiService.instance.createPurchase(purchase: payload);
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        clearCart();
        // Refresh products and history
        loadData();
        return response.data;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការបង្កើតការទិញចូល',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'កំហុសក្នុងការបង្កើតការទិញចូល: $e',
      );
      return null;
    }
  }
}

final purchaseProvider =
    NotifierProvider<PurchaseNotifier, PurchaseState>(() => PurchaseNotifier());

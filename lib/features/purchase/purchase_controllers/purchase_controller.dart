import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stock/stock_model/stock_model.dart';
import '../../supplier/supplier_models/supplier_model.dart';
import '../purchase_models/purchase_model.dart';
import '../../../services/api_service.dart';

class PurchaseController extends GetxController {
  var allProducts = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var suppliers = <SupplierModel>[].obs;
  var selectedSupplierId = RxnInt();
  var cartItems = <PurchaseCartItem>[].obs;
  var history = <PurchaseResponse>[].obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var errorMessage = RxnString();

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity.toInt());

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (!ApiService.instance.isAuthenticated) {
      isLoading.value = false;
      return;
    }

    try {
      // 1. Fetch suppliers
      final suppRes = await ApiService.instance.getSuppliers();
      final List<SupplierModel> loadedSuppliers =
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
      final List<PurchaseResponse> loadedHistory =
          (historyRes.success && historyRes.data != null) ? historyRes.data! : [];

      suppliers.assignAll(loadedSuppliers);
      allProducts.assignAll(products);
      filteredProducts.assignAll(products);
      history.assignAll(loadedHistory);
    } catch (e) {
      errorMessage.value = 'មានបញ្ហាក្នុងការទាញយកទិន្នន័យ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectSupplier(int? supplierId) {
    selectedSupplierId.value = supplierId;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredProducts.assignAll(allProducts);
      return;
    }

    final filtered = allProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(clean) ||
              p.code.toLowerCase().contains(clean),
        )
        .toList();

    filteredProducts.assignAll(filtered);
  }

  void addToCart(ProductModel product, {double? customCost}) {
    final idx = cartItems.indexWhere((i) => i.product.id == product.id);
    final cost = customCost ?? (product.costPrice > 0 ? product.costPrice : product.price);

    if (idx >= 0) {
      cartItems[idx] = cartItems[idx].copyWith(quantity: cartItems[idx].quantity + 1.0);
    } else {
      cartItems.add(
        PurchaseCartItem(
          product: product,
          quantity: 1.0,
          costPrice: cost,
        ),
      );
    }
  }

  void updateQuantity(String productId, double delta) {
    final idx = cartItems.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      final newQty = cartItems[idx].quantity + delta;
      if (newQty <= 0) {
        cartItems.removeAt(idx);
      } else {
        cartItems[idx] = cartItems[idx].copyWith(quantity: newQty);
      }
    }
  }

  void setQuantity(String productId, double quantity) {
    final idx = cartItems.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      if (quantity <= 0) {
        cartItems.removeAt(idx);
      } else {
        cartItems[idx] = cartItems[idx].copyWith(quantity: quantity);
      }
    }
  }

  void updateCostPrice(String productId, double costPrice) {
    final idx = cartItems.indexWhere((i) => i.product.id == productId);

    if (idx >= 0) {
      cartItems[idx] = cartItems[idx].copyWith(costPrice: costPrice);
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((i) => i.product.id != productId);
  }

  void clearCart() {
    cartItems.clear();
    selectedSupplierId.value = null;
  }

  /// Create purchase
  Future<PurchaseResponse?> createPurchase({
    int? supplierId,
    String? invoiceNo,
    double? paidAmount,
    DateTime? purchaseDate,
  }) async {
    if (cartItems.isEmpty) return null;

    isSubmitting.value = true;
    errorMessage.value = null;

    final sId = supplierId ?? selectedSupplierId.value;
    final total = subtotal;
    final paid = paidAmount ?? total;
    final invoice = invoiceNo?.trim().isNotEmpty == true
        ? invoiceNo!.trim()
        : 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final items = cartItems.map((c) {
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
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        clearCart();
        loadData();
        return response.data;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការបង្កើតការទិញចូល';
        return null;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុសក្នុងការបង្កើតការទិញចូល: $e';
      return null;
    }
  }

  PurchaseState get state => PurchaseState(
        allProducts: allProducts,
        filteredProducts: filteredProducts,
        suppliers: suppliers,
        selectedSupplierId: selectedSupplierId.value,
        cartItems: cartItems,
        history: history,
        searchQuery: searchQuery.value,
        isLoading: isLoading.value,
        isSubmitting: isSubmitting.value,
        errorMessage: errorMessage.value,
        subtotal: subtotal,
        totalItemCount: totalItemCount,
      );
}

typedef PurchaseNotifier = PurchaseController;

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
  final double subtotal;
  final int totalItemCount;

  const PurchaseState({
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
    this.subtotal = 0.0,
    this.totalItemCount = 0,
  });
}

import 'package:get/get.dart';
import '../supplier_models/supplier_model.dart';
import '../../../services/api_service.dart';

class SupplierController extends GetxController {
  var allSuppliers = <SupplierModel>[].obs;
  var filteredSuppliers = <SupplierModel>[].obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var searchQuery = ''.obs;
  var errorMessage = RxnString();

  int get totalCount => allSuppliers.length;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    final cleanQuery = searchQuery.value.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      filteredSuppliers.assignAll(allSuppliers);
      return;
    }

    final filtered = allSuppliers.where((s) {
      final nameMatch = s.name.toLowerCase().contains(cleanQuery);
      final phoneMatch = s.phone?.toLowerCase().contains(cleanQuery) ?? false;
      final emailMatch = s.email?.toLowerCase().contains(cleanQuery) ?? false;
      final addressMatch =
          s.address?.toLowerCase().contains(cleanQuery) ?? false;
      return nameMatch || phoneMatch || emailMatch || addressMatch;
    }).toList();

    filteredSuppliers.assignAll(filtered);
  }

  /// Load suppliers from database API
  Future<void> loadSuppliers({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    if (!ApiService.instance.isAuthenticated) {
      isLoading.value = false;
      errorMessage.value = 'សូមចូលគណនីដើម្បីមើលទិន្នន័យអ្នកផ្គត់ផ្គង់';
      allSuppliers.clear();
      filteredSuppliers.clear();
      return;
    }

    try {
      final response = await ApiService.instance.getSuppliers();
      if (response.success && response.data != null) {
        allSuppliers.assignAll(response.data!);
        _applyFilter();
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការទាញយកអ្នកផ្គត់ផ្គង់';
      }
    } catch (e) {
      errorMessage.value = 'មានបញ្ហាក្នុងការតភ្ជាប់: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new supplier
  Future<bool> createSupplier(SupplierCreate supplier) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response =
          await ApiService.instance.createSupplier(supplier: supplier);
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការបន្ថែមអ្នកផ្គត់ផ្គង់';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  /// Update supplier details
  Future<bool> updateSupplier(int supplierId, SupplierUpdate supplier) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response = await ApiService.instance.updateSupplier(
        supplierId: supplierId,
        supplier: supplier,
      );
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  /// Delete supplier
  Future<bool> deleteSupplier(int supplierId) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response =
          await ApiService.instance.deleteSupplier(supplierId: supplierId);
      isSubmitting.value = false;

      if (response.success) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការលុបអ្នកផ្គត់ផ្គង់';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  SupplierState get state => SupplierState(
        allSuppliers: allSuppliers,
        filteredSuppliers: filteredSuppliers,
        isLoading: isLoading.value,
        isSubmitting: isSubmitting.value,
        searchQuery: searchQuery.value,
        errorMessage: errorMessage.value,
        totalCount: totalCount,
      );
}

typedef SupplierNotifier = SupplierController;

class SupplierState {
  final List<SupplierModel> allSuppliers;
  final List<SupplierModel> filteredSuppliers;
  final bool isLoading;
  final bool isSubmitting;
  final String searchQuery;
  final String? errorMessage;
  final int totalCount;

  const SupplierState({
    this.allSuppliers = const [],
    this.filteredSuppliers = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.searchQuery = '',
    this.errorMessage,
    this.totalCount = 0,
  });
}

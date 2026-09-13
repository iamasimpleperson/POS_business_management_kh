import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supplier_models/supplier_model.dart';
import '../../../services/api_service.dart';

class SupplierState {
  final List<SupplierModel> allSuppliers;
  final List<SupplierModel> filteredSuppliers;
  final bool isLoading;
  final bool isSubmitting;
  final String searchQuery;
  final String? errorMessage;

  SupplierState({
    this.allSuppliers = const [],
    this.filteredSuppliers = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.searchQuery = '',
    this.errorMessage,
  });

  int get totalCount => allSuppliers.length;

  SupplierState copyWith({
    List<SupplierModel>? allSuppliers,
    List<SupplierModel>? filteredSuppliers,
    bool? isLoading,
    bool? isSubmitting,
    String? searchQuery,
    String? errorMessage,
  }) {
    return SupplierState(
      allSuppliers: allSuppliers ?? this.allSuppliers,
      filteredSuppliers: filteredSuppliers ?? this.filteredSuppliers,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class SupplierNotifier extends Notifier<SupplierState> {
  @override
  SupplierState build() {
    Future.microtask(() => loadSuppliers());
    return SupplierState();
  }

  void setSearchQuery(String query) {
    final filtered = _filterSuppliers(state.allSuppliers, query);
    state = state.copyWith(
      searchQuery: query,
      filteredSuppliers: filtered,
    );
  }

  List<SupplierModel> _filterSuppliers(
    List<SupplierModel> all,
    String query,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return all;

    return all.where((s) {
      final nameMatch = s.name.toLowerCase().contains(cleanQuery);
      final phoneMatch = s.phone?.toLowerCase().contains(cleanQuery) ?? false;
      final emailMatch = s.email?.toLowerCase().contains(cleanQuery) ?? false;
      final addressMatch =
          s.address?.toLowerCase().contains(cleanQuery) ?? false;
      return nameMatch || phoneMatch || emailMatch || addressMatch;
    }).toList();
  }

  /// Load suppliers from database API
  Future<void> loadSuppliers({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    if (!ApiService.instance.isAuthenticated) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'សូមចូលគណនីដើម្បីមើលទិន្នន័យអ្នកផ្គត់ផ្គង់',
        allSuppliers: [],
        filteredSuppliers: [],
      );
      return;
    }

    try {
      final response = await ApiService.instance.getSuppliers();
      if (response.success && response.data != null) {
        final suppliers = response.data!;
        final filtered = _filterSuppliers(suppliers, state.searchQuery);
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          allSuppliers: suppliers,
          filteredSuppliers: filtered,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error ?? 'បរាជ័យក្នុងការទាញយកអ្នកផ្គត់ផ្គង់',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'មានបញ្ហាក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Create new supplier
  Future<bool> createSupplier(SupplierCreate supplier) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response =
          await ApiService.instance.createSupplier(supplier: supplier);
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការបន្ថែមអ្នកផ្គត់ផ្គង់',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'កំហុស: $e',
      );
      return false;
    }
  }

  /// Update supplier details
  Future<bool> updateSupplier(int supplierId, SupplierUpdate supplier) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response = await ApiService.instance.updateSupplier(
        supplierId: supplierId,
        supplier: supplier,
      );
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'កំហុស: $e',
      );
      return false;
    }
  }

  /// Delete supplier
  Future<bool> deleteSupplier(int supplierId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response =
          await ApiService.instance.deleteSupplier(supplierId: supplierId);
      state = state.copyWith(isSubmitting: false);

      if (response.success) {
        await loadSuppliers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការលុបអ្នកផ្គត់ផ្គង់',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'កំហុស: $e',
      );
      return false;
    }
  }
}

final supplierProvider =
    NotifierProvider<SupplierNotifier, SupplierState>(() => SupplierNotifier());

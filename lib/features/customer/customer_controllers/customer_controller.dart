import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../customer_models/customer_model.dart';
import '../../../services/api_service.dart';

class CustomerState {
  final List<CustomerModel> allCustomers;
  final List<CustomerModel> filteredCustomers;
  final bool isLoading;
  final bool isSubmitting;
  final int selectedFilterTabIndex;
  final String searchQuery;
  final String? errorMessage;

  CustomerState({
    this.allCustomers = const [],
    this.filteredCustomers = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.selectedFilterTabIndex = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  int get totalCount => allCustomers.length;

  int get newCount {
    final now = DateTime.now();
    return allCustomers.where((c) {
      if (c.createdAt == null) return false;
      return now.difference(c.createdAt!).inDays <= 30;
    }).length;
  }

  int get vipCount {
    return allCustomers.where((c) => c.totalSpent >= 500.0).length;
  }

  int get inactiveCount {
    return allCustomers.where((c) => c.totalSpent == 0.0).length;
  }

  CustomerState copyWith({
    List<CustomerModel>? allCustomers,
    List<CustomerModel>? filteredCustomers,
    bool? isLoading,
    bool? isSubmitting,
    int? selectedFilterTabIndex,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CustomerState(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedFilterTabIndex:
          selectedFilterTabIndex ?? this.selectedFilterTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class CustomerNotifier extends Notifier<CustomerState> {
  @override
  CustomerState build() {
    Future.microtask(() => loadCustomers());
    return CustomerState();
  }

  void setFilterTab(int index) {
    final filtered = _filterCustomers(
      state.allCustomers,
      index,
      state.searchQuery,
    );
    state = state.copyWith(
      selectedFilterTabIndex: index,
      filteredCustomers: filtered,
    );
  }

  void setSearchQuery(String query) {
    final filtered = _filterCustomers(
      state.allCustomers,
      state.selectedFilterTabIndex,
      query,
    );
    state = state.copyWith(
      searchQuery: query,
      filteredCustomers: filtered,
    );
  }

  List<CustomerModel> _filterCustomers(
    List<CustomerModel> all,
    int tabIndex,
    String query,
  ) {
    List<CustomerModel> list = all;

    // 1. Tab filter
    if (tabIndex == 1) {
      // VIP: totalSpent >= 500
      list = list.where((c) => c.totalSpent >= 500.0).toList();
    } else if (tabIndex == 2) {
      // ថ្មី (New: created within 30 days or newest first)
      final now = DateTime.now();
      list = list.where((c) {
        if (c.createdAt == null) return false;
        return now.difference(c.createdAt!).inDays <= 30;
      }).toList();
    } else if (tabIndex == 3) {
      // អសកម្ម (Inactive: 0 spent)
      list = list.where((c) => c.totalSpent == 0.0).toList();
    }

    // 2. Search query filter
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      list = list.where((c) {
        final nameMatch = c.name.toLowerCase().contains(cleanQuery);
        final phoneMatch =
            c.phone?.toLowerCase().contains(cleanQuery) ?? false;
        final emailMatch =
            c.email?.toLowerCase().contains(cleanQuery) ?? false;
        final addressMatch =
            c.address?.toLowerCase().contains(cleanQuery) ?? false;
        return nameMatch || phoneMatch || emailMatch || addressMatch;
      }).toList();
    }

    return list;
  }

  /// Load customers from database via API
  Future<void> loadCustomers({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    if (!ApiService.instance.isAuthenticated) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'សូមចូលគណនីដើម្បីមើលទិន្នន័យអតិថិជន',
        allCustomers: [],
        filteredCustomers: [],
      );
      return;
    }

    try {
      final response = await ApiService.instance.getCustomers();
      if (response.success && response.data != null) {
        final customers = response.data!;
        final filtered = _filterCustomers(
          customers,
          state.selectedFilterTabIndex,
          state.searchQuery,
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          allCustomers: customers,
          filteredCustomers: filtered,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error ?? 'បរាជ័យក្នុងការទាញយកទិន្នន័យអតិថិជន',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'មានបញ្ហាក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Create new customer
  Future<bool> createCustomer(CustomerCreate customer) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response =
          await ApiService.instance.createCustomer(customer: customer);
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការបង្កើតអតិថិជន',
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

  /// Update customer details
  Future<bool> updateCustomer(int customerId, CustomerUpdate customer) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response = await ApiService.instance.updateCustomer(
        customerId: customerId,
        customer: customer,
      );
      state = state.copyWith(isSubmitting: false);

      if (response.success && response.data != null) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអតិថិជន',
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

  /// Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final response =
          await ApiService.instance.deleteCustomer(customerId: customerId);
      state = state.copyWith(isSubmitting: false);

      if (response.success) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'បរាជ័យក្នុងការលុបអតិថិជន',
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

final customerProvider =
    NotifierProvider<CustomerNotifier, CustomerState>(() => CustomerNotifier());

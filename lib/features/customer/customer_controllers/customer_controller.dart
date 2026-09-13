import 'package:get/get.dart';
import '../customer_models/customer_model.dart';
import '../../../services/api_service.dart';
import '../../sales/sales_model/sales_model.dart';

class CustomerController extends GetxController {
  var allCustomers = <CustomerModel>[].obs;
  var filteredCustomers = <CustomerModel>[].obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var selectedFilterTabIndex = 0.obs;
  var searchQuery = ''.obs;
  var errorMessage = RxnString();

  int get totalCount => allCustomers.length;

  int get newCount {
    final now = DateTime.now();
    return allCustomers.where((c) {
      if (c.createdAt == null) return false;
      return now.difference(c.createdAt!).inDays <= 30;
    }).length;
  }

  int get vipCount => allCustomers.where((c) => c.totalSpent >= 500.0).length;
  int get inactiveCount => allCustomers.where((c) => c.totalSpent == 0.0).length;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
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
    List<CustomerModel> list = allCustomers.toList();

    // 1. Tab filter
    if (selectedFilterTabIndex.value == 1) {
      list = list.where((c) => c.totalSpent >= 500.0).toList();
    } else if (selectedFilterTabIndex.value == 2) {
      final now = DateTime.now();
      list = list.where((c) {
        if (c.createdAt == null) return false;
        return now.difference(c.createdAt!).inDays <= 30;
      }).toList();
    } else if (selectedFilterTabIndex.value == 3) {
      list = list.where((c) => c.totalSpent == 0.0).toList();
    }

    // 2. Search query filter
    final cleanQuery = searchQuery.value.trim().toLowerCase();
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

    filteredCustomers.assignAll(list);
  }

  /// Load customers from database via API
  Future<void> loadCustomers({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    if (!ApiService.instance.isAuthenticated) {
      isLoading.value = false;
      errorMessage.value = 'សូមចូលគណនីដើម្បីមើលទិន្នន័យអតិថិជន';
      allCustomers.clear();
      filteredCustomers.clear();
      return;
    }

    try {
      final responses = await Future.wait([
        ApiService.instance.getCustomers(),
        ApiService.instance.getSales(limit: 100),
      ]);

      final custRes = responses[0] as ApiResponse<List<CustomerModel>>;
      final salesRes = responses[1] as ApiResponse<List<SaleResponse>>;

      if (custRes.success && custRes.data != null) {
        final salesList = (salesRes.success && salesRes.data != null)
            ? salesRes.data!
            : <SaleResponse>[];

        final enrichedList = custRes.data!.map((c) {
          final customerSales =
              salesList.where((s) => s.customerId == c.id).toList();
          final totalSpent = customerSales.fold<double>(
            0.0,
            (sum, s) => sum + s.totalAmount,
          );

          DateTime? lastVisit = c.lastVisit;
          for (final s in customerSales) {
            if (s.saleDate != null) {
              if (lastVisit == null || s.saleDate!.isAfter(lastVisit)) {
                lastVisit = s.saleDate;
              }
            }
          }

          return CustomerModel(
            id: c.id,
            businessId: c.businessId,
            name: c.name,
            phone: c.phone,
            email: c.email,
            address: c.address,
            totalSpent: totalSpent,
            lastVisit: lastVisit,
            createdAt: c.createdAt,
            updatedAt: c.updatedAt,
          );
        }).toList();

        allCustomers.assignAll(enrichedList);
        _applyFilter();
      } else {
        errorMessage.value = custRes.error ?? 'បរាជ័យក្នុងការទាញយកទិន្នន័យអតិថិជន';
      }
    } catch (e) {
      errorMessage.value = 'មានបញ្ហាក្នុងការតភ្ជាប់: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new customer
  Future<bool> createCustomer(CustomerCreate customer) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response =
          await ApiService.instance.createCustomer(customer: customer);
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការបង្កើតអតិថិជន';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  /// Update customer details
  Future<bool> updateCustomer(int customerId, CustomerUpdate customer) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response = await ApiService.instance.updateCustomer(
        customerId: customerId,
        customer: customer,
      );
      isSubmitting.value = false;

      if (response.success && response.data != null) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអតិថិជន';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final response =
          await ApiService.instance.deleteCustomer(customerId: customerId);
      isSubmitting.value = false;

      if (response.success) {
        await loadCustomers(showLoading: false);
        return true;
      } else {
        errorMessage.value = response.error ?? 'បរាជ័យក្នុងការលុបអតិថិជន';
        return false;
      }
    } catch (e) {
      isSubmitting.value = false;
      errorMessage.value = 'កំហុស: $e';
      return false;
    }
  }

  CustomerState get state => CustomerState(
        allCustomers: allCustomers,
        filteredCustomers: filteredCustomers,
        isLoading: isLoading.value,
        isSubmitting: isSubmitting.value,
        selectedFilterTabIndex: selectedFilterTabIndex.value,
        searchQuery: searchQuery.value,
        errorMessage: errorMessage.value,
        totalCount: totalCount,
        newCount: newCount,
        vipCount: vipCount,
        inactiveCount: inactiveCount,
      );
}

typedef CustomerNotifier = CustomerController;

class CustomerState {
  final List<CustomerModel> allCustomers;
  final List<CustomerModel> filteredCustomers;
  final bool isLoading;
  final bool isSubmitting;
  final int selectedFilterTabIndex;
  final String searchQuery;
  final String? errorMessage;
  final int totalCount;
  final int newCount;
  final int vipCount;
  final int inactiveCount;

  const CustomerState({
    this.allCustomers = const [],
    this.filteredCustomers = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.selectedFilterTabIndex = 0,
    this.searchQuery = '',
    this.errorMessage,
    this.totalCount = 0,
    this.newCount = 0,
    this.vipCount = 0,
    this.inactiveCount = 0,
  });
}

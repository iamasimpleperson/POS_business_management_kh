import 'package:get/get.dart';
import '../debt_models/debt_model.dart';
import '../../customer/customer_models/customer_model.dart';
import '../../../services/api_service.dart';

class DebtController extends GetxController {
  var allDebts = <DebtModel>[].obs;
  var customers = <CustomerModel>[].obs;
  var selectedFilterTab = 0.obs; // 0: ទាំងអស់, 1: មិនទាន់សង (OPEN), 2: សងរួច (PAID)
  var searchQuery = ''.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  List<DebtModel> get filteredDebts {
    var list = allDebts.toList();

    // 1. Filter by Tab
    if (selectedFilterTab.value == 1) {
      list = list.where((d) => d.status.toUpperCase() == 'OPEN' || d.remainingAmount > 0).toList();
    } else if (selectedFilterTab.value == 2) {
      list = list.where((d) => d.status.toUpperCase() == 'PAID' || d.remainingAmount == 0).toList();
    }

    // 2. Filter by search query (customer name or phone)
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((d) {
        final nameMatch = d.customerName?.toLowerCase().contains(q) ?? false;
        final phoneMatch = d.customerPhone?.toLowerCase().contains(q) ?? false;
        return nameMatch || phoneMatch;
      }).toList();
    }

    return list;
  }

  double get totalRemainingDebt {
    return allDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);
  }

  double get totalPaidDebt {
    return allDebts.fold(0.0, (sum, d) => sum + d.paidAmount);
  }

  int get openDebtCount {
    return allDebts.where((d) => d.remainingAmount > 0).length;
  }

  Future<void> loadDebts({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    try {
      final responses = await Future.wait([
        ApiService.instance.getDebts(limit: 100),
        ApiService.instance.getCustomers(),
      ]);

      final debtRes = responses[0] as ApiResponse<List<DebtModel>>;
      final custRes = responses[1] as ApiResponse<List<CustomerModel>>;

      if (custRes.success && custRes.data != null) {
        customers.assignAll(custRes.data!);
      }

      if (debtRes.success && debtRes.data != null) {
        final custList = custRes.data ?? [];
        final enriched = debtRes.data!.map((d) {
          final cust = custList.firstWhereOrNull((c) => c.id == d.customerId);
          if (cust != null) {
            d.customerName = cust.name;
            d.customerPhone = cust.phone;
          }
          return d;
        }).toList();

        allDebts.assignAll(enriched);
      } else if (!debtRes.success) {
        errorMessage.value = debtRes.error ?? 'បរាជ័យក្នុងការទាញយកបញ្ជីបំណុល';
      }
    } catch (e) {
      errorMessage.value = 'កំហុសក្នុងការទាញយកទិន្នន័យ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<({bool success, String message})> recordPayment({
    required int debtId,
    required double amount,
    String paymentMethod = 'CASH',
    String? note,
  }) async {
    if (amount <= 0) {
      return (success: false, message: 'សូមបញ្ចូលទឹកប្រាក់សងឱ្យបានត្រឹមត្រូវ');
    }
    isSubmitting.value = true;

    try {
      final res = await ApiService.instance.recordDebtPayment(
        debtId: debtId,
        amount: amount,
        paymentMethod: paymentMethod,
        note: note,
        paymentDate: DateTime.now(),
      );

      isSubmitting.value = false;

      if (res.success) {
        await loadDebts(showLoading: false);
        return (
          success: true,
          message:
              'បានកត់ត្រាការសងប្រាក់ចំនួន \$${amount.toStringAsFixed(2)} ដោយជោគជ័យ',
        );
      } else {
        return (
          success: false,
          message: res.error ?? 'មិនអាចកត់ត្រាការសងប្រាក់បាន',
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      return (success: false, message: 'កំហុសក្នុងការសងប្រាក់: $e');
    }
  }
}

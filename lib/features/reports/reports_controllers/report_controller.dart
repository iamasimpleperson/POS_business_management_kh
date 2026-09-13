import 'package:get/get.dart';
import '../reports_models/report_model.dart';
import '../../../services/api_service.dart';

class ReportController extends GetxController {
  var selectedPeriod = 0.obs; // 0: ថ្ងៃនេះ (Today), 1: សប្ដាហ៍នេះ (Week), 2: ខែនេះ (Month)
  var selectedTab = 0.obs; // 0: ចំណេញ/ខាត (P&L), 1: ការលក់ (Sales), 2: ស្តុក (Inventory), 3: ចំណាយ (Expenses)

  var salesReport = Rxn<SalesReportModel>();
  var profitReport = Rxn<ProfitReportModel>();
  var inventoryReport = Rxn<InventoryReportModel>();
  var expenseReport = Rxn<ExpenseReportModel>();

  var isLoading = true.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadAllReports();
  }

  void changePeriod(int index) {
    selectedPeriod.value = index;
    loadAllReports();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  (DateTime startDate, DateTime endDate) _getDateRange() {
    final now = DateTime.now();
    if (selectedPeriod.value == 0) {
      // Today
      final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return (start, end);
    } else if (selectedPeriod.value == 1) {
      // This week (last 7 days)
      final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return (start, end);
    } else {
      // This month
      final start = DateTime(now.year, now.month, 1, 0, 0, 0);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return (start, end);
    }
  }

  Future<void> loadAllReports() async {
    isLoading.value = true;
    errorMessage.value = null;

    final (start, end) = _getDateRange();

    try {
      final responses = await Future.wait([
        ApiService.instance.getSalesReport(startDate: start, endDate: end),
        ApiService.instance.getProfitReport(startDate: start, endDate: end),
        ApiService.instance.getInventoryReport(),
        ApiService.instance.getExpenseReport(startDate: start, endDate: end),
      ]);

      final salesRes = responses[0] as ApiResponse<SalesReportModel>;
      final profitRes = responses[1] as ApiResponse<ProfitReportModel>;
      final invRes = responses[2] as ApiResponse<InventoryReportModel>;
      final expRes = responses[3] as ApiResponse<ExpenseReportModel>;

      if (salesRes.success && salesRes.data != null) {
        salesReport.value = salesRes.data;
      }
      if (profitRes.success && profitRes.data != null) {
        profitReport.value = profitRes.data;
      }
      if (invRes.success && invRes.data != null) {
        inventoryReport.value = invRes.data;
      }
      if (expRes.success && expRes.data != null) {
        expenseReport.value = expRes.data;
      }
    } catch (e) {
      errorMessage.value = 'កំហុសក្នុងការទាញយករបាយការណ៍: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

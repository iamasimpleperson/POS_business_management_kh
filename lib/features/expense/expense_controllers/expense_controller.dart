import 'package:get/get.dart';
import '../expense_models/expense_model.dart';
import '../../../services/api_service.dart';

class ExpenseController extends GetxController {
  var allExpenses = <ExpenseModel>[].obs;
  var categories = <ExpenseCategoryModel>[].obs;
  var selectedCategory = Rxn<ExpenseCategoryModel>();
  var searchQuery = ''.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  List<ExpenseModel> get filteredExpenses {
    var list = allExpenses.toList();
    if (selectedCategory.value != null) {
      list = list
          .where((e) => e.categoryId == selectedCategory.value!.id)
          .toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) => e.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  double get totalExpensesAmount {
    return filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> loadExpenses({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    try {
      final responses = await Future.wait([
        ApiService.instance.getExpenseCategories(),
        ApiService.instance.getExpenses(limit: 100),
      ]);

      final catRes = responses[0] as ApiResponse<List<ExpenseCategoryModel>>;
      final expRes = responses[1] as ApiResponse<List<ExpenseModel>>;

      if (catRes.success && catRes.data != null) {
        categories.assignAll(catRes.data!);
      }

      if (expRes.success && expRes.data != null) {
        allExpenses.assignAll(expRes.data!);
      } else if (!expRes.success) {
        errorMessage.value = expRes.error ?? 'បរាជ័យក្នុងការទាញយកចំណាយ';
      }
    } catch (e) {
      errorMessage.value = 'កំហុសក្នុងការទាញយកទិន្នន័យ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<({bool success, String message})> createExpense({
    required String title,
    required double amount,
    int? categoryId,
    DateTime? expenseDate,
    String? note,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await ApiService.instance.createExpense(
        title: title,
        amount: amount,
        categoryId: categoryId,
        expenseDate: expenseDate ?? DateTime.now(),
        note: note,
      );

      isSubmitting.value = false;
      if (res.success && res.data != null) {
        allExpenses.insert(0, res.data!);
        return (success: true, message: 'បានកត់ត្រាការចំណាយដោយជោគជ័យ');
      } else {
        return (
          success: false,
          message: res.error ?? 'មិនអាចកត់ត្រាចំណាយបាន',
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      return (success: false, message: 'មិនអាចកត់ត្រាចំណាយបាន: $e');
    }
  }

  Future<bool> createCategory(String name) async {
    if (name.trim().isEmpty) return false;
    try {
      final res = await ApiService.instance.createExpenseCategory(name);
      if (res.success && res.data != null) {
        categories.add(res.data!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final res = await ApiService.instance.deleteExpense(id);
      if (res.success) {
        allExpenses.removeWhere((e) => e.id == id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

import 'package:get/get.dart';
import '../member_models/member_model.dart';
import '../../../services/api_service.dart';

class MemberController extends GetxController {
  var members = <BusinessMemberModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    try {
      final res = await ApiService.instance.getBusinessMembers();
      if (res.success && res.data != null) {
        members.assignAll(res.data!);
      } else {
        errorMessage.value = res.error ?? 'បរាជ័យក្នុងការទាញយកបញ្ជីបុគ្គលិក';
      }
    } catch (e) {
      errorMessage.value = 'កំហុសក្នុងការទាញយកទិន្នន័យ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<({bool success, String message})> addMember({
    required int userId,
    String role = 'staff',
  }) async {
    try {
      final res = await ApiService.instance.addBusinessMember(
        userId: userId,
        role: role,
      );
      if (res.success && res.data != null) {
        await loadMembers(showLoading: false);
        return (success: true, message: 'បានបន្ថែមបុគ្គលិកដោយជោគជ័យ');
      } else {
        String err = res.error ?? 'មិនអាចបន្ថែមបុគ្គលិកបានទេ';
        final lower = err.toLowerCase();
        if (lower.contains('user not found') || lower.contains('not found')) {
          err = 'រកមិនឃើញគណនីដែលមាន User ID #$userId នេះទេ (សូមឱ្យបុគ្គលិកចុះឈ្មោះក្នុង App ជាមុន)';
        } else if (lower.contains('already a member') || lower.contains('already exists')) {
          err = 'អ្នកប្រើប្រាស់ដែលមាន User ID #$userId នេះជាបុគ្គលិកក្នុងហាងរួចហើយ';
        } else if (lower.contains('permission') || lower.contains('forbidden')) {
          err = 'អ្នកមិនមានសិទ្ធិក្នុងការបន្ថែមបុគ្គលិកទេ (ទាមទារសិទ្ធិជាម្ចាស់ហាង)';
        } else if (lower.contains('input should be') || lower.contains('role')) {
          err = 'តួនាទីមិនត្រឹមត្រូវ (ត្រូវតែជា staff ឬ owner)';
        }
        return (success: false, message: err);
      }
    } catch (e) {
      return (success: false, message: 'កំហុសក្នុងការបន្ថែមបុគ្គលិក: $e');
    }
  }

  Future<({bool success, String message})> removeMember(int userId) async {
    try {
      final res = await ApiService.instance.removeBusinessMember(userId);
      if (res.success) {
        members.removeWhere((m) => m.userId == userId);
        return (success: true, message: 'បានលុបបុគ្គលិកចេញពីហាងដោយជោគជ័យ');
      } else {
        String err = res.error ?? 'មិនអាចលុបបុគ្គលិកបានទេ';
        final lower = err.toLowerCase();
        if (lower.contains('permission') || lower.contains('forbidden')) {
          err = 'អ្នកមិនមានសិទ្ធិដកបុគ្គលិកទេ (ទាមទារសិទ្ធិជាម្ចាស់ហាង)';
        }
        return (success: false, message: err);
      }
    } catch (e) {
      return (success: false, message: 'កំហុសក្នុងការលុបបុគ្គលិក: $e');
    }
  }
}

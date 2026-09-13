import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../member_controllers/member_controller.dart';
import '../member_models/member_model.dart';

class MemberView extends StatelessWidget {
  const MemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberController());
    final currentUserId = ApiService.instance.currentUser?['id'] as int?;
    final currentUserName = ApiService.instance.currentUser?['name'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'គ្រប់គ្រងបុគ្គលិក (Staff)',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ទាញយកឡើងវិញ',
            onPressed: () => controller.loadMembers(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (controller.errorMessage.value != null && controller.members.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadMembers(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('ព្យាយាមម្តងទៀត'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMembers(showLoading: false),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current User & Store Info Card
              _buildUserInfoBanner(currentUserName, currentUserId),
              const SizedBox(height: 16),

              if (controller.members.isEmpty)
                _buildEmptyState(context, controller)
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'បញ្ជីសមាជិក (${controller.members.length} នាក់)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...controller.members.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildMemberCard(member, controller, context, currentUserId),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context, controller, currentUserId),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'បន្ថែមបុគ្គលិក',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUserInfoBanner(String? currentUserName, int? currentUserId) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentUserName ?? 'គណនីរបស់អ្នក',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    if (currentUserId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'User ID: #$currentUserId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'ដើម្បីបន្ថែមបុគ្គលិក សូមឱ្យពួកគេចុះឈ្មោះក្នុង App រួចផ្ដល់ User ID មកកាន់អ្នក។',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MemberController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded, size: 44, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              'មិនទាន់មានបុគ្គលិកនៅក្នុងហាងនៅឡើយទេ',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ចុចប៊ូតុងខាងក្រោមដើម្បីបន្ថែមបុគ្គលិកថ្មីចូលក្នុងហាង',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(
                context,
                controller,
                ApiService.instance.currentUser?['id'] as int?,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('បន្ថែមបុគ្គលិកឥឡូវនេះ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    BusinessMemberModel member,
    MemberController controller,
    BuildContext context,
    int? currentUserId,
  ) {
    final isOwner = member.role.toLowerCase() == 'owner';
    final isCurrentUser = currentUserId != null && member.userId == currentUserId;

    Color roleColor = Colors.grey.shade700;
    String roleName = 'បុគ្គលិក (Staff)';
    if (isOwner) {
      roleColor = const Color(0xFFE65100);
      roleName = 'ម្ចាស់ហាង (Owner)';
    }

    String displayName = member.fullName ?? member.username ?? '';
    if (displayName.isEmpty) {
      if (isCurrentUser) {
        displayName = '${ApiService.instance.currentUser?['name'] ?? 'គណនីរបស់អ្នក'} (អ្នក)';
      } else {
        displayName = 'បុគ្គលិក #${member.userId}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
          width: isCurrentUser ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withValues(alpha: 0.12),
            radius: 22,
            child: Icon(
              isOwner ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
              color: roleColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'អ្នក',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleName,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'User ID: #${member.userId}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isOwner && !isCurrentUser)
            IconButton(
              icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red[400]),
              tooltip: 'ដកចេញ',
              onPressed: () {
                Get.defaultDialog(
                  title: 'ដកបុគ្គលិក',
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  middleText: 'តើអ្នកប្រាកដជាចង់ដកបុគ្គលិកនេះចេញពីហាងមែនទេ?',
                  textConfirm: 'ដកចេញ',
                  textCancel: 'បោះបង់',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () async {
                    Get.back();
                    final result = await controller.removeMember(member.userId);
                    _showNotification(
                      result.success ? 'ជោគជ័យ' : 'បរាជ័យ',
                      result.message,
                      isError: !result.success,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    MemberController controller,
    int? currentUserId,
  ) {
    final userIdController = TextEditingController();
    String selectedRole = 'staff';
    bool isSubmitting = false;
    String? dialogError;
    String? fieldError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF2E7D32),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'បន្ថែមបុគ្គលិកថ្មី',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Instruction Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'បុគ្គលិកត្រូវតែបង្កើតគណនីក្នុង App ជាមុនសិន។ បន្ទាប់មក សូមសួររក User ID របស់ពួកគេ (លេខសម្គាល់គណនី)។${currentUserId != null ? ' (ឧ. User ID របស់អ្នកគឺ #$currentUserId)' : ''}',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error banner if any
              if (dialogError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dialogError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Input field for User ID
              TextField(
                controller: userIdController,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (_) {
                  if (fieldError != null || dialogError != null) {
                    setState(() {
                      fieldError = null;
                      dialogError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'User ID របស់បុគ្គលិក *',
                  hintText: 'ឧទាហរណ៍: 2, 5, 12...',
                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF2E7D32)),
                  errorText: fieldError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Role Dropdown (Only owner and staff supported by backend)
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'តួនាទី (Role)',
                  prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'staff',
                    child: Text('បុគ្គលិក (Staff)'),
                  ),
                  DropdownMenuItem(
                    value: 'owner',
                    child: Text('សហម្ចាស់ហាង (Co-Owner)'),
                  ),
                ],
                onChanged: isSubmitting
                    ? null
                    : (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final text = userIdController.text.trim();
                          if (text.isEmpty) {
                            setState(() {
                              fieldError = 'សូមបញ្ចូល User ID របស់បុគ្គលិក';
                              dialogError = null;
                            });
                            return;
                          }

                          final uid = int.tryParse(text);
                          if (uid == null || uid <= 0) {
                            setState(() {
                              fieldError = 'User ID ត្រូវតែជាលេខធំជាង 0 (ឧទាហរណ៍: 2, 5)';
                              dialogError = null;
                            });
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                            dialogError = null;
                            fieldError = null;
                          });

                          final result = await controller.addMember(userId: uid, role: selectedRole);

                          if (!context.mounted) return;

                          if (result.success) {
                            Navigator.pop(context);
                            _showNotification('ជោគជ័យ', result.message, isError: false);
                          } else {
                            setState(() {
                              isSubmitting = false;
                              dialogError = result.message;
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'បន្ថែមបុគ្គលិក',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotification(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  // ignore: unused_element
  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    _showNotification(isError ? 'កំហុស' : 'ជោគជ័យ', message, isError: isError);
  }
}

import 'package:business_management_kh/features/home/controllers/home_controller.dart';
import 'package:business_management_kh/features/home/home_model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_store_info_view.dart';
import '../../supplier/supplier_views/supplier_view.dart';
import '../../purchase/purchase_views/purchase_view.dart';
import '../../expense/expense_views/expense_view.dart';
import '../../debt/debt_views/debt_view.dart';
import '../../reports/reports_views/reports_view.dart';
import '../../member/member_views/member_view.dart';
import '../../../services/api_service.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Obx(() {
      final data = homeController.homeData.value;
      if (homeController.isLoading.value && data == null) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        );
      }

      if (data == null) {
        return const Center(child: Text('គ្មានទិន្នន័យ'));
      }

      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 14),

                // User Profile Card
                _buildUserProfileCard(),
                const SizedBox(height: 12),

                // Store Card
                _buildStoreCard(context, data),
                const SizedBox(height: 20),

                // Section 1: គ្រប់គ្រងវត្តភាព
                _buildSectionTitle('គ្រប់គ្រងវត្តភាព'),
                const SizedBox(height: 8),
                _buildManagementCard(context),
                const SizedBox(height: 20),

                // Section 2: ការកំណត់ និងជំនួយ
                _buildSectionTitle('ការកំណត់ និងជំនួយ'),
                const SizedBox(height: 8),
                _buildSettingsCard(),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'បន្ថែម',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                size: 26,
                color: Colors.black87,
              ),
              onPressed: () {},
              splashRadius: 24,
            ),
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserProfileCard() {
    final user = ApiService.instance.currentUser;
    final userName = user?['name']?.toString() ?? 'គណនីរបស់ខ្ញុំ';
    final userEmail = user?['email']?.toString() ?? user?['phone']?.toString() ?? '';
    final userId = user?['id'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
            child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 28),
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
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (userId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'User ID: #$userId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, HomeDataModel data) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditStoreInfoView()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC8E6C9).withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEDC8).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF2E7D32),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.shop.name} ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'គ្រប់គ្រងហាង',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.storefront_outlined,
            title: 'ព័ត៌មានហាង',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditStoreInfoView(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.people_outline,
            title: 'បុគ្គលិក',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemberView()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.credit_card_outlined,
            title: 'ចំណាយ (Expenses)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseView()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'បំណុល (Debts)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtView()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.local_shipping_outlined,
            title: 'អ្នកផ្គត់ផ្គង់',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupplierView()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'ទិញទំនិញចូល (Purchase)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchaseView()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.bar_chart_rounded,
            title: 'របាយការណ៍ (Reports)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsView()),
              );
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'ភាសា',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'ជំនួយ',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5)),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'អំពី',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(16),
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ចាកចេញ'),
            content: const Text('តើអ្នកពិតជាចង់ចាកចេញពីគណនីនេះមែនទេ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'បោះបង់',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ចាកចេញ',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE53935), size: 20),
            SizedBox(width: 8),
            Text(
              'ចាកចេញ',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

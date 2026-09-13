import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../customer_controllers/customer_controller.dart';
import '../customer_models/customer_model.dart';

class CustomerView extends ConsumerStatefulWidget {
  const CustomerView({super.key});

  @override
  ConsumerState<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends ConsumerState<CustomerView> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tabs = ['ទាំងអស់', 'VIP', 'ថ្មី', 'អសកម្ម'];

  static const List<Color> _avatarColors = [
    Color(0xFFBBDEFB), // Blue 100
    Color(0xFFF8BBD0), // Pink 100
    Color(0xFFFFE0B2), // Orange 100
    Color(0xFFE1BEE7), // Purple 100
    Color(0xFFC8E6C9), // Green 100
    Color(0xFFFFECB3), // Amber 100
    Color(0xFFB2EBF2), // Cyan 100
    Color(0xFFD1C4E9), // Deep Purple 100
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(customerState),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF4CAF50),
                onRefresh: () async {
                  await ref
                      .read(customerProvider.notifier)
                      .loadCustomers(showLoading: false);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildStatsCards(customerState),
                          _buildSearchBar(),
                          _buildTabs(customerState),
                          _buildFilterRow(customerState),
                        ],
                      ),
                    ),
                    if (customerState.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      )
                    else if (customerState.errorMessage != null &&
                        customerState.allCustomers.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorView(customerState.errorMessage!),
                      )
                    else if (customerState.filteredCustomers.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyView(),
                      )
                    else
                      _buildCustomerList(customerState.filteredCustomers),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CustomerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'អតិថិជន',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'គ្រប់គ្រងព័ត៌មានអតិថិជន (${state.allCustomers.length})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black87),
                tooltip: 'ទាញយកទិន្នន័យឡើងវិញ',
                onPressed: () {
                  ref.read(customerProvider.notifier).loadCustomers();
                },
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'បន្ថែមអតិថិជនថ្មី',
                  onPressed: () => _showAddCustomerSheet(context),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(CustomerState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.people_outline,
              'សរុប',
              state.totalCount.toString(),
              Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              Icons.person_add_alt_1_outlined,
              'ថ្មី',
              state.newCount.toString(),
              Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              Icons.workspace_premium_outlined,
              'VIP',
              state.vipCount.toString(),
              Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              Icons.person_off_outlined,
              'អសកម្ម',
              state.inactiveCount.toString(),
              Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'អតិថិជន',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            ref.read(customerProvider.notifier).setSearchQuery(val);
          },
          decoration: InputDecoration(
            hintText: 'ស្វែងរកដោយឈ្មោះ លេខទូរស័ព្ទ ឬអ៊ីមែល...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(customerProvider.notifier).setSearchQuery('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(CustomerState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tabs.length, (index) {
          final isSelected = state.selectedFilterTabIndex == index;
          return GestureDetector(
            onTap: () {
              ref.read(customerProvider.notifier).setFilterTab(index);
            },
            child: Column(
              children: [
                Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 50,
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterRow(CustomerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'ទាំងអស់ (${state.filteredCustomers.length})',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.swap_vert, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'ថ្មីបំផុត',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(List<CustomerModel> customers) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final customer = customers[index];
        final avatarColor = _avatarColors[customer.id % _avatarColors.length];

        String dateStr = 'មិនទាន់មាន';
        if (customer.createdAt != null) {
          final dt = customer.createdAt!;
          dateStr =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        }

        return InkWell(
          onTap: () => _showCustomerOptions(context, customer),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    customer.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.green[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.phone?.isNotEmpty == true
                                  ? customer.phone!
                                  : 'គ្មានលេខទូរស័ព្ទ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (customer.email != null && customer.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined,
                                  size: 11, color: Colors.blue[300]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ការប្រើប្រាស់',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${customer.totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 10,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        );
      }, childCount: customers.length),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'រកមិនឃើញអតិថិជនឡើយ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'សូមចុចប៊ូតុង "+" ខាងលើ ដើម្បីបន្ថែមអតិថិជនថ្មី',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddCustomerSheet(context),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'បន្ថែមអតិថិជន',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(customerProvider.notifier).loadCustomers();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('ព្យាយាមម្តងទៀត'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MODALS & DIALOGS ====================

  void _showAddCustomerSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'បន្ថែមអតិថិជនថ្មី',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: nameController,
                        label: 'ឈ្មោះអតិថិជន *',
                        hint: 'ឧទាហរណ៍៖ សុខ ជា',
                        icon: Icons.person_outline,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'សូមបញ្ចូលឈ្មោះអតិថិជន';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: phoneController,
                        label: 'លេខទូរស័ព្ទ',
                        hint: 'ឧទាហរណ៍៖ 012 345 678',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emailController,
                        label: 'អ៊ីមែល',
                        hint: 'ឧទាហរណ៍៖ user@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: addressController,
                        label: 'អាសយដ្ឋាន',
                        hint: 'រាជធានីភ្នំពេញ...',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final newCustomer = CustomerCreate(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim().isEmpty
                                        ? null
                                        : phoneController.text.trim(),
                                    email: emailController.text.trim().isEmpty
                                        ? null
                                        : emailController.text.trim(),
                                    address: addressController.text.trim().isEmpty
                                        ? null
                                        : addressController.text.trim(),
                                  );

                                  setModalState(() => isSubmitting = true);
                                  final success = await ref
                                      .read(customerProvider.notifier)
                                      .createCustomer(newCustomer);

                                  if (!bottomSheetContext.mounted) return;
                                  setModalState(() => isSubmitting = false);
                                  if (success) {
                                    Navigator.pop(bottomSheetContext);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('បានបន្ថែមអតិថិជនជោគជ័យ'),
                                        backgroundColor: Color(0xFF4CAF50),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    final err = ref.read(customerProvider).errorMessage ??
                                        'បរាជ័យក្នុងការបន្ថែមអតិថិជន';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'រក្សាទុកអតិថិជន',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerOptions(BuildContext context, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _avatarColors[customer.id % _avatarColors.length],
                    child: Text(customer.initials),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    customer.phone?.isNotEmpty == true
                        ? customer.phone!
                        : (customer.email ?? 'គ្មានលេខទូរស័ព្ទ'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                  title: const Text('កែប្រែព័ត៌មានអតិថិជន'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _showEditCustomerSheet(context, customer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('លុបអតិថិជន',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _showDeleteConfirmDialog(context, customer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditCustomerSheet(BuildContext context, CustomerModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone ?? '');
    final emailController = TextEditingController(text: customer.email ?? '');
    final addressController =
        TextEditingController(text: customer.address ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'កែប្រែព័ត៌មានអតិថិជន',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: nameController,
                        label: 'ឈ្មោះអតិថិជន *',
                        icon: Icons.person_outline,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'សូមបញ្ចូលឈ្មោះអតិថិជន';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: phoneController,
                        label: 'លេខទូរស័ព្ទ',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emailController,
                        label: 'អ៊ីមែល',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: addressController,
                        label: 'អាសយដ្ឋាន',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final updateData = CustomerUpdate(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim().isEmpty
                                        ? null
                                        : phoneController.text.trim(),
                                    email: emailController.text.trim().isEmpty
                                        ? null
                                        : emailController.text.trim(),
                                    address: addressController.text.trim().isEmpty
                                        ? null
                                        : addressController.text.trim(),
                                  );

                                  setModalState(() => isSubmitting = true);
                                  final success = await ref
                                      .read(customerProvider.notifier)
                                      .updateCustomer(customer.id, updateData);

                                  if (!bottomSheetContext.mounted) return;
                                  setModalState(() => isSubmitting = false);
                                  if (success) {
                                    Navigator.pop(bottomSheetContext);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'បានកែប្រែព័ត៌មានអតិថិជនជោគជ័យ'),
                                        backgroundColor: Color(0xFF4CAF50),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    final err = ref
                                            .read(customerProvider)
                                            .errorMessage ??
                                        'បរាជ័យក្នុងការកែប្រែព័ត៌មានអតិថិជន';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'រក្សាទុកការកែប្រែ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('បញ្ជាក់ការលុប'),
          content: Text('តើអ្នកពិតជាចង់លុបអតិថិជន "${customer.name}" មែនទេ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('បោះបង់', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await ref
                    .read(customerProvider.notifier)
                    .deleteCustomer(customer.id);

                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('បានលុបអតិថិជនជោគជ័យ'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final err = ref.read(customerProvider).errorMessage ??
                      'បរាជ័យក្នុងការលុបអតិថិជន';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('លុប'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

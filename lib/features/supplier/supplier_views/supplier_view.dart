import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supplier_controllers/supplier_controller.dart';
import '../supplier_models/supplier_model.dart';

class SupplierView extends ConsumerStatefulWidget {
  const SupplierView({super.key});

  @override
  ConsumerState<SupplierView> createState() => _SupplierViewState();
}

class _SupplierViewState extends ConsumerState<SupplierView> {
  final TextEditingController _searchController = TextEditingController();

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
    final supplierState = ref.watch(supplierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'អ្នកផ្គត់ផ្គង់',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'ទាញយកទិន្នន័យឡើងវិញ',
            onPressed: () {
              ref.read(supplierProvider.notifier).loadSuppliers();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'បន្ថែមអ្នកផ្គត់ផ្គង់ថ្មី',
                onPressed: () => _showAddSupplierSheet(context),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4CAF50),
          onRefresh: () async {
            await ref
                .read(supplierProvider.notifier)
                .loadSuppliers(showLoading: false);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryCard(supplierState),
                      const SizedBox(height: 12),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
              if (supplierState.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  ),
                )
              else if (supplierState.errorMessage != null &&
                  supplierState.allSuppliers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorView(supplierState.errorMessage!),
                )
              else if (supplierState.filteredSuppliers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyView(),
                )
              else
                _buildSupplierList(supplierState.filteredSuppliers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SupplierState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'អ្នកផ្គត់ផ្គង់សរុប',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                '${state.totalCount} ក្រុមហ៊ុន/បុគ្គល',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          ref.read(supplierProvider.notifier).setSearchQuery(val);
        },
        decoration: InputDecoration(
          hintText: 'ស្វែងរកតាមឈ្មោះ លេខទូរស័ព្ទ អ៊ីមែល...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(supplierProvider.notifier).setSearchQuery('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSupplierList(List<SupplierModel> suppliers) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final supplier = suppliers[index];
        final avatarColor = _avatarColors[supplier.id % _avatarColors.length];

        String dateStr = 'មិនទាន់មាន';
        if (supplier.createdAt != null) {
          final dt = supplier.createdAt!;
          dateStr =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        }

        return InkWell(
          onTap: () => _showSupplierOptions(context, supplier),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                  radius: 22,
                  backgroundColor: avatarColor,
                  child: Text(
                    supplier.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.green[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier.phone?.isNotEmpty == true
                                  ? supplier.phone!
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
                      if (supplier.address != null &&
                          supplier.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 11, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  supplier.address!,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
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
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
                  ],
                ),
              ],
            ),
          ),
        );
      }, childCount: suppliers.length),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'រកមិនឃើញអ្នកផ្គត់ផ្គង់ឡើយ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'សូមចុចប៊ូតុង "+" ខាងលើ ដើម្បីបន្ថែមអ្នកផ្គត់ផ្គង់ថ្មី',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddSupplierSheet(context),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'បន្ថែមអ្នកផ្គត់ផ្គង់',
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
                ref.read(supplierProvider.notifier).loadSuppliers();
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

  void _showAddSupplierSheet(BuildContext context) {
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
                            'បន្ថែមអ្នកផ្គត់ផ្គង់ថ្មី',
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
                        label: 'ឈ្មោះអ្នកផ្គត់ផ្គង់ *',
                        hint: 'ឧទាហរណ៍៖ ក្រុមហ៊ុន ខ្មែរ ប៊េស',
                        icon: Icons.business_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'សូមបញ្ចូលឈ្មោះអ្នកផ្គត់ផ្គង់';
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
                        hint: 'ឧទាហរណ៍៖ supplier@example.com',
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

                                  final newSupplier = SupplierCreate(
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
                                      .read(supplierProvider.notifier)
                                      .createSupplier(newSupplier);

                                  if (!bottomSheetContext.mounted) return;
                                  setModalState(() => isSubmitting = false);

                                  if (success) {
                                    Navigator.pop(bottomSheetContext);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('បានបន្ថែមអ្នកផ្គត់ផ្គង់ជោគជ័យ'),
                                        backgroundColor: Color(0xFF4CAF50),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    final err = ref
                                            .read(supplierProvider)
                                            .errorMessage ??
                                        'បរាជ័យក្នុងការបន្ថែមអ្នកផ្គត់ផ្គង់';
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
                                  'រក្សាទុកអ្នកផ្គត់ផ្គង់',
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

  void _showSupplierOptions(BuildContext context, SupplierModel supplier) {
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
                        _avatarColors[supplier.id % _avatarColors.length],
                    child: Text(supplier.initials),
                  ),
                  title: Text(
                    supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    supplier.phone?.isNotEmpty == true
                        ? supplier.phone!
                        : (supplier.email ?? 'គ្មានលេខទូរស័ព្ទ'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                  title: const Text('កែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _showEditSupplierSheet(context, supplier);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('លុបអ្នកផ្គត់ផ្គង់',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _showDeleteConfirmDialog(context, supplier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditSupplierSheet(BuildContext context, SupplierModel supplier) {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone ?? '');
    final emailController = TextEditingController(text: supplier.email ?? '');
    final addressController =
        TextEditingController(text: supplier.address ?? '');
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
                            'កែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់',
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
                        label: 'ឈ្មោះអ្នកផ្គត់ផ្គង់ *',
                        icon: Icons.business_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'សូមបញ្ចូលឈ្មោះអ្នកផ្គត់ផ្គង់';
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

                                  final updateData = SupplierUpdate(
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
                                      .read(supplierProvider.notifier)
                                      .updateSupplier(supplier.id, updateData);

                                  if (!bottomSheetContext.mounted) return;
                                  setModalState(() => isSubmitting = false);

                                  if (success) {
                                    Navigator.pop(bottomSheetContext);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'បានកែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់ជោគជ័យ'),
                                        backgroundColor: Color(0xFF4CAF50),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    final err = ref
                                            .read(supplierProvider)
                                            .errorMessage ??
                                        'បរាជ័យក្នុងការកែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់';
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

  void _showDeleteConfirmDialog(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('បញ្ជាក់ការលុប'),
          content: Text('តើអ្នកពិតជាចង់លុបអ្នកផ្គត់ផ្គង់ "${supplier.name}" មែនទេ?'),
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
                    .read(supplierProvider.notifier)
                    .deleteSupplier(supplier.id);

                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('បានលុបអ្នកផ្គត់ផ្គង់ជោគជ័យ'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final err = ref.read(supplierProvider).errorMessage ??
                      'បរាជ័យក្នុងការលុបអ្នកផ្គត់ផ្គង់';
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
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
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

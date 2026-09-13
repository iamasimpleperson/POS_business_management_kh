import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../purchase_controllers/purchase_controller.dart';
import '../purchase_models/purchase_model.dart';
import '../../stock/stock_model/stock_model.dart';
import '../../supplier/supplier_views/supplier_view.dart';

class PurchaseView extends ConsumerStatefulWidget {
  const PurchaseView({super.key});

  @override
  ConsumerState<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends ConsumerState<PurchaseView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseProvider);
    final controller = ref.read(purchaseProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'ទិញទំនិញចូល (Purchase)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'ទាញយកទិន្នន័យឡើងវិញ',
            onPressed: () => controller.loadData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_shopping_cart, size: 18),
                  const SizedBox(width: 6),
                  const Text('បញ្ជាទិញចូល'),
                  if (state.cartItems.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 18),
                  SizedBox(width: 6),
                  Text('ប្រវត្តិទិញចូល'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNewPurchaseTab(context, state, controller),
                _buildHistoryTab(context, state, controller),
              ],
            ),
    );
  }

  // ==================== TAB 1: NEW PURCHASE ====================

  Widget _buildNewPurchaseTab(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier controller,
  ) {
    return Column(
      children: [
        // Supplier selection bar
        _buildSupplierSelector(context, state, controller),

        // Product search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: controller.updateSearch,
                    decoration: const InputDecoration(
                      hintText: 'ស្វែងរកទំនិញតាមឈ្មោះ ឬបាកូដ...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      controller.updateSearch('');
                    },
                    child: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  ),
              ],
            ),
          ),
        ),

        // Products list
        Expanded(
          child: state.filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'រកមិនឃើញទំនិញទេ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  itemCount: state.filteredProducts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    final inCart =
                        state.cartItems.any((c) => c.product.id == product.id);
                    return _buildProductListItem(
                      product,
                      inCart,
                      controller,
                    );
                  },
                ),
        ),

        // Cart section bottom
        _buildCartBottomSection(context, state, controller),
      ],
    );
  }

  Widget _buildSupplierSelector(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier controller,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: Color(0xFF2E7D32),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                value: state.selectedSupplierId,
                hint: const Text(
                  'ជ្រើសរើសអ្នកផ្គត់ផ្គង់ (Supplier)...',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'ទូទៅ (គ្មានអ្នកផ្គត់ផ្គង់ជាក់លាក់)',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  ...state.suppliers.map(
                    (s) => DropdownMenuItem<int?>(
                      value: s.id,
                      child: Text(
                        '${s.name} ${s.phone != null ? "(${s.phone})" : ""}',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (id) => controller.selectSupplier(id),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_outlined,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            tooltip: 'បន្ថែមអ្នកផ្គត់ផ្គង់',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupplierView()),
              ).then((_) => controller.loadData());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(
    ProductModel product,
    bool inCart,
    PurchaseNotifier controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inCart ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'ថ្លៃដើម: \$${product.costPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'លក់: \$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ស្តុកបច្ចុប្បន្ន: ${product.stock} ${product.unit ?? ""}',
                  style: TextStyle(
                    color: product.stock <= 5 ? Colors.red : Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.addToCart(product),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  inCart ? const Color(0xFFE8F5E9) : const Color(0xFF2E7D32),
              foregroundColor:
                  inCart ? const Color(0xFF2E7D32) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: const Color(0xFF2E7D32),
                  width: inCart ? 1 : 0,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(inCart ? Icons.check : Icons.add, size: 15),
                const SizedBox(width: 4),
                Text(
                  inCart ? 'បានជ្រើស' : 'ទិញចូល',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomSection(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier controller,
  ) {
    if (state.cartItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'សូមជ្រើសរើសទំនិញដែលត្រូវទិញចូល',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'កន្ត្រកទិញចូល (${state.cartItems.length} មុខ)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: controller.clearCart,
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      SizedBox(width: 2),
                      Text(
                        'សម្អាត',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Itemized list (max 140 height)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.20,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              itemCount: state.cartItems.length,
              separatorBuilder: (c, i) => const Divider(height: 6),
              itemBuilder: (context, index) {
                final item = state.cartItems[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          GestureDetector(
                            onTap: () => _showCostPriceDialog(
                              context,
                              item,
                              controller,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '\$${item.costPrice.toStringAsFixed(2)} / ឯកតា',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 11,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity +/-
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              controller.updateQuantity(item.product.id, -1),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.remove, size: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item.quantity.toInt().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              controller.updateQuantity(item.product.id, 1),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Subtotal
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 12),

          // Total & Checkout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'សរុបចំណាយទិញចូល',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        '\$${state.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showConfirmPurchaseSheet(context, state, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'បញ្ជាក់ការទិញចូល',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCostPriceDialog(
    BuildContext context,
    PurchaseCartItem item,
    PurchaseNotifier controller,
  ) {
    final ctrl =
        TextEditingController(text: item.costPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'កែប្រែថ្លៃដើម (${item.product.name})',
          style: const TextStyle(fontSize: 15),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(),
            hintText: '0.00',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val >= 0) {
                controller.updateCostPrice(item.product.id, val);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text(
              'រក្សាទុក',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmPurchaseSheet(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier controller,
  ) {
    final invoiceCtrl = TextEditingController(
      text:
          'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );
    final paidCtrl =
        TextEditingController(text: state.subtotal.toStringAsFixed(2));
    DateTime selectedDate = DateTime.now();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              ),
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'បញ្ជាក់ការទិញទំនិញចូល',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Amount display
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ទឹកប្រាក់ត្រូវទូទាត់៖',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${state.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Invoice No
                    const Text(
                      'លេខវិក្កយបត្រ (Invoice No)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: invoiceCtrl,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Paid amount
                    const Text(
                      'ប្រាក់បានទូទាត់ (\$)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: paidCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final paidVal =
                                    double.tryParse(paidCtrl.text.trim()) ??
                                    state.subtotal;

                                setSheetState(() => isSubmitting = true);

                                final purchaseRes =
                                    await controller.createPurchase(
                                  supplierId: state.selectedSupplierId,
                                  invoiceNo: invoiceCtrl.text.trim(),
                                  paidAmount: paidVal,
                                  purchaseDate: selectedDate,
                                );

                                if (!sheetCtx.mounted) return;
                                setSheetState(() => isSubmitting = false);

                                if (purchaseRes != null) {
                                  Navigator.pop(sheetCtx);
                                  if (!context.mounted) return;
                                  _showPurchaseReceiptDialog(
                                    context,
                                    purchaseRes,
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  final err =
                                      ref.read(purchaseProvider).errorMessage ??
                                      'បរាជ័យក្នុងការទិញចូល';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(err),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
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
                                'បង្កើតការទិញចូល (Confirm)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPurchaseReceiptDialog(
    BuildContext context,
    PurchaseResponse purchase,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF2E7D32),
                size: 38,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ទិញទំនិញចូលជោគជ័យ!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'វិក្កយបត្រ៖ ${purchase.invoiceNo ?? "PO-${purchase.id}"}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            _receiptRow(
              'សរុបទឹកប្រាក់៖',
              '\$${purchase.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 6),
            _receiptRow(
              'ប្រាក់បានបង់៖',
              '\$${purchase.paidAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 6),
            _receiptRow(
              'ស្ថានភាពបង់ប្រាក់៖',
              purchase.paymentStatus,
            ),
            const SizedBox(height: 6),
            _receiptRow(
              'ចំនួនមុខទំនិញ៖',
              '${purchase.items.length} មុខ',
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _tabController.animateTo(1); // Switch to history tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'មើលប្រវត្តិទិញចូល',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: PURCHASE HISTORY ====================

  Widget _buildHistoryTab(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier controller,
  ) {
    if (state.history.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF2E7D32),
        onRefresh: () => controller.loadData(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'មិនទាន់មានប្រវត្តិទិញចូលទេ',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: () => controller.loadData(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: state.history.length,
        separatorBuilder: (c, i) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = state.history[index];
          final isFullyPaid = p.paidAmount >= p.totalAmount;
          return InkWell(
            onTap: () => _showHistoryDetailDialog(context, p),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.receipt_outlined,
                              color: Color(0xFF2E7D32),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.invoiceNo ?? 'PO-${p.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isFullyPaid
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isFullyPaid ? 'បង់រួច' : 'ជំពាក់',
                          style: TextStyle(
                            color: isFullyPaid
                                ? const Color(0xFF2E7D32)
                                : Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.supplierName != null &&
                                    p.supplierName!.trim().isNotEmpty
                                ? 'អ្នកផ្គត់ផ្គង់៖ ${p.supplierName}'
                                : 'អ្នកផ្គត់ផ្គង់ទូទៅ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.purchaseDate != null
                                ? '${p.purchaseDate!.day}/${p.purchaseDate!.month}/${p.purchaseDate!.year}'
                                : (p.createdAt != null
                                    ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year}'
                                    : ''),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${p.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          if (!isFullyPaid)
                            Text(
                              'បង់: \$${p.paidAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.deepOrange,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHistoryDetailDialog(BuildContext context, PurchaseResponse p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              p.invoiceNo ?? 'PO-${p.id}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _receiptRow(
                'អ្នកផ្គត់ផ្គង់៖',
                p.supplierName ?? 'ទូទៅ',
              ),
              const SizedBox(height: 6),
              _receiptRow(
                'កាលបរិច្ឆេទ៖',
                p.purchaseDate != null
                    ? '${p.purchaseDate!.day}/${p.purchaseDate!.month}/${p.purchaseDate!.year}'
                    : '-',
              ),
              const SizedBox(height: 6),
              _receiptRow(
                'សរុបទឹកប្រាក់៖',
                '\$${p.totalAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _receiptRow(
                'ប្រាក់បានបង់៖',
                '\$${p.paidAmount.toStringAsFixed(2)}',
              ),
              if (p.items.isNotEmpty) ...[
                const Divider(height: 20),
                const Text(
                  'មុខទំនិញទិញចូល៖',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...p.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.productName ?? "ទំនិញ #${item.productId}"} x ${item.quantity.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បិទ'),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

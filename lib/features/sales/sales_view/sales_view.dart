import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sales_controller.dart';
import '../sales_model/sales_model.dart';
import '../../stock/stock_model/stock_model.dart';
import '../../customer/customer_controllers/customer_controller.dart';

class SalesView extends ConsumerWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesProvider);
    final controller = ref.read(salesProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'លក់ទំនិញ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black87),
                    tooltip: 'ទាញយកទិន្នន័យឡើងវិញ',
                    onPressed: () => controller.loadProducts(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: controller.updateSearch,
                              decoration: const InputDecoration(
                                hintText: 'ស្វែងរកទំនិញតាមឈ្មោះ ឬកូដ...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final cat = state.categories[index];
                  final isSelected = state.selectedCategory?.name == cat.name;
                  return GestureDetector(
                    onTap: () => controller.selectCategory(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(cat.name),
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Products Grid
            Expanded(
              child: state.filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'រកមិនឃើញទំនិញឡើយ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: state.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = state.filteredProducts[index];
                        return _buildProductCard(product, controller);
                      },
                    ),
            ),

            // Cart Section (Bottom Fixed)
            _buildCartSection(context, state, controller, ref),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'កាហ្វេ':
        return Icons.coffee;
      case 'តែ':
        return Icons.emoji_food_beverage;
      case 'នំប៉័ងនិងនំ':
        return Icons.bakery_dining;
      case 'ភេសជ្ជៈ':
        return Icons.local_drink;
      default:
        return Icons.grid_view;
    }
  }

  Widget _buildProductCard(ProductModel product, SalesNotifier controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: product.category.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(product.category.name),
              color: product.category.textColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ស្តុក ${product.stock}',
                      style: TextStyle(
                        color: product.stock <= 0 ? Colors.red : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF2E7D32),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection(
    BuildContext context,
    SalesState state,
    SalesNotifier controller,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'កន្ត្រកទំនិញ (${state.totalItems})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (state.cartItems.isNotEmpty)
                  GestureDetector(
                    onTap: controller.clearCart,
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 16),
                        SizedBox(width: 4),
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

          // Cart Items List
          if (state.cartItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'មិនទាន់មានទំនិញក្នុងកន្ត្រកទេ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.22,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: state.cartItems.length,
                separatorBuilder: (context, index) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final item = state.cartItems[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              child: const Icon(
                                Icons.remove,
                                size: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
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

          const Divider(height: 16),

          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'សរុបរង',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '\$${state.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _showDiscountDialog(context, state, controller),
                      child: const Row(
                        children: [
                          Text(
                            'បញ្ចុះតម្លៃ ',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.green,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _showDiscountDialog(context, state, controller),
                      child: Text(
                        '-\$${state.discount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'សរុបត្រូវទូទាត់',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '\$${state.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentMethod(
                  Icons.money,
                  'សាច់ប្រាក់',
                  'CASH',
                  state.selectedPaymentMethod == 'CASH',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.account_balance,
                  'ធនាគារ',
                  'BANK',
                  state.selectedPaymentMethod == 'BANK',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.qr_code,
                  'QR',
                  'QR',
                  state.selectedPaymentMethod == 'QR',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.credit_card,
                  'ជំពាក់',
                  'DEBT',
                  state.selectedPaymentMethod == 'DEBT',
                  controller,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Checkout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: state.cartItems.isEmpty
                  ? null
                  : () => _showCheckoutSheet(context, state, controller, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ទូទាត់ប្រាក់',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    IconData icon,
    String title,
    String methodCode,
    bool isSelected,
    SalesNotifier controller,
  ) {
    return GestureDetector(
      onTap: () => controller.setPaymentMethod(methodCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountDialog(
    BuildContext context,
    SalesState state,
    SalesNotifier controller,
  ) {
    final discountCtrl = TextEditingController(
      text: state.discount > 0 ? state.discount.toString() : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'បញ្ចូលការបញ្ចុះតម្លៃ (\$)',
            style: TextStyle(fontSize: 16),
          ),
          content: TextField(
            controller: discountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('បោះបង់'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(discountCtrl.text.trim()) ?? 0.0;
                controller.setDiscount(val);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text(
                'យល់ព្រម',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutSheet(
    BuildContext context,
    SalesState state,
    SalesNotifier controller,
    WidgetRef ref,
  ) {
    final customers = ref.read(customerProvider).allCustomers;
    int? selectedCustomerId = state.selectedCustomerId;
    String selectedPaymentMethod =
        (state.selectedPaymentMethod as dynamic) ?? 'CASH';
    final paidCtrl = TextEditingController(
      text: selectedPaymentMethod == 'DEBT'
          ? '0.00'
          : state.grandTotal.toStringAsFixed(2),
    );
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final double grandTotal = state.grandTotal;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
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
                          'បញ្ជាក់ការទូទាត់ប្រាក់',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Amount Due Display
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
                            'ទឹកប្រាក់សរុប៖',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${grandTotal.toStringAsFixed(2)}',
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

                    // Customer Selection
                    const Text(
                      'អតិថិជន (Customer)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: selectedCustomerId,
                          hint: const Text('អតិថិជនទូទៅ (Walk-in)'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('អតិថិជនទូទៅ (Walk-in)'),
                            ),
                            ...customers.map(
                              (c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(
                                  '${c.name} (${c.phone ?? "គ្មានលេខ"})',
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setModalState(() {
                              selectedCustomerId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method in Modal
                    const Text(
                      'វិធីសាស្ត្រទូទាត់',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _modalPaymentOption(
                          'សាច់ប្រាក់',
                          'CASH',
                          selectedPaymentMethod,
                          (m) {
                            setModalState(() {
                              selectedPaymentMethod = m;
                              paidCtrl.text = grandTotal.toStringAsFixed(2);
                            });
                          },
                        ),
                        _modalPaymentOption(
                          'ធនាគារ',
                          'BANK',
                          selectedPaymentMethod,
                          (m) {
                            setModalState(() {
                              selectedPaymentMethod = m;
                              paidCtrl.text = grandTotal.toStringAsFixed(2);
                            });
                          },
                        ),
                        _modalPaymentOption('QR', 'QR', selectedPaymentMethod, (
                          m,
                        ) {
                          setModalState(() {
                            selectedPaymentMethod = m;
                            paidCtrl.text = grandTotal.toStringAsFixed(2);
                          });
                        }),
                        _modalPaymentOption(
                          'ជំពាក់',
                          'DEBT',
                          selectedPaymentMethod,
                          (m) {
                            setModalState(() {
                              selectedPaymentMethod = m;
                              paidCtrl.text = '0.00';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Paid Amount Input
                    const Text(
                      'ប្រាក់ទទួលបានជាក់ស្តែង (\$)',
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

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final paidVal =
                                    double.tryParse(paidCtrl.text.trim()) ??
                                    0.0;

                                setModalState(() => isSubmitting = true);

                                final saleRes = await controller.checkout(
                                  customerId: selectedCustomerId,
                                  paymentMethod: selectedPaymentMethod,
                                  customPaidAmount: paidVal,
                                );

                                if (!sheetContext.mounted) return;
                                setModalState(() => isSubmitting = false);

                                if (saleRes != null) {
                                  Navigator.pop(sheetContext);
                                  if (!context.mounted) return;
                                  _showReceiptDialog(context, saleRes);
                                } else {
                                  if (!context.mounted) return;
                                  final err =
                                      ref.read(salesProvider).errorMessage ??
                                      'បរាជ័យក្នុងការលក់';
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
                                'បញ្ជាក់ការលក់',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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

  Widget _modalPaymentOption(
    String title,
    String code,
    String currentCode,
    Function(String) onSelect,
  ) {
    final isSelected = currentCode == code;
    return GestureDetector(
      onTap: () => onSelect(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, SaleResponse sale) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                  Icons.check,
                  color: Color(0xFF2E7D32),
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ការលក់ទទួលបានជោគជ័យ!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'វិក្កយបត្រ៖ ${sale.invoiceNo ?? "INV-${sale.id}"}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              _receiptRow(
                'សរុបទឹកប្រាក់៖',
                '\$${sale.totalAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _receiptRow(
                'ប្រាក់បានបង់៖',
                '\$${sale.paidAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _receiptRow('វិធីសាស្ត្រ៖', sale.paymentMethod ?? 'CASH'),
              const SizedBox(height: 6),
              _receiptRow('ស្ថានភាព៖', sale.status),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'យល់ព្រម',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
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

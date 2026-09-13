import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';
import '../sales_model/sales_model.dart';
import '../../stock/stock_model/stock_model.dart';
import '../../customer/customer_controllers/customer_controller.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();

    return Obx(() {
      if (controller.isLoading.value) {
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
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    final isSelected = controller.selectedCategory.value?.name == cat.name;
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
                child: controller.filteredProducts.isEmpty
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
                        itemCount: controller.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = controller.filteredProducts[index];
                          return _buildProductCard(product, controller);
                        },
                      ),
              ),

              // Cart Section (Bottom Fixed)
              _buildCartSection(context, controller),
            ],
          ),
        ),
      );
    });
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'កាហ្វេ':
        return Icons.local_cafe_outlined;
      case 'តែ':
        return Icons.emoji_food_beverage_outlined;
      case 'ភេសជ្ជៈ':
        return Icons.wine_bar_outlined;
      case 'នំខេក':
        return Icons.cake_outlined;
      case 'អាហារសម្រន់':
        return Icons.fastfood_outlined;
      default:
        return Icons.grid_view;
    }
  }

  Widget _buildProductCard(ProductModel product, SalesController controller) {
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
    SalesController controller,
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
                  'កន្ត្រកទំនិញ (${controller.totalItems})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (controller.cartItems.isNotEmpty)
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

          // Items list in cart
          if (controller.cartItems.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shrinkWrap: true,
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              color: Colors.grey.shade600,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => controller.updateQuantity(
                                item.product.id,
                                -1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              color: const Color(0xFF2E7D32),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => controller.updateQuantity(
                                item.product.id,
                                1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const Divider(height: 1),

          // Total Calculation Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'សរុប (Subtotal)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${controller.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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
                      onTap: () => _showDiscountDialog(context, controller),
                      child: Row(
                        children: [
                          Text(
                            'បញ្ចុះតម្លៃ (Discount)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-\$${controller.discount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'សរុបចុងក្រោយ (Total)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${controller.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Method Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentMethod(
                  Icons.payments_outlined,
                  'សាច់ប្រាក់',
                  'CASH',
                  controller.selectedPaymentMethod.value == 'CASH',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.account_balance_outlined,
                  'ធនាគារ',
                  'BANK',
                  controller.selectedPaymentMethod.value == 'BANK',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.qr_code,
                  'QR',
                  'QR',
                  controller.selectedPaymentMethod.value == 'QR',
                  controller,
                ),
                _buildPaymentMethod(
                  Icons.credit_card,
                  'ជំពាក់',
                  'DEBT',
                  controller.selectedPaymentMethod.value == 'DEBT',
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
              onPressed: controller.cartItems.isEmpty
                  ? null
                  : () => _showCheckoutSheet(context, controller),
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
    SalesController controller,
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
    SalesController controller,
  ) {
    final discountCtrl = TextEditingController(
      text: controller.discount > 0 ? controller.discount.toString() : '',
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
    SalesController controller,
  ) {
    final customerController = Get.find<CustomerController>();
    final customers = customerController.allCustomers;
    int? selectedCustomerId = controller.selectedCustomerId.value;
    String selectedPaymentMethod = controller.selectedPaymentMethod.value;
    final paidCtrl = TextEditingController(
      text: selectedPaymentMethod == 'DEBT'
          ? '0.00'
          : controller.grandTotal.toStringAsFixed(2),
    );
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final double grandTotal = controller.grandTotal;

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
                        prefixText: '\$',
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

                    // Error Message Display inside Modal
                    if (modalError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
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
                      const SizedBox(height: 12),
                    ],

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

                                setModalState(() {
                                  isSubmitting = true;
                                  modalError = null;
                                });

                                final saleRes = await controller.checkout(
                                  customerId: selectedCustomerId,
                                  paymentMethod: selectedPaymentMethod,
                                  customPaidAmount: paidVal,
                                );

                                if (!sheetContext.mounted) return;

                                if (saleRes != null) {
                                  setModalState(() => isSubmitting = false);
                                  Navigator.pop(sheetContext);
                                  if (!context.mounted) return;
                                  _showReceiptDialog(context, saleRes);
                                } else {
                                  final err =
                                      controller.errorMessage.value ??
                                      'បរាជ័យក្នុងការលក់';
                                  setModalState(() {
                                    isSubmitting = false;
                                    modalError = err;
                                  });
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'រួចរាល់',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

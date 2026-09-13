import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/stock_controller.dart';
import '../stock_model/stock_model.dart';
import '../../purchase/purchase_views/purchase_view.dart';

class StockView extends ConsumerStatefulWidget {
  const StockView({super.key});

  @override
  ConsumerState<StockView> createState() => _StockViewState();
}

class _StockViewState extends ConsumerState<StockView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockProvider);
    final controller = ref.read(stockProvider.notifier);

    if (state.isLoading && state.allProducts.isEmpty) {
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
        child: RefreshIndicator(
          color: const Color(0xFF2E7D32),
          onRefresh: () => controller.loadProducts(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 28),
                      tooltip: 'ទាញយកទិន្នន័យឡើងវិញ',
                      onPressed: () => controller.loadProducts(),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, size: 28),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              _searchController.clear();
                              controller.setSearchQuery('');
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined, size: 26, color: Color(0xFF2E7D32)),
                          tooltip: 'ទិញទំនិញចូល (Purchase)',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PurchaseView(),
                              ),
                            ).then((_) => controller.loadProducts());
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: 'បន្ថែមទំនិញថ្មី',
                            onPressed: () => _showAddProductDialog(context, controller, state),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Title and Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ទំនិញ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'គ្រប់គ្រងទំនិញ និងស្តុកជាក់ស្តែង',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error banner if any
              if (state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.loadProducts(),
                        child: const Text('ព្យាយាមម្តងទៀត', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              // Stats Row (Calculated from Real Database)
              SizedBox(
                height: 90,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.stats.length,
                  itemBuilder: (context, index) {
                    final stat = state.stats[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(stat.icon, size: 16, color: stat.color),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  stat.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stat.count}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: stat.color,
                            ),
                          ),
                          Text(
                            stat.subtitle,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'ទាំងអស់', state, controller),
                    _buildFilterTab(1, 'ស្តុកទាប', state, controller),
                    _buildFilterTab(2, 'អស់', state, controller),
                    _buildFilterTab(3, 'បិទ', state, controller),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => controller.setSearchQuery(val),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            hintText: 'ស្វែងរកតាមឈ្មោះ ឬកូដទំនិញ...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      controller.setSearchQuery('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Product List or Empty State
              Expanded(
                child: state.filteredProducts.isEmpty
                    ? _buildEmptyState(state, controller)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.filteredProducts.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Colors.black12),
                        itemBuilder: (context, index) {
                          final product = state.filteredProducts[index];
                          return InkWell(
                            onTap: () => _showProductOptions(context, controller, product),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                              child: Row(
                                children: [
                                  // Product Icon
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: product.stock > 0
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: product.stock > 0
                                          ? const Color(0xFF2E7D32)
                                          : Colors.red.shade300,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          product.code,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.category.bgColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            product.category.name,
                                            style: TextStyle(
                                              color: product.category.textColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Stock and Price
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'ស្តុក',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product.stock}',
                                        style: TextStyle(
                                          color: product.stock > 15
                                              ? const Color(0xFF2E7D32)
                                              : (product.stock > 0
                                                  ? Colors.orange
                                                  : Colors.red),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(StockState state, StockNotifier controller) {
    final hasSearch = state.searchQuery.isNotEmpty;
    final isFiltered = state.selectedFilterTabIndex != 0;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'រកមិនឃើញទំនិញដែលត្រូវនឹង "${state.searchQuery}"'
                  : (isFiltered
                      ? 'មិនមានទំនិញក្នុងប្រភេទនេះទេ'
                      : 'មិនទាន់មានទំនិញក្នុងស្តុកនៅឡើយទេ'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'សូមសាកល្បងស្វែងរកដោយពាក្យគន្លឹះផ្សេងទៀត'
                  : 'ទិន្នន័យស្តុកពី Database នឹងបង្ហាញនៅទីនេះពេលអ្នកបន្ថែមទំនិញ',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!hasSearch && !isFiltered)
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context, controller, state),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'បន្ថែមទំនិញដំបូង',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  controller.setSearchQuery('');
                  controller.setFilterTab(0);
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                label: const Text(
                  'បង្ហាញទំនិញទាំងអស់',
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    int index,
    String title,
    StockState state,
    StockNotifier controller,
  ) {
    final isSelected = state.selectedFilterTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilterTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  )
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog to add a product directly into the database
  void _showAddProductDialog(
    BuildContext context,
    StockNotifier controller,
    StockState state,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    int? selectedCatId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'បន្ថែមទំនិញថ្មីទៅក្នុង Database',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Name
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ឈ្មោះទំនិញ *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price and Cost
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'តម្លៃលក់ (\$) *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'តម្លៃដើម (\$) (ជម្រើស)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Initial Stock and SKU
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'ចំនួនស្តុកដំបូង',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: skuCtrl,
                            decoration: const InputDecoration(
                              labelText: 'កូដទំនិញ / SKU',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category Selector
                    if (state.categories.isNotEmpty) ...[
                      DropdownButtonFormField<int?>(
                        initialValue: selectedCatId,
                        decoration: const InputDecoration(
                          labelText: 'ប្រភេទ',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('ទូទៅ (គ្មានប្រភេទ)'),
                          ),
                          ...state.categories.map((cat) {
                            return DropdownMenuItem<int?>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedCatId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text.trim());
                          if (name.isEmpty || price == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('សូមបញ្ចូលឈ្មោះ និងតម្លៃលក់ឱ្យបានត្រឹមត្រូវ'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final cost = double.tryParse(costCtrl.text.trim()) ?? 0.0;
                          final stock = double.tryParse(stockCtrl.text.trim()) ?? 0.0;
                          final sku = skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null;

                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(ctx);
                          final ok = await controller.createProduct(
                            name: name,
                            sellPrice: price,
                            costPrice: cost,
                            stockQty: stock,
                            sku: sku,
                            categoryId: selectedCatId,
                          );

                          if (!mounted) return;
                          if (ok) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('បានបន្ថែមទំនិញទៅក្នុង Database ជោគជ័យ'),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('បរាជ័យក្នុងការបន្ថែមទំនិញ'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'រក្សាទុកទៅ Database',
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
            );
          },
        );
      },
    );
  }

  /// Show product options (Adjust Stock / Delete)
  void _showProductOptions(
    BuildContext context,
    StockNotifier controller,
    ProductModel product,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'កូដ: ${product.code} | ស្តុកបច្ចុប្បន្ន: ${product.stock}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.tune, color: Color(0xFF2E7D32)),
                  title: const Text('កែសម្រួលស្តុក (Stock Adjustment)'),
                  subtitle: const Text('បន្ថែម ឬកាត់បន្ថយចំនួនក្នុង Database'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAdjustStockDialog(context, controller, product);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('លុបទំនិញ', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('លុបទំនិញនេះចេញពី Database'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        title: const Text('បញ្ជាក់ការលុប'),
                        content: Text('តើអ្នកពិតជាចង់លុបទំនិញ "${product.name}" ចេញពី Database មែនទេ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, false),
                            child: const Text('បោះបង់'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, true),
                            child: const Text('លុប', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final prodId = int.tryParse(product.id);
                      if (prodId != null) {
                        final ok = await controller.deleteProduct(prodId);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'បានលុបទំនិញជោគជ័យ' : 'បរាជ័យក្នុងការលុបទំនិញ'),
                            backgroundColor: ok ? const Color(0xFF2E7D32) : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dialog to adjust stock quantity in database
  void _showAdjustStockDialog(
    BuildContext context,
    StockNotifier controller,
    ProductModel product,
  ) {
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController(text: 'កែសម្រួលស្តុកដោយដៃ');
    bool isAdd = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: Text('កែសម្រួលស្តុក: ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ស្តុកបច្ចុប្បន្ន: ${product.stock}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('+ បន្ថែម')),
                          selected: isAdd,
                          selectedColor: const Color(0xFFE8F5E9),
                          onSelected: (val) {
                            setDialogState(() => isAdd = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('- កាត់បន្ថយ')),
                          selected: !isAdd,
                          selectedColor: Colors.red.shade50,
                          onSelected: (val) {
                            setDialogState(() => isAdd = false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'ចំនួនស្តុកកែសម្រួល',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'កំណត់សម្គាល់ (Note)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('បោះបង់'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  onPressed: () async {
                    final qtyVal = double.tryParse(qtyCtrl.text.trim());
                    if (qtyVal == null || qtyVal <= 0) {
                      return;
                    }
                    final finalQty = isAdd ? qtyVal : -qtyVal;
                    final prodId = int.tryParse(product.id);
                    if (prodId == null) return;

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final ok = await controller.adjustStock(
                      productId: prodId,
                      quantity: finalQty,
                      note: noteCtrl.text.trim(),
                    );

                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'បានកែសម្រួលស្តុកជោគជ័យ' : 'បរាជ័យក្នុងការកែសម្រួលស្តុក'),
                        backgroundColor: ok ? const Color(0xFF2E7D32) : Colors.red,
                      ),
                    );
                  },
                  child: const Text('យល់ព្រម', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

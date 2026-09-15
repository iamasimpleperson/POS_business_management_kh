import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../reports_controllers/report_controller.dart';
import '../../../core/localizations/language_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'reports_title'.tr,
          style: const TextStyle(
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
            tooltip: 'retry'.tr,
            onPressed: () => controller.loadAllReports(),
          ),
        ],
      ),
      body: Obx(() {
        LanguageController.to.currentLocale.value;
        return Column(
          children: [
            // Period Selector (Today, Week, Month)
            _buildPeriodSelector(controller),

            // Tab Selector (Profit/Loss, Sales, Inventory, Expenses)
            _buildTabSelector(controller),

            // Content Area
            Expanded(
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.loadAllReports(),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSelectedReport(controller),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPeriodSelector(ReportController controller) {
    final periods = ['period_today'.tr, 'period_last_7_days'.tr, 'period_this_month'.tr];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = controller.selectedPeriod.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changePeriod(index),
              child: Container(
                margin: EdgeInsets.only(right: index < periods.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  periods[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabSelector(ReportController controller) {
    final tabs = ['tab_profit_loss'.tr, 'tab_sales'.tr, 'tab_inventory'.tr, 'tab_expenses'.tr];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = controller.selectedTab.value == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(tabs[index]),
                selected: isSelected,
                onSelected: (_) => controller.changeTab(index),
                selectedColor: const Color(0xFF2E7D32),
                backgroundColor: const Color(0xFFF5F5F5),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSelectedReport(ReportController controller) {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildProfitLossReport(controller);
      case 1:
        return _buildSalesReport(controller);
      case 2:
        return _buildInventoryReport(controller);
      case 3:
        return _buildExpenseReport(controller);
      default:
        return _buildProfitLossReport(controller);
    }
  }

  // 1. Profit & Loss Report
  Widget _buildProfitLossReport(ReportController controller) {
    final p = controller.profitReport.value;
    final totalSales = p?.totalSales ?? 0.0;
    final totalCogs = p?.totalCogs ?? 0.0;
    final totalExpenses = p?.totalExpenses ?? 0.0;
    final netProfit = p?.netProfit ?? 0.0;
    final isProfitable = netProfit >= 0;

    return Column(
      children: [
        // Net Profit Hero Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isProfitable
                  ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                  : [const Color(0xFFE53935), const Color(0xFFC62828)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isProfitable ? Colors.green : Colors.red).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'net_profit'.tr,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '${isProfitable ? '+' : ''}\$${netProfit.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isProfitable ? 'profit_good'.tr : 'loss_warning'.tr,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // P&L Breakdown Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pnl_breakdown'.tr,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              _buildRowItem('${'total_revenue'.tr} (+)', '\$${totalSales.toStringAsFixed(2)}', Colors.green[700]!),
              const SizedBox(height: 12),
              _buildRowItem('${'cost_of_goods'.tr} (-)', '-\$${totalCogs.toStringAsFixed(2)}', Colors.orange[800]!),
              const SizedBox(height: 12),
              _buildRowItem('${'total_expense'.tr} (-)', '-\$${totalExpenses.toStringAsFixed(2)}', Colors.red[700]!),
              const Divider(height: 24, thickness: 1.2),
              _buildRowItem(
                '${'net_profit'.tr} =',
                '\$${netProfit.toStringAsFixed(2)}',
                isProfitable ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Sales Report
  Widget _buildSalesReport(ReportController controller) {
    final s = controller.salesReport.value;
    final totalSales = s?.totalSalesAmount ?? 0.0;
    final totalTx = s?.totalTransactions ?? 0;
    final topProducts = s?.topSellingProducts ?? [];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'total_revenue'.tr,
                '\$${totalSales.toStringAsFixed(2)}',
                Icons.attach_money_rounded,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'total_sales_count'.tr,
                '$totalTx ${'transactions_count'.tr}',
                Icons.receipt_long_rounded,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Top Selling Products Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'top_products'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              if (topProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_report_data'.tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                )
              else
                ...topProducts.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('${'sold_qty'.tr} ${item.totalQuantitySold.toInt()} ${'units_sold'.tr}',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                            ],
                          ),
                        ),
                        Text(
                          '\$${item.totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Inventory Report
  Widget _buildInventoryReport(ReportController controller) {
    final inv = controller.inventoryReport.value;
    final stockVal = inv?.totalStockValue ?? 0.0;
    final totalProds = inv?.totalProductsCount ?? 0;
    final lowStock = inv?.lowStockItems ?? [];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'total_stock_value'.tr,
                '\$${stockVal.toStringAsFixed(2)}',
                Icons.inventory_2_outlined,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'total_stock_items'.tr,
                '$totalProds',
                Icons.category_outlined,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('low_stock_warning'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${lowStock.length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),
              if (lowStock.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_report_data'.tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                )
              else
                ...lowStock.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('${'cost_of_goods'.tr}: \$${item.costPrice.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${'remaining_stock'.tr} ${item.currentStock.toInt()}',
                            style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Expense Report
  Widget _buildExpenseReport(ReportController controller) {
    final exp = controller.expenseReport.value;
    final totalExp = exp?.totalExpenses ?? 0.0;
    final byCat = exp?.byCategory ?? [];

    return Column(
      children: [
        _buildMetricCard(
          'total_expense'.tr,
          '\$${totalExp.toStringAsFixed(2)}',
          Icons.trending_down_rounded,
          Colors.red,
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('expense_by_category'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              if (byCat.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_report_data'.tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                )
              else
                ...byCat.map((c) {
                  final pct = totalExp > 0 ? (c.totalAmount / totalExp * 100).toStringAsFixed(1) : '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.categoryName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('\$${c.totalAmount.toStringAsFixed(2)} ($pct%)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE53935))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: totalExp > 0 ? c.totalAmount / totalExp : 0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

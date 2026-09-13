class TopProduct {
  final int? productId;
  final String productName;
  final double totalQuantitySold;
  final double totalRevenue;

  TopProduct({
    this.productId,
    required this.productName,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] as int?,
      productName: json['product_name']?.toString() ?? '',
      totalQuantitySold:
          double.tryParse(json['total_quantity_sold']?.toString() ?? '0') ?? 0.0,
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SalesReportModel {
  final double totalSalesAmount;
  final int totalTransactions;
  final List<TopProduct> topSellingProducts;

  SalesReportModel({
    required this.totalSalesAmount,
    required this.totalTransactions,
    required this.topSellingProducts,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      totalSalesAmount:
          double.tryParse(json['total_sales_amount']?.toString() ?? '0') ?? 0.0,
      totalTransactions: json['total_transactions'] as int? ?? 0,
      topSellingProducts: (json['top_selling_products'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ProfitReportModel {
  final double totalSales;
  final double totalCogs;
  final double totalExpenses;
  final double netProfit;

  ProfitReportModel({
    required this.totalSales,
    required this.totalCogs,
    required this.totalExpenses,
    required this.netProfit,
  });

  factory ProfitReportModel.fromJson(Map<String, dynamic> json) {
    return ProfitReportModel(
      totalSales:
          double.tryParse(json['total_sales']?.toString() ?? '0') ?? 0.0,
      totalCogs:
          double.tryParse(json['total_cogs']?.toString() ?? '0') ?? 0.0,
      totalExpenses:
          double.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0.0,
      netProfit:
          double.tryParse(json['net_profit']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class LowStockProduct {
  final int productId;
  final String productName;
  final double currentStock;
  final double costPrice;

  LowStockProduct({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.costPrice,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name']?.toString() ?? '',
      currentStock:
          double.tryParse(json['current_stock']?.toString() ?? '0') ?? 0.0,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class InventoryReportModel {
  final double totalStockValue;
  final int totalProductsCount;
  final List<LowStockProduct> lowStockItems;

  InventoryReportModel({
    required this.totalStockValue,
    required this.totalProductsCount,
    required this.lowStockItems,
  });

  factory InventoryReportModel.fromJson(Map<String, dynamic> json) {
    return InventoryReportModel(
      totalStockValue:
          double.tryParse(json['total_stock_value']?.toString() ?? '0') ?? 0.0,
      totalProductsCount: json['total_products_count'] as int? ?? 0,
      lowStockItems: (json['low_stock_items'] as List<dynamic>?)
              ?.map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ExpenseCategoryBreakdown {
  final int? categoryId;
  final String categoryName;
  final double totalAmount;

  ExpenseCategoryBreakdown({
    this.categoryId,
    required this.categoryName,
    required this.totalAmount,
  });

  factory ExpenseCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryBreakdown(
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name']?.toString() ?? 'ទូទៅ',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ExpenseReportModel {
  final double totalExpenses;
  final List<ExpenseCategoryBreakdown> byCategory;

  ExpenseReportModel({
    required this.totalExpenses,
    required this.byCategory,
  });

  factory ExpenseReportModel.fromJson(Map<String, dynamic> json) {
    return ExpenseReportModel(
      totalExpenses:
          double.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0.0,
      byCategory: (json['by_category'] as List<dynamic>?)
              ?.map((e) =>
                  ExpenseCategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

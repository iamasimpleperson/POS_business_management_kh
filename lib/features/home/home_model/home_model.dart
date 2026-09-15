import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopModel {
  final String name;
  final String location;
  final String logoUrl;

  ShopModel({required this.name, required this.location, this.logoUrl = ''});

  String get localizedLocation => location.tr;
}

class StatModel {
  final String title;
  final String amount;
  final String percentageText;
  final bool isPositive;
  final IconData icon;
  final Color color;

  StatModel({
    required this.title,
    required this.amount,
    required this.percentageText,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  String get localizedTitle => title.tr;
  String get localizedAmount =>
      amount == 'មិនទាន់មាន' ? 'none_yet'.tr : amount.tr;
  String get localizedPercentageText => percentageText.tr;
}

class QuickActionModel {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;

  QuickActionModel({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  String get localizedTitle => title.tr;
}

class HomeDataModel {
  final ShopModel shop;
  final List<StatModel> stats;
  final int lowStockCount;
  final List<QuickActionModel> quickActions;
  final DashboardResponse? apiDashboard;

  HomeDataModel({
    required this.shop,
    required this.stats,
    required this.lowStockCount,
    required this.quickActions,
    this.apiDashboard,
  });
}

/// Strongly typed Dashboard Response matching GET /api/v1/businesses/{business_id}/dashboard
class DashboardResponse {
  final double todaySales;
  final double todayExpense;
  final double todayProfit;
  final double totalDebt;
  final int debtCustomerCount;
  final int lowStockCount;
  final int newOrdersCount;
  final String? bestSellerName;
  final double bestSellerQty;

  DashboardResponse({
    this.todaySales = 0.0,
    this.todayExpense = 0.0,
    this.todayProfit = 0.0,
    this.totalDebt = 0.0,
    this.debtCustomerCount = 0,
    this.lowStockCount = 0,
    this.newOrdersCount = 0,
    this.bestSellerName,
    this.bestSellerQty = 0.0,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      todaySales: _parseDouble(json['today_sales']),
      todayExpense: _parseDouble(json['today_expense']),
      todayProfit: _parseDouble(json['today_profit']),
      totalDebt: _parseDouble(json['total_debt']),
      debtCustomerCount: _parseInt(json['debt_customer_count']),
      lowStockCount: _parseInt(json['low_stock_count']),
      newOrdersCount: _parseInt(json['new_orders_count']),
      bestSellerName: json['best_seller_name']?.toString(),
      bestSellerQty: _parseDouble(json['best_seller_qty']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_sales': todaySales.toString(),
      'today_expense': todayExpense.toString(),
      'today_profit': todayProfit.toString(),
      'total_debt': totalDebt.toString(),
      'debt_customer_count': debtCustomerCount,
      'low_stock_count': lowStockCount,
      'new_orders_count': newOrdersCount,
      if (bestSellerName != null) 'best_seller_name': bestSellerName,
      'best_seller_qty': bestSellerQty.toString(),
    };
  }
}

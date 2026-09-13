import 'package:flutter/material.dart';

class ProductStatModel {
  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color color;

  ProductStatModel({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class ProductCategoryModel {
  final int? id;
  final String name;
  final Color bgColor;
  final Color textColor;

  ProductCategoryModel({
    this.id,
    required this.name,
    this.bgColor = const Color(0xFFE8F5E9),
    this.textColor = const Color(0xFF2E7D32),
  });
}

class ProductModel {
  final String id;
  final String name;
  final String code;
  final ProductCategoryModel category;
  final int stock;
  final double price;
  final double costPrice;
  final String status;
  final String? unit;
  final String? image;

  ProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.stock,
    required this.price,
    this.costPrice = 0.0,
    required this.status,
    this.unit,
    this.image,
  });
}

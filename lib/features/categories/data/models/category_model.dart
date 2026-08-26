import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  static List<CategoryModel> getCategoriesList() {
    return [
      CategoryModel(id: 'general', title: 'General', icon: Icons.public, color: Colors.blue),
      CategoryModel(id: 'business', title: 'Business', icon: Icons.business_center, color: Colors.amber),
      CategoryModel(id: 'sports', title: 'Sports', icon: Icons.sports_soccer, color: Colors.green),
      CategoryModel(id: 'technology', title: 'Technology', icon: Icons.memory, color: Colors.purple),
      CategoryModel(id: 'entertainment', title: 'Entertainment', icon: Icons.movie, color: Colors.pink),
      CategoryModel(id: 'health', title: 'Health', icon: Icons.favorite, color: Colors.red),
      CategoryModel(id: 'science', title: 'Science', icon: Icons.science, color: Colors.teal),
    ];
  }
}
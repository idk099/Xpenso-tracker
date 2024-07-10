import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xpenso/Models/categorymodel.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';

class CategoryService extends ChangeNotifier {
  static const int categoryLimit = 12;
  final Box<Category> _categoryBox = Hive.box<Category>('categories');

  int? _selectedIcon;

  List<Category> get categories => _categoryBox.values.toList();

  int? get selectedIcon => _selectedIcon;

  void addCategory(String name, BuildContext context) {
    if (_selectedIcon != null) {
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a category name'),
          ),
        );
        return;
      }
    }
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: (name.isEmpty)
              ? Text('Choose icon and enter a category name ')
              : Text('Choose an icon'),
        ),
      );
      return;
    }

    if (_categoryBox.length >= categoryLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Category limit exceeded. You can only add $categoryLimit categories.'),
        ),
      );
      return;
    }

    final category = Category(
        name: name,
        icon: _selectedIcon ?? 0,
        id: DateTime.now().microsecondsSinceEpoch.toString());
    _categoryBox.add(category);
    _selectedIcon = null;
    print(category.id);
    notifyListeners();
  }

  void deletecategory(int index) {
    TransactionServices()
        .deleteTransactionOnCategoryDeletion(_categoryBox.getAt(index)!.name);
    var deletebox = Hive.box('fcatdel');
    
      deletebox.add(_categoryBox.getAt(index)!.id);
    
   
    _categoryBox.deleteAt(index);
    notifyListeners();
    TransactionServices()
        .deleteTransactionOnCategoryDeletion(_categoryBox.getAt(index)!.name);
  }

  void selectIcon(int? icon) {
    _selectedIcon = icon;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:xpenso/Data/list.dart';

import 'package:xpenso/services/Provider/categoryservices.dart';


class CategoryScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  
       

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
            
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 9,
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _categoryField(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _addIcon(context),
              _selectedIcon(),
            ],
          ),
          const SizedBox(height: 60),
           _addCategoryButton(context)
        
        ],
      ),
    ),
    const SizedBox(height: 20),
    const Text(
      'Available Categories:',
      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 10),
    Expanded(
      child: _categoriesList(context),
    ),
  ],
)

        ),
      ),
    );
  }

  Widget _addIcon(BuildContext context) {
     final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: const Text("Add Icon",style: TextStyle(fontSize: 17),),
      avatar: Icon(Icons.add,color: islightmode?Colors.black:Colors.white,),
      
      side: BorderSide.none,
      onPressed: () {
        iconsDialog(context);
      },
    );
  }

  void iconsDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Choose icon'),
              content: SizedBox(
                  height: 200,
                  width: 300,
                  child: SingleChildScrollView(
                      child: Center(child: _categoryIconChoiceChip()))),
              actions: [_addButton(context)],
            ));
  }

  Widget _addButton(BuildContext context) {
    return Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close')));
  }

  Widget _categoryIconChoiceChip() {
    return Consumer<CategoryService>(
      builder: (context, categoryService, _) => Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: icons.map((icon) {
          return ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white)

                // Remove the border
                ),
            showCheckmark: false,
            label: Icon(icon),
            selected: categoryService.selectedIcon == icon.codePoint,
            onSelected: (bool selected) {
              if (selected) {
                categoryService.selectIcon(icon.codePoint);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _selectedIcon() {
    return Consumer<CategoryService>(
        builder: (context, categoryService, child) =>
            categoryService.selectedIcon == null
                ? const Text("No Icon selected")
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Selected Icon  '),
                      Icon(IconData(categoryService.selectedIcon!,
                          fontFamily: 'MaterialIcons')),
                    ],
                  ));
  }

  Widget _addCategoryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final categoryService =
            Provider.of<CategoryService>(context, listen: false);
        categoryService.addCategory(_nameController.text, context);
        _nameController.clear();
        FocusScope.of(context).unfocus();
     
      },
      child: const Text('Add Category'),
    );
  }

  Widget _categoryField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
          labelText: 'Category Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
    );
  }

  Widget _categoriesList(BuildContext context) {
    return Consumer<CategoryService>(
      builder: (context, categoryService, _) {
        final categories = categoryService.categories;
        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories added'),
          );
        }
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.3)),
                child: ListTile(
                  leading: Icon(
                      IconData(category.icon, fontFamily: 'MaterialIcons')),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      final categoryService =
                          Provider.of<CategoryService>(context, listen: false);
                      categoryService.deletecategory(index);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

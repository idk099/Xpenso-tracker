import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();
  late String uid;
  late DocumentReference userRef;


  // Define the categories that should always be displayed
  List<String> predefinedCategories = ['Food', 'Transportation', 'Enter', 'other', 'new', 'kk'];

  // Define icons for specific categories
  Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    // Add more category-icon mappings as needed
  };
  @override
  void initState() {
    super.initState();
     final uid = FirebaseAuth.instance.currentUser?.uid;
    userRef = FirebaseFirestore.instance.collection('User').doc(uid);
   
  }

  Future<void> _addCategory() async {
    String category = _categoryController.text.trim();
    if (category.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('categories').add({
          'category': category,
          // Add more fields if needed
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Category added successfully!'),
        ));
        _categoryController.clear();
         
      } catch (error) {
        print('Error adding category: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add category. Please try again.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a category name.'),
      ));
    }
  }

  Future<void> _deleteCategory(String categoryName) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .where('category', isEqualTo: categoryName)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category deleted successfully!')),
      );
    } catch (error) {
      print('Error deleting category: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding1 = screenWidth * 0.05;
     double screenheight = MediaQuery.of(context).size.height;
    double responsivePadding2 = screenheight * 0.008;
    
    return Scaffold(
      backgroundColor: Colors.blue,
       
       resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(responsivePadding1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
                decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  SizedBox(
                  height: 10,
                ),
                  Padding(
                    padding:  EdgeInsets.all(responsivePadding1),
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),
                  ),
              
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
                ),
                onPressed: _addCategory,
                child: Text('Add Category',style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(
                  height: 20,
                ),
            Text('Available Categories:', style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold)),
            Expanded(
              child:
               
                StreamBuilder(
                stream: userRef.snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
             child: Container(),
            );
          }

                 
                  List<String> firestoreCategories = snapshot.data!.docs.map((doc) => doc['category'] as String).toList();
                  List<String> allCategories = [...predefinedCategories, ...firestoreCategories];

                  return ListView.builder(
                    itemCount: allCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      String categoryName = allCategories[index];
                      IconData? icon = categoryIcons[categoryName];
                      if (icon == null) {
                        // Use default category icon
                        icon = Icons.category;
                      }
                      return Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        height: 50, // Set a fixed height for all containers
                        margin: EdgeInsets.symmetric(vertical: responsivePadding2),
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(icon, color: Colors.black), // Display category icon
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                categoryName,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            if (!predefinedCategories.contains(categoryName))
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(categoryName),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ) ,
            ),
          ],
        ),
      ),
    );
  }
  
}

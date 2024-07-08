import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/Models/budgetmodel.dart';
import 'package:xpenso/Models/categorymodel.dart';
import 'package:xpenso/screens/otherscreens/categoryadd.dart';
import 'package:xpenso/screens/otherscreens/transactionrecord.dart';
import 'package:xpenso/services/Provider/categoryservices.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/widgets/Progressbar.dart';

class BudgetSettingPage extends StatefulWidget {
  @override
  _BudgetSettingPageState createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends State<BudgetSettingPage> {
   
        String formattedDate = DateFormat("MMMM-yyyy").format(DateTime.now() );
  void _showTotalBudgetDialog(TransactionServices transactionServices) {
    final budgetController = TextEditingController(
      text: transactionServices
              .getCurrentMonthBudget()
              ?.totalBudget
              ?.toString() ??
          '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Total Budget'),
          content: TextField(
            controller: budgetController,
            decoration: InputDecoration(
              labelText: 'Enter total budget',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final budget = double.tryParse(budgetController.text);
                if (budget != null) {
                  transactionServices.saveTotalBudget(budget);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please enter a valid number for total budget.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCategoryBudgetDialog(
      TransactionServices transactionServices, Category category) {
    final categoryController = TextEditingController();
    final currentBudget = transactionServices.getCurrentMonthBudget();
    if (currentBudget != null &&
        currentBudget.categoryBudgets.containsKey(category.name)) {
      categoryController.text =
          currentBudget.categoryBudgets[category.name].toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Budget for ${category.name}'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: 'Enter budget',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                transactionServices.deleteCategoryBudget(
                  '${DateTime.now().month}-${DateTime.now().year}',
                  category.name,
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final budget = double.tryParse(categoryController.text);
                if (budget != null) {
                  transactionServices.saveCategoryBudget(
                    '${DateTime.now().month}-${DateTime.now().year}',
                    category.name,
                    budget,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please enter a valid number for category budget.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesBox = Hive.box<Category>('categories');
    final transactionServices = Provider.of<TransactionServices>(context);
    final theme = Theme.of(context);

    final currentBudget = transactionServices.getCurrentMonthBudget();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionRecord(),
            )),
      ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(
                 child: Text(
                    formattedDate,
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
               ),
               SizedBox(
                height: 8,
               ),
             
              totalBudgetCard(),
              SizedBox(height: 16),
              
              Text("Categorywise Budget",style: TextStyle(color: Colors.white,fontSize: 17),),
              SizedBox(height: 10,),
             Expanded(child:_categoryBudgetList())
          
          
        
              
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryWiseBudgetButton() {
    return TextButton(
        onPressed:_showCategoryBudgetBottomSheet, child: Text("Set C"));
  }

  Widget totalBudgetCard() {
    return Consumer<TransactionServices>(
      builder: (context, budgetServices, child) {
       
       
        Budget? currentMonthTotalBudget =
            budgetServices.getCurrentMonthBudget();
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
               Center(child:   Column(
                    children: [
                      SizedBox(height: 20,),
                      Text(
                            'Total Budget',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                         
                         SizedBox(height: 10,),
                           
                              Text(
  currentMonthTotalBudget?.totalBudget != null 
      ? '₹ ${currentMonthTotalBudget!.totalBudget.toString()}' 
      : 'Not set',
  style: TextStyle(fontSize: 21),
),

                                                    
                          
                    ],
                  ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  
                   
                    Row(
                      children: [
                         IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showTotalBudgetDialog(budgetServices),
                      ),
                        
                        (currentMonthTotalBudget?.totalBudget != null)
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  budgetServices.deleteTotalBudget();
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
          ],
            ),
          ),
        );
      },
    );
  }

 void _showCategoryBudgetBottomSheet() {
  final halfScreenHeight = MediaQuery.of(context).size.height * 0.83;
  final islightmode = Theme.of(context).brightness == Brightness.light;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Consumer<CategoryService>(
            builder: (context, categoryService, child) {
          if (categoryService.categories.isEmpty) {
            return SizedBox(
              height: 200,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("No Categories Available"),
                  SizedBox(height: 20),
                  Center(
                    child: _addCategoryChip(context),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<TransactionServices>(
                builder: (context, budgetService, child) {
              final currentBudget = budgetService.getCurrentMonthBudget();
              return SizedBox(
                height: halfScreenHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Category wise Budget",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      _addCategoryChip(context),
                      SizedBox(height: 20,),
                      Expanded(
                        child: ListView(
                          children: categoryService.categories.map((category) {
                            return Card(
                              color: Colors.blueGrey,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      side: BorderSide.none,
                                      label: Text(
                                        category.name,
                                      ),
                                      avatar: Icon(
                                        IconData(category.icon, fontFamily: 'MaterialIcons'),
                                        color: islightmode ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          currentBudget
                                                  ?.categoryBudgets[category.id]
                                                  ?.toString() ??
                                              'Not set',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(width: 16),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              _showCategoryBudgetDialog(budgetService, category),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: Colors.white,
                                          onPressed: () {
                                            budgetService.deleteCategoryBudget(
                                              '${DateTime.now().month}-${DateTime.now().year}',
                                              category.id,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }
        });
      });
    },
  );
}


  Widget _addCategoryChip(BuildContext context) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: Text("Add category", style: TextStyle(fontSize: 17)),
      avatar: Icon(
        Icons.add,
        color: islightmode ? Colors.black : Colors.white,
      ),
      side: BorderSide.none,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(),
            ));
      },
    );
  }


  Widget _categoryBudgetList()
  {
       final islightmode = Theme.of(context).brightness == Brightness.light;
       return Consumer<CategoryService>(
            builder: (context, categoryService, child) {
          if (categoryService.categories.isEmpty) {
            return SizedBox(
              height: 200,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("No Categories Available"),
                  SizedBox(height: 20),
                  Center(
                    child: _addCategoryChip(context),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<TransactionServices>(
                builder: (context, budgetService, child) {
              final currentBudget = budgetService.getCurrentMonthBudget();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Expanded(
                      child: ListView(
                        children: categoryService.categories.map((category) {
                          return Card(
                            color:islightmode ? Colors.blue.withOpacity(0.7) : Colors.white.withOpacity(0.1),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    side: BorderSide.none,
                                    label: Text(
                                      category.name,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    avatar: Icon(
                                      IconData(category.icon, fontFamily: 'MaterialIcons'),
                                      color: islightmode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        currentBudget
                                                ?.categoryBudgets[category.name]
                                                ?.toString() ??
                                            'Not set',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(width: 16),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _showCategoryBudgetDialog(budgetService, category),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.white,
                                        onPressed: () {
                                          budgetService.deleteCategoryBudget(
                                            '${DateTime.now().month}-${DateTime.now().year}',
                                            category.name,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            });
          }
        });










  }







}

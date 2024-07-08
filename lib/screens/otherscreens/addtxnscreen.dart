import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/screens/otherscreens/categoryadd.dart';
import 'package:xpenso/screens/otherscreens/txnAnalysis.dart';
import 'package:xpenso/services/Provider/categoryservices.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';

class AddPage extends StatefulWidget {
  AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _amountcontroller = TextEditingController();

 
  List<String> _types = ['Expense', 'Income'];
  String _selectedAccount = "Cash";
  String? _selectedCategory;
  String _selectedType = 'Expense';
  int? _categoryIcon;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    resizeToAvoidBottomInset: true,
      appBar: AppBar(
         automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Add Transaction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30),
        ),
      ),
      floatingActionButton: Container(width: 200, child: _addButton(context)),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              child: SizedBox(
                height: 540,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      _categoryField(),
                      const SizedBox(
                        height: 20,
                      ),
                      _chooseCategoryActionChip(context),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Choose an Account",style: TextStyle(fontSize: 17)
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _accountChoiceChip(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          _dateDisplay(context),
                          SizedBox(width: 11.0),
                          _dateChangeButton(context),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Choose type",style: TextStyle(fontSize: 17)
                      ),
                      SizedBox(height: 10.0),
                      _transactionTypeChip(),
                     
                    ],
                  ),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _categoryField() {
    return TextField(
      keyboardType: TextInputType.number,
      controller: _amountcontroller,
      decoration: InputDecoration(hintText: "Enter amount", filled: true),
    );
  }

  Widget _categoryChoiceChip() {
    return Consumer<CategoryService>(
      builder: (context, categoryService, _) {
        final categories = categoryService.categories;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((category) {
            return ChoiceChip(
              showCheckmark: false,
              avatar:
                  Icon(IconData(category.icon, fontFamily: 'MaterialIcons')),
              side: BorderSide.none,
              label: Text(category.name,style: TextStyle(fontSize: 17)),
              selected: _selectedCategory == category.name,
              onSelected: (value) {
                setState(() {
                  _selectedCategory = category.name;
                  _categoryIcon = category.icon;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _accountChoiceChip() {
    return Consumer<TransactionServices>(
      builder: (context, accountService, child) {
        return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: accountService.accounts.map(
              (account) {
                return ChoiceChip(
                  side: BorderSide.none,
                  label: Text(account.name,style: TextStyle(fontSize: 17)),
                  selected: _selectedAccount == account.name,
                  onSelected: (value) {
                    setState(() {
                      _selectedAccount = account.name;
                    });
                  },
                );
              },
            ).toList());
      }
    );
  }

  Widget _addCategoryChip(BuildContext context) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: Text(
        "Add category",style: TextStyle(fontSize: 17)
      ),
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

  Widget _chooseCategoryActionChip(BuildContext context) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: _selectedCategory != null
          ? Text(_selectedCategory!,style: TextStyle(fontSize: 17))
          : Text(
              "Select a Category",style: TextStyle(fontSize: 17)
            ),
      avatar: _selectedCategory != null
          ? Icon(
              IconData(
                _categoryIcon!,
                fontFamily: 'MaterialIcons',
              ),
              color: islightmode ? Colors.black : Colors.white,
            )
          : Icon(
              Icons.add,
              color: islightmode ? Colors.black : Colors.white,
            ),
      side: BorderSide.none,
      onPressed: () {
        _categoryBottomSheet(context);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _transactionTypeChip() {
    return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _types.map(
          (type) {
            return ChoiceChip(
              side: BorderSide.none,
              label: Text(type,style: TextStyle(fontSize: 17)),
              selected: _selectedType == type,
              onSelected: (value) {
                setState(() {
                  _selectedType = type;
                });
              },
            );
          },
        ).toList());
  }

  Widget _dateDisplay(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
        ),
        SizedBox(width: 10.0),
        Text(
          'Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  void _categoryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                
                  Spacer(),
               
                  Text("               Choose a Category",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                  
                  Spacer(),
                  // Close button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [_addCategoryChip(context), _categoryChoiceChip()],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _dateChangeButton(BuildContext context) {
    return TextButton(
      onPressed: () => _selectDate(context),
      child: Text(
        'Change Date',
        style: TextStyle(color: Colors.black,fontSize: 17),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor:Theme.of(context).brightness == Brightness.light
                ? Color.fromARGB(255, 236, 236, 89)
                :null, 
      onPressed: () {
        double? amount = double.tryParse(_amountcontroller.text);
        if (_selectedCategory != null) {
          if (amount == null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Enter a valid amount')));
            return;
          }
        }

        if (_selectedCategory == null) {
          amount == null
              ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Enter a valid amount, choose a category ')))
              : ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(' choose a category ')));
          return;
        }

        final expense =
            Provider.of<TransactionServices>(context, listen: false);
        expense.addTransaction(
            context: context,
            amount: amount ?? 0.0,
            date: _selectedDate,
            category: _selectedCategory ?? "N/A",
            account: _selectedAccount,
            txnType: _selectedType);
       Navigator.pop(context);
      },
      child: Text(
        'Add',
        style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }
}

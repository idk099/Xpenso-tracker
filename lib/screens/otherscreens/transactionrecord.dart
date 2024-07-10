import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/Models/transactionmodel.dart';
import 'package:xpenso/screens/otherscreens/categoryadd.dart';
import 'package:xpenso/screens/otherscreens/addtxnscreen.dart';
import 'package:xpenso/services/Provider/categoryservices.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/Models/transactionmodel.dart';

class TransactionRecord extends StatefulWidget {
  const TransactionRecord({super.key});

  @override
  State<TransactionRecord> createState() => _TransactionRecordState();
}

class _TransactionRecordState extends State<TransactionRecord>
    with AutomaticKeepAliveClientMixin<TransactionRecord> {
  DateTime _currentDate = DateTime.now();
  String _viewType = 'Monthly';
  String _transactionTypeFilter = 'All';
  String? _selectedCategory;

  List<String> _types = ['Expense', 'Income'];
  String? _selectedAccount;

  String? _selectedType;
  DateTime? _selectedDate;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Records',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildMonthYearHeader(),
                  _buildHeader(),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: _transactionlist(),
            )),
          ],
        ),
      ),
      
    );
  }

  Widget _transactionlist() {
    return Consumer<TransactionServices>(
      builder: (context, transactionServices, child) {
        final transactions = transactionServices.getFilteredTransactions(
            currentDate: _currentDate,
            transactionTypeFilter: _transactionTypeFilter,
            viewType: _viewType);
        return _buildExpenseList(transactions);
      },
    );
  }

  void _incrementDate() {
    setState(() {
      switch (_viewType) {
        case 'Daily':
          _currentDate = _currentDate.add(Duration(days: 1));
          break;
        case 'Weekly':
          _currentDate = _currentDate.add(Duration(days: 7));
          break;
        case 'Monthly':
          _currentDate = DateTime(
              _currentDate.year, _currentDate.month + 1, _currentDate.day);
          break;
        case 'Yearly':
          _currentDate = DateTime(
              _currentDate.year + 1, _currentDate.month, _currentDate.day);
          break;
      }
    });
  }

  void _decrementDate() {
    setState(() {
      switch (_viewType) {
        case 'Daily':
          _currentDate = _currentDate.subtract(Duration(days: 1));
          break;
        case 'Weekly':
          _currentDate = _currentDate.subtract(Duration(days: 7));
          break;
        case 'Monthly':
          _currentDate = DateTime(
              _currentDate.year, _currentDate.month - 1, _currentDate.day);
          break;
        case 'Yearly':
          _currentDate = DateTime(
              _currentDate.year - 1, _currentDate.month, _currentDate.day);
          break;
      }
    });
  }

  void _updateDateFilter(String viewType) {
    setState(() {
      _viewType = viewType;
      _currentDate =
          DateTime.now(); // Reset to current date on view type change
    });
  }

  void _updateTransactionTypeFilter(String type) {
    setState(() {
      _transactionTypeFilter = type;
    });
  }

  String _formatDate() {
    switch (_viewType) {
      case 'Daily':
        return DateFormat.yMMMMd().format(_currentDate);
      case 'Weekly':
        final startOfWeek =
            _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return "${DateFormat.yMMMMd().format(startOfWeek)} - ${DateFormat.yMMMMd().format(endOfWeek)}";
      case 'Monthly':
        return DateFormat.yMMMM().format(_currentDate);
      case 'Yearly':
        return DateFormat.y().format(_currentDate);
      default:
        return DateFormat.yMMMM().format(_currentDate);
    }
  }

  Widget _buildHeader() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final transactions = Provider.of<TransactionServices>(context, listen: true)
        .getFilteredTransactions(
            currentDate: _currentDate,
            transactionTypeFilter: "All",
            viewType: _viewType);

    for (var transaction in transactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPENSES',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text('₹${totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INCOME',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text('₹${totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                  )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAVINGS',
                  style: TextStyle(
                      color: totalIncome - totalExpense >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text('₹${(totalIncome - totalExpense).toStringAsFixed(2)}',
                  style: TextStyle(
                      color: totalIncome - totalExpense >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(Transaction transaction) {
    TextEditingController amountController =
        TextEditingController(text: transaction.amount.toString());

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Provider.of<TransactionServices>(context, listen: false)
                            .updateTransaction(transaction, context, "Delete",
                                transaction.account);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: "Amount"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Category",
                style: TextStyle(fontSize: 17),
              ),
              _addCategoryChip(context),
              _categoryChoiceChip(),
              SizedBox(
                height: 10,
              ),
              _dateDisplay(context),
              SizedBox(
                height: 10,
              ),
              Text(
                "Account",
                style: TextStyle(fontSize: 17),
              ),
              _accountChoiceChip(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Transaction Type",
                style: TextStyle(fontSize: 17),
              ),
              _transactionTypeChip(),
              SizedBox(
                height: 20,
              ),
              _addButton(context, amountController, transaction),
              SizedBox(
                height: 50,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _addButton(BuildContext context,
      TextEditingController amountController, Transaction txn) {
    return ElevatedButton(
      onPressed: () {
        if (amountController.text.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Enter a valid amount')));
          return;
        }
        Transaction editedTransaction = Transaction(
            id: txn.id,
            category: _selectedCategory!,
            amount: double.parse(amountController.text),
            date: _selectedDate!,
            account: _selectedAccount!,
            type: _selectedType!);

        Provider.of<TransactionServices>(context, listen: false)
            .updateTransaction(editedTransaction, context, "Edit", txn.account);
        Navigator.pop(context);
      },
      child: Text(
        "Add",
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  Widget _transactionTypeChip() {
    return StatefulBuilder(builder: (context, setState) {
      return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _types.map(
            (type) {
              return ChoiceChip(
                side: BorderSide.none,
                label: Text(
                  type,
                  style: TextStyle(fontSize: 17),
                ),
                selected: _selectedType == type,
                onSelected: (value) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              );
            },
          ).toList());
    });
  }

  Widget _accountChoiceChip() {
    return StatefulBuilder(builder: (context, setState) {
      return Consumer<TransactionServices>(
          builder: (context, accounService, child) {
        return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: accounService.accounts.map(
              (account) {
                return ChoiceChip(
                  side: BorderSide.none,
                  label: Text(
                    account.name,
                    style: TextStyle(fontSize: 17),
                  ),
                  selected: _selectedAccount == account.name,
                  onSelected: (value) {
                    setState(() {
                      _selectedAccount = account.name;
                    });
                  },
                );
              },
            ).toList());
      });
    });
  }

  Widget _dateDisplay(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        child: StatefulBuilder(builder: (context, setState) {
          return Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.calendar_today,
              ),
              SizedBox(width: 10.0),
              Text(
                'Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          );
        }),
      ),
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

  Widget _categoryChoiceChip() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Consumer<CategoryService>(
          builder: (context, categoryService, _) {
            final categories = categoryService.categories;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                return ChoiceChip(
                  showCheckmark: false,
                  avatar: Icon(
                      IconData(category.icon, fontFamily: 'MaterialIcons')),
                  side: BorderSide.none,
                  label: Text(
                    category.name,
                    style: TextStyle(fontSize: 17),
                  ),
                  selected: _selectedCategory == category.name,
                  onSelected: (value) {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _addCategoryChip(BuildContext context) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: Text(
        "Add category",
        style: TextStyle(fontSize: 17),
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

  Widget _buildExpenseList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Card(child: Center(child: Text('No transactions found.')));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = transaction.category;
              _selectedDate = transaction.date;
              _selectedType = transaction.type;
              _selectedAccount = transaction.account;
            });
            _showUpdateDialog(transaction);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.2),
              ),
              child: ListTile(
                leading: Icon(
                  transaction.type == 'Expense'
                      ? Icons.remove_circle
                      : Icons.add_circle,
                  color:
                      transaction.type == 'Expense' ? Colors.red : Colors.green,
                ),
                title: Text(
                  transaction.category,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                subtitle: Text(
                  '${DateFormat.yMMMMd().format(transaction.date)}\n${transaction.account}',
                  style: TextStyle(fontSize: 20),
                ),
                isThreeLine: true,
                trailing: Text(
                  transaction.type == 'Expense'
                      ? '-₹${transaction.amount.toStringAsFixed(2)}'
                      : '+₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 20,
                      color: transaction.type == 'Expense'
                          ? Colors.red
                          : Colors.green),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthYearHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                ),
                onPressed: _decrementDate,
              ),
              Text(_formatDate(), style: TextStyle(fontSize: 20)),
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.filter_alt),
                    onSelected: _updateTransactionTypeFilter,
                    itemBuilder: (BuildContext context) {
                      return ['All', 'Income', 'Expense'].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: _incrementDate,
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.filter_list),
          onSelected: _updateDateFilter,
          itemBuilder: (BuildContext context) {
            return ['Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

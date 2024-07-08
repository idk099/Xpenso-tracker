import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:xpenso/Models/accountmodel.dart';
import 'package:xpenso/Models/transactionmodel.dart';
import 'package:xpenso/screens/otherscreens/categoryadd.dart';
import 'package:xpenso/screens/otherscreens/addtxnscreen.dart';
import 'package:xpenso/Data/list.dart';
import 'package:xpenso/services/Provider/categoryservices.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';

class TxnAccount extends StatefulWidget {
  const TxnAccount({super.key});

  @override
  State<TxnAccount> createState() => _TxnAccountState();
}

class _TxnAccountState extends State<TxnAccount>
    with AutomaticKeepAliveClientMixin<TxnAccount> {
  DateTime _currentDate = DateTime.now();
  String _viewType = 'Monthly';
  String _transactionTypeFilter = 'All';
  PageController _pageController = PageController();

  int? _selectedIcon;

  String? _pageName;

  List<String> _accounts = ['Cash', 'Bank'];
  List<String> _types = ['Expense', 'Income'];
  String? _selectedAccount;
  String? _selectedType;
  DateTime? _selectedDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _pageName = TransactionServices().getAccountName(0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Accounts",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showBottomSheet();
              },
              icon: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ))
        ],
      ),
    
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 260,
              child: _accountCard(),
            ),
            _pageIndicator(),
            SizedBox(
              height: 5,
            ),
            _headers(),
            SizedBox(
              height: 10,
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

  Widget _headers() {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            _buildMonthYearHeader(),
          ],
        ));
  }

  void _showBottomSheet({Accounts? account}) {
    TextEditingController acController = TextEditingController(text: "");
    TextEditingController initBalController = TextEditingController(text: "");

    if (account != null) {
      acController.text = account.name.toString();
      initBalController.text = account.initbal.toString();
    } else {
      _selectedIcon = null;
    }

    final halfScreenHeight = MediaQuery.of(context).size.height * 0.83;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            height: halfScreenHeight,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    account != null && _pageName != "Cash"
                        ? Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Provider.of<TransactionServices>(context,
                                            listen: false)
                                        .updateAccount(
                                            account, context, "Delete");
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          )
                        : SizedBox(
                            height: 20,
                          ),
                    Center(
                        child: account == null
                            ? Text(
                                "Add Account",
                                style: TextStyle(fontSize: 22),
                              )
                            : Text("Edit Account",
                                style: TextStyle(fontSize: 22))),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: acController,
                      decoration: InputDecoration(labelText: "Account Name"),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: initBalController,
                      decoration: InputDecoration(labelText: "Initial Balance"),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        _addIcon(context, setState),
                        SizedBox(
                          width: 15,
                        ),
                        _selectedIconDisplay(setState),
                      ],
                    ),
                    account != null
                        ? Center(
                            child: _acButton(
                                ac: account,
                                acname: acController,
                                initbal: initBalController),
                          )
                        : Center(
                            child: _acButton(
                                acname: acController,
                                initbal: initBalController),
                          )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _acButton(
      {Accounts? ac,
      required TextEditingController acname,
      required TextEditingController initbal}) {
    return ElevatedButton(
        onPressed: () {
          if (acname.text.isEmpty) return;
          if (initbal.text.isEmpty) return;
          if (_selectedIcon == null) return;
          double? initibal = double.tryParse(initbal.text);
          if (initibal == null) return;
          if (ac != null) {
            Accounts editedac = Accounts(
                id: ac.id,
                name: acname.text,
                icon: _selectedIcon!,
                bal: ac.bal,
                initbal: initibal);
            setState(() {
              _pageName = acname.text;
            });

            Provider.of<TransactionServices>(context, listen: false)
                .updateAccount(editedac, context, "Edit");
          } else {
            Provider.of<TransactionServices>(context, listen: false).addAccount(
                name: acname.text,
                initbal: initibal,
                icon: _selectedIcon!,
                bal: initibal);
            _selectedIcon = null;
          }

          Navigator.pop(context);
        },
        child: Text(
          'Submit',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ));
  }

  Widget _selectedIconDisplay(StateSetter setState) {
    return _selectedIcon == null
        ? const Text("No Icon selected")
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selected Icon  ',
                  style: TextStyle(
                    fontSize: 17,
                  )),
              Icon(IconData(_selectedIcon!, fontFamily: 'MaterialIcons')),
            ],
          );
  }

  void _iconsDialog(BuildContext context, StateSetter bottomSheetSetState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose icon'),
        content: SizedBox(
          height: 200,
          width: 300,
          child: SingleChildScrollView(
            child: Center(child: _accountIconChoiceChip(bottomSheetSetState)),
          ),
        ),
        actions: [],
      ),
    );
  }

  Widget _accountIconChoiceChip(StateSetter bottomSheetSetState) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: icons.map((icon) {
        return ChoiceChip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white),
          ),
          showCheckmark: false,
          label: Icon(icon),
          selected: _selectedIcon == icon.codePoint,
          onSelected: (bool selected) {
            if (selected) {
              bottomSheetSetState(() {
                _selectedIcon = icon.codePoint;
              });
              Navigator.of(context).pop();
            }
          },
        );
      }).toList(),
    );
  }

  Widget _addIcon(BuildContext context, StateSetter bottomSheetSetState) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    return ActionChip(
      label: _selectedIcon == null
          ? Text("Choose icon", style: TextStyle(fontSize: 15))
          : Text(
              "Change icon",
              style: TextStyle(fontSize: 15),
            ),
      avatar: Icon(Icons.add, color: islightmode ? Colors.black : Colors.white),
      side: BorderSide.none,
      onPressed: () {
        _iconsDialog(context, bottomSheetSetState);
      },
    );
  }

  Widget _pageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SmoothPageIndicator(
        effect: WormEffect(
            dotColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.white,
            activeDotColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.red),
        controller: _pageController,
        count: Provider.of<TransactionServices>(context, listen: false)
            .accounts
            .length,
      ),
    );
  }

  Widget _accountCard() {
    return Consumer<TransactionServices>(
      builder: (context, accountService, child) {
        final accounts = accountService.accounts;
        print("Number of accounts: ${accounts.length}");
        return PageView.builder(
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _pageName = accountService.getAccountName(value);
            });
          },
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return GestureDetector(
              onTap: () {
                _showBottomSheet(account: account);
                setState(() {
                  _selectedIcon = account.icon;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconData(account.icon, fontFamily: 'MaterialIcons'),
                            size: 40,
                          ),
                          Text(
                            account.name,
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _buildHeader(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Total balance : ₹${account.bal}",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }
//

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

  Widget _buildMonthYearHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
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
      ),
    );
  }

  Widget _buildHeader() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final transactions = Provider.of<TransactionServices>(context, listen: true)
        .getFilteredTransactions(
            currentDate: _currentDate,
            transactionTypeFilter: "All",
            viewType: _viewType,
            acType: _pageName);

    for (var transaction in transactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPENSE',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.red
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₹${totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.red
                        : Colors.white,
                  )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INCOME',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.green
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₹${totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.green
                        : Colors.white,
                    fontSize: 24,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionlist() {
    return Consumer<TransactionServices>(
      builder: (context, transactionServices, child) {
        final transactions = transactionServices.getFilteredTransactions(
            currentDate: _currentDate,
            transactionTypeFilter: _transactionTypeFilter,
            viewType: _viewType,
            acType: _pageName);
        return _buildExpenseList(transactions);
      },
    );
  }

  Widget _buildExpenseList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
          child: Text(
        'No transactions found.',
        style: TextStyle(fontSize: 17),
      ));
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
                borderRadius: BorderRadius.circular(15),
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
              Text("Category", style: TextStyle(fontSize: 17)),
              _addCategoryChip(context),
              _categoryChoiceChip(),
              SizedBox(
                height: 10,
              ),
              _dateDisplay(context),
              SizedBox(
                height: 10,
              ),
              Text("Account", style: TextStyle(fontSize: 17)),
              _accountChoiceChip(),
              SizedBox(
                height: 20,
              ),
              Text("Transaction Type", style: TextStyle(fontSize: 17)),
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
      child: Text("Add", style: TextStyle(fontSize: 17)),
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
                label: Text(type, style: TextStyle(fontSize: 17)),
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
          builder: (context, accountService, child) {
        return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: accountService.accounts.map(
              (account) {
                return ChoiceChip(
                  side: BorderSide.none,
                  label: Text(account.name, style: TextStyle(fontSize: 17)),
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
                  label: Text(category.name, style: TextStyle(fontSize: 17)),
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
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

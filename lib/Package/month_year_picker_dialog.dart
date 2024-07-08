import 'package:flutter/material.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color selectedColor;
  final Color unselectedColor;

  const MonthYearPickerDialog({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
  }) : super(key: key);

  @override
  _MonthYearPickerDialogState createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
     
    return Dialog(
      child: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Choose Month and Year',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildMonthPicker(),
              SizedBox(height: 16),
              _buildCustomYearPicker(),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(DateTime(selectedYear, selectedMonth));
                },
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomYearPicker() {
    List<int> years = List<int>.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.lastDate.year - index,
    );

    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: years.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedYear = years[index];
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedYear == years[index] ? widget.selectedColor : widget.unselectedColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                '${years[index]}',
                style: TextStyle(
                  color: selectedYear == years[index] ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthPicker() {
    return DropdownButton<String>(
      dropdownColor: Theme.of(context).brightness == Brightness.light?Colors.white:Colors.grey.shade800,
      focusColor: Colors.transparent,
      value: monthNames[selectedMonth - 1],
      items: monthNames.map((String monthName) {
        return DropdownMenuItem<String>(
          value: monthName,
          child: Text(monthName),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          selectedMonth = monthNames.indexOf(value!) + 1;
        });
      },
    );
  }
}

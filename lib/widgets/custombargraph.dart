import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xpenso/Data/list.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';



class Bargraph extends StatefulWidget {
  const Bargraph({super.key});

  @override
  State<Bargraph> createState() => _BargraphState();
}

class _BargraphState extends State<Bargraph> {
   final List<String> _filter = ['Day', 'Month', 'Year'];
   String _filterby = "Day";

  DateTime _selectedDate = DateTime.now();
  String _selectedMonth = DateFormat("MMMM").format(DateTime.now());
  String _selectedYear = DateFormat("yyyy").format(DateTime.now());


  @override
  Widget build(BuildContext context) {
     

    return Container(
       
  
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
         
          Card(
            elevation: 2,
            child: Column(
             
              children: [
                SizedBox(height: 40,),
                 filterChoices(),
                SizedBox(
                  height: 20,
                ),
                
               _filterWidgets(context),
               doublebar(context)
            
            
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChoices() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        children: _filter
            .map(
              (filter) => ChoiceChip(
                label: Text(filter),
                selected: _filterby == filter,
                onSelected: (value) {
                   if(_filterby!=filter)
                  setState(() {
                  
                    _selectedMonth = DateFormat("MMMM").format(DateTime.now());
                    _selectedYear = DateFormat("yyyy").format(DateTime.now());
                  
                    
                  });
                  setState(() {
                    _filterby = filter;
                    
                  });
                 
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget doublebar(BuildContext context) {
    final bargraphdata = Provider.of<TransactionServices>(context, listen: true);

    return SfCartesianChart(
      legend: Legend(isVisible: true),

       primaryXAxis: CategoryAxis(
         majorGridLines: MajorGridLines(width: 0),
            title: AxisTitle(
              text:  _filterby =='Day'
      ? "Days"
      :   _filterby =='Month' 
          ? "Months"
          : "Year",
              textStyle: TextStyle(
              
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          primaryYAxis: NumericAxis(
             majorGridLines: MajorGridLines(width: 0),
            title: AxisTitle(
              text: 'Total amount(in rupees)',
              textStyle: TextStyle(
             
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
         labelRotation: 90, ),
      series: <CartesianSeries>[
        ColumnSeries<BarGraphData, String>(
          
          
          dataSource: bargraphdata.fetchBarGraphData(filterby: _filterby, month: _selectedMonth, year: _selectedYear,txnType: "Expense"),
              
          xValueMapper: (BarGraphData data, _) => data.x,
          yValueMapper: (BarGraphData data, _) => data.y,
          name: 'Expense',
          color: Colors.blue,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BarGraphData, String>(
          dataSource: bargraphdata.fetchBarGraphData(filterby: _filterby, month: _selectedMonth, year: _selectedYear,txnType: "Income"),
              
          xValueMapper: (BarGraphData data, _) => data.x,
          yValueMapper: (BarGraphData data, _) => data.y,
          name: 'Income',
          color: Colors.green,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
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

  Widget _yearDisplay(BuildContext context) {
    return 
        Text(
          'Year:  $_selectedYear',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        );
        
  }

  Widget _yearSelectButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("hi");
        _yearDialog(context);
        print("hello");
      },
      child: Text(
        'Change Year',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

   void _yearDialog(BuildContext context) {
  DateTime now = DateTime.now();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Choose an Year"),
      content: SizedBox(
        height: 300,
        width: 300,
        child: Builder(
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(
                // Customize the YearPicker selection color
                colorScheme: Theme.of(context).brightness==Brightness.light?const ColorScheme.light():const ColorScheme.dark(),
              ),
              child: YearPicker(
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year),
                selectedDate: _selectedDate,
                onChanged: (value) {
                  setState(() {
                    _selectedDate = value;
                    _selectedYear = DateFormat('yyyy').format(_selectedDate);
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}

 
  Widget _filterWidgets(BuildContext context) {
    if (_filterby == 'Day') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<String>(
            hint: Text('Select Month'),
            value: _selectedMonth,
            autofocus: false,
            focusColor: Colors.transparent,
            dropdownColor: Theme.of(context).brightness == Brightness.light?Colors.white:Colors.grey.shade800,
            onChanged: (String? newValue) {
              setState(() {
                _selectedMonth = newValue!;
              });
            },
            items: months.map((String month) {
              return DropdownMenuItem<String>(
                
                value: month,
                child: Text(month),
              );
            }).toList(),
          ),
          SizedBox(width: 20),
          DropdownButton<String>(
             focusColor: Colors.transparent,
            dropdownColor: Theme.of(context).brightness == Brightness.light?Colors.white:Colors.grey.shade800,
            hint: Text('Select Year'),
            value: _selectedYear,
            onChanged: (String? newValue) {
              setState(() {
                _selectedYear = newValue!;
              });
            },
            items: years.map((String year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              );
            }).toList(),
          ),
        ],
      );
    } else if (_filterby == 'Month') {
      print(_filterby);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _yearDisplay(context),
          _yearSelectButton(context),
        ],
      );
    }
    return Container();
  }
}

class BarGraphData {
  String x;
  double y;

  BarGraphData({required this.x, required this.y});
}

class ChartData {
  ChartData(this.month, this.sales1, this.sales2);
  final String month;
  final double sales1;
  final double sales2;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xpenso/Package/show_month_year_picker.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';

class PieChart extends StatefulWidget {
  const PieChart({super.key, required this.txnType});

  final String txnType;

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  final List<String> _filter = ['Day', 'Month', 'Year'];
  DateTime _selectedDate = DateTime.now();
  String _filterby = "Day";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final islightmode = Theme.of(context).brightness == Brightness.light;
    final pieChartData =
        Provider.of<TransactionServices>(context, listen: true);
    final data = pieChartData.fetchPieChartData(
        _selectedDate, _filterby, widget.txnType);
    return Card(
      child: data.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No data",
                  style: TextStyle(
                    color: islightmode ? Colors.black : null,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                filterChoices(),
                SizedBox(
                  height: 20,
                ),
                _filterWidgets(context),
                SizedBox(
                  height: 60,
                ),
              _pieChart()],
            ),
    );
  }

  Widget filterChoices() {
    return Wrap(
      spacing: 10,
      children: _filter
          .map(
            (filter) => ChoiceChip(
              label: Text(filter),
              selected: _filterby == filter,
              onSelected: (value) {
                if (_filterby != filter)
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                setState(() {
                  _filterby = filter;
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _dateDisplay(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
        ),
        SizedBox(width: 10.0),
        Text(
          'Day:  ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _datePickerButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showDatePicker(context),
      child: Text(
        'Change',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _monthYearPickerButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showMonthYearPicker(context),
      child: Text(
        'Change',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
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

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final DateTime? pickedDate = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      print(_selectedDate);
    }
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
                  colorScheme: Theme.of(context).brightness == Brightness.light
                      ? const ColorScheme.light()
                      : const ColorScheme.dark(),
                ),
                child: YearPicker(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(now.year),
                  selectedDate: _selectedDate,
                  onChanged: (value) {
                    setState(() {
                      _selectedDate = value;
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
        children: [_dateDisplay(context), _datePickerButton(context)],
      );
    } else if (_filterby == 'Month') {
      print(_filterby);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_monthDisplay(context), _monthYearPickerButton(context)],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _yearDisplay(context),
          _yearSelectButton(context),
        ],
      );
    }
  }

  Widget _yearSelectButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("hi");
        _yearDialog(context);
        print("hello");
      },
      child: Text(
        'Change',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _monthDisplay(BuildContext context) {
    return Text(
      'Month:  ${DateFormat("MMMM-yyyy").format(_selectedDate)}',
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _yearDisplay(BuildContext context) {
    return Text(
      'Year:  ${DateFormat("yyyy").format(_selectedDate)}',
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _pieChart() {
    final pieChartData =
        Provider.of<TransactionServices>(context, listen: true);
    return SfCircularChart(
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<PieChartData, String>(
          dataSource: pieChartData.fetchPieChartData(
              _selectedDate, _filterby, widget.txnType),
          xValueMapper: (PieChartData data, _) => data.x,
          yValueMapper: (PieChartData data, _) => data.y,
          dataLabelSettings: DataLabelSettings(
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Text(
                'Rs ${point.y.toString()}',
                style: TextStyle(
                  color: Theme.of(context).brightness==Brightness.light ? Colors.black : null,
                ),
              );
            },
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(
                color: Theme.of(context).brightness==Brightness.light ? Colors.black : null,
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

class PieChartData {
  String x;
  double y;
  PieChartData({required this.x, required this.y});
}

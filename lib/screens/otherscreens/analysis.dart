import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum DateFilter { Day, Week, Month, Year }

class Analysis extends StatefulWidget {
  const Analysis({Key? key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  late DateTime _selectedDate = DateTime.now();
  late DateFilter _selectedFilter = DateFilter.Day;
  late List<_PieData> _pieData = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseData(_selectedDate);
  }

  Future<void> _fetchExpenseData(DateTime selectedDate) async {
    DateTime startDate;
    DateTime endDate;

    switch (_selectedFilter) {
      case DateFilter.Day:
        startDate =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        endDate = startDate.add(Duration(days: 1));
        break;
      case DateFilter.Week:
        startDate =
            selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        endDate = startDate.add(Duration(days: 7));
        break;
      case DateFilter.Month:
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
        break;
      case DateFilter.Year:
        startDate = DateTime(selectedDate.year, 1, 1);
        endDate = DateTime(selectedDate.year + 1, 1, 1);
        break;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: startDate, isLessThan: endDate)
        .get();

    final Map<String, int> categoryTotalMap = {};

    querySnapshot.docs.forEach((doc) {
      final category = doc['category'] as String;
      final amount = doc['amount'] as int;
      categoryTotalMap.update(category, (value) => value + amount,
          ifAbsent: () => amount);
    });

    setState(() {
      _pieData = categoryTotalMap.entries
          .map((entry) => _PieData(entry.key, entry.value))
          .toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              height: 120,
              child: Image.asset(
                'assets/images/appbarlogo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expense Analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('Day', DateFilter.Day),
                _buildFilterButton('Week', DateFilter.Week),
                _buildFilterButton('Month', DateFilter.Month),
                _buildFilterButton('Year', DateFilter.Year),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _pickDate,
                child: Text(
                  'Pick Date: ${_selectedDate.toString().split(' ')[0]}',
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 260,
              child: _pieData.isEmpty
                  ? Center(child: Text('No data available for selected date'))
                  : _buildPieChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, DateFilter filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
        _fetchExpenseData(_selectedDate);
      },
      child: Text(text),
    );
  }

  void _pickDate() async {
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
      _fetchExpenseData(pickedDate);
    }
  }

  Widget _buildPieChart() {
    return Center(
      child: SfCircularChart(
        title: ChartTitle(
          text: 'Categories',
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontSize: 15,
          ),
        ),
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            animationDuration: 760,
            explode: true,
            explodeIndex: null,
            dataSource: _pieData,
            xValueMapper: (_PieData data, _) => data.category,
            yValueMapper: (_PieData data, _) => data.amount,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
        legend: Legend(
          isVisible: true,
          position: LegendPosition.auto,
          orientation: LegendItemOrientation.vertical,
          alignment: ChartAlignment.near,
        ),
      ),
    );
  }
}

class _PieData {
  final String category;
  final int amount;

  _PieData(this.category, this.amount);
}

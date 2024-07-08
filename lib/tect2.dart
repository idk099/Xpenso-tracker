import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Syncfusion Chart Example')),
        body: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            labelRotation: 90, // Rotates labels to vertical
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: MajorGridLines(width: 0),
          ),
          series: <CartesianSeries>[
            ColumnSeries<ChartData, String>(
              dataSource: generateChartData(),
              xValueMapper: (ChartData data, _) => data.date,
              yValueMapper: (ChartData data, _) => data.sales,
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> generateChartData() {
    List<ChartData> data = [];
    for (int day = 1; day <= 31; day++) {
      data.add(ChartData('Jan $day', day.toDouble()));
    }
    return data;
  }
}

class ChartData {
  ChartData(this.date, this.sales);
  final String date;
  final double sales;
}

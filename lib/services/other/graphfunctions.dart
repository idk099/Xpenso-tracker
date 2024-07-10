 import 'package:xpenso/widgets/Piechart.dart';
import 'package:xpenso/widgets/custombargraph.dart';

List<BarGraphData> fil(List<BarGraphData> filteredDta, String filteredby,
      String month, String year) {
    List<BarGraphData> choice = [];
    if (filteredby == "Day") {
      for (var element in filteredDta) {
        if (element.x.contains('$month-$year')) {
          List<String> parts = element.x.split('-');
          String x = parts[0] + "-" + parts[1];

          var fil = BarGraphData(x: x, y: element.y);
          choice.add(fil);
        }
      }
    } else if (filteredby == "Month") {
      print("here");
      for (var element in filteredDta) {
        if (element.x .contains('$year')) {
          List<String> parts = element.x.split('-');

          var fil = BarGraphData(x: parts[0], y: element.y);
          choice.add(fil);
        }
      }
    }
    return choice;
  }


   List<BarGraphData> getTotalBargraphamount( List<BarGraphData> txnData) {
    List<BarGraphData> barData = [];

    Map<String, double> myMap = {};

    for (var element in txnData) {
      if (myMap.containsKey(element.x)) {
        myMap[element.x] = (myMap[element.x] ?? 0.0) + element.y;
      } else {
        myMap[element.x] = element.y;
      }
    }
    myMap.forEach((key, value) {
      String x = key;
      double y = value;
      var txn = BarGraphData(y: y, x: x);

      barData.add(txn);
    });
    return barData;
  }

  



   List<PieChartData> getTotalPiechartamount( List<PieChartData> filteredData) {
    List<PieChartData> pieChartData = [];

    Map<String, double> myMap = {};

    for (var element in filteredData) {
      if (myMap.containsKey(element.x)) {
        myMap[element.x] = (myMap[element.x] ?? 0.0) + element.y;
      } else {
        myMap[element.x] = element.y;
      }
    }
    myMap.forEach((key, value) {
      String x = key;
      double y = value;
      var txn = PieChartData(y: y, x: x);

      pieChartData.add(txn);
    });
    return pieChartData;
  }
import 'package:flutter/material.dart';
import 'month_year_picker_dialog.dart';

Future<DateTime?> showMonthYearPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color selectedColor = Colors.blue,
  Color unselectedColor = Colors.white,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return MonthYearPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
      );
    },
  );
}

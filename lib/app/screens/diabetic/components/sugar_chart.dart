import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../controller/diabetic_controller.dart';

class SugarChart extends StatelessWidget {
  final String isBp;

  SugarChart({super.key, required this.isBp});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiabeticController>(builder: (diabeticController) {
      final sugarList = (isBp == "Blood Pressure")
          ? diabeticController.bpChartList
          : diabeticController.sugarChartList;

      final isListEmpty = sugarList == null || sugarList.monthlySugarValues.isEmpty;
      final isSugarLoading = diabeticController.isDailySugarCheckupLoading;

      // Convert to data source for fasting and post-meal values
      List<SugarData> fastingData = [];
      List<SugarData> postMealData = [];

      sugarList?.monthlySugarValues.forEach((element) {
        DateTime? date = _parseDate(element.testDate);
        if (date != null) {
          // Fasting data
          final fastingValue = element.measureValues.isNotEmpty
              ? double.tryParse((isBp == "Blood Pressure")
              ? element.measureValues[0].systolic
              : element.measureValues[0].fastingSugar)
              : 0.0;
          if (fastingValue != null && fastingValue != 0) {
            fastingData.add(SugarData(date: date, value: fastingValue));
          }

          // Post-meal data
          final postMealValue = element.measureValues.isNotEmpty
              ? double.tryParse((isBp == "Blood Pressure")
              ? element.measureValues[0].diastolic ?? '0'
              : element.measureValues[0].measuredValue ?? '0')
              : 0.0;
          if (postMealValue != null && postMealValue != 0) {
            postMealData.add(SugarData(date: date, value: postMealValue));
          }
        }
      });




      // Sort the data by date
      fastingData.sort((a, b) => a.date.compareTo(b.date));
      postMealData.sort((a, b) => a.date.compareTo(b.date));


      double getMaxValue() {
        final fastingMax = fastingData.map((data) => data.value).reduce((a, b) => a > b ? a : b);
        final postMealMax = postMealData.map((data) => data.value).reduce((a, b) => a > b ? a : b);
        return (fastingMax > postMealMax ? fastingMax : postMealMax) + 50; // Add padding
      }
      // Debug: Log data
      print("Fasting Data: $fastingData");
      print("Post Meal Data: $postMealData");

      return isSugarLoading
          ? const Center(child: CircularProgressIndicator())
          : isListEmpty
          ? const Center(child: Text('Add Sugar Level For Track Details'))
          : SfCartesianChart(
        crosshairBehavior: CrosshairBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          shouldAlwaysShow: true,
        ),
        enableAxisAnimation: true,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('dd/MM'),
          intervalType: DateTimeIntervalType.days,
          minimum: fastingData.isNotEmpty ? fastingData.first.date : DateTime.now(),
          maximum: fastingData.isNotEmpty ? fastingData.last.date.add(Duration(days: 1)) : DateTime.now(),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 1000,
          interval: 50,
        ),
        series: <SplineSeries<SugarData, DateTime>>[
          if (isBp == "Blood Pressure" || isBp == "fasting")
            SplineSeries<SugarData, DateTime>(
              name: 'Fasting Values',
              dataSource: fastingData,
              xValueMapper: (SugarData data, _) => data.date,
              yValueMapper: (SugarData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              markerSettings: const MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.red,
              ),
              color: Colors.red,
            ),
          if (isBp == "Blood Pressure" || isBp == "postMeal")
            SplineSeries<SugarData, DateTime>(
              name: 'Post Meal Values',
              dataSource: postMealData,
              xValueMapper: (SugarData data, _) => data.date,
              yValueMapper: (SugarData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              markerSettings: const MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.blue,
              ),
              color: Colors.blue,
            ),
        ],
      );
    });
  }

  /// Helper function to parse dates safely
  DateTime? _parseDate(String? date) {
    try {
      return date != null ? DateTime.parse(date) : null;
    } catch (e) {
      print('Invalid date format: $date');
      return null;
    }
  }
}

class SugarData {
  final DateTime date;
  final double value;

  SugarData({required this.date, required this.value});

  @override
  String toString() => 'Date: $date, Value: $value';
}

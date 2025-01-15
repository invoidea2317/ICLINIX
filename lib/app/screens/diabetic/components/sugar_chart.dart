import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/response/diabetic_dashboard_detail_model.dart';

class SugarChart extends StatelessWidget {
  bool isBp;
  SugarChart({super.key,required this.isBp});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiabeticController>(builder: (diabeticController) {
      final sugarList = isBp?diabeticController.bpChartList:diabeticController.sugarChartList;
      final isListEmpty = sugarList == null || sugarList.monthlySugarValues.isEmpty;
      final isSugarLoading = diabeticController.isDailySugarCheckupLoading;

      // Convert to data source for fasting and post-meal values
      List<SugarData> fastingData = [];
      sugarList?.monthlySugarValues.forEach((element){
        fastingData.add(SugarData(date: DateTime.parse(element.testDate), value: element.measureValues.isNotEmpty?double.parse(isBp?element.measureValues[0].diastolic:element.measureValues[0].fastingSugar):0.0));
      });

      List<SugarData> postMealData = [];

      sugarList?.monthlySugarValues.forEach((element){
        postMealData.add(SugarData(date: DateTime.parse(element.testDate), value: element.measureValues.isNotEmpty?double.parse(isBp?element.measureValues[0].systolic:element.measureValues[0].measuredValue):0.0));
      });

      return isSugarLoading
          ? const Center(child: CircularProgressIndicator())
          : isListEmpty
          ? const Center(child: Text('Add Sugar Level For Track Details'))
          : SfCartesianChart(
        enableAxisAnimation: true,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('MM/dd'), // Show date only in MM/DD format
          intervalType: DateTimeIntervalType.days,
        ),
        primaryYAxis: const NumericAxis(),
        series: <LineSeries<SugarData, DateTime>>[
          LineSeries<SugarData, DateTime>(
            name: 'Fasting Values',
            dataSource: fastingData ?? [],
            xValueMapper: (SugarData data, _) => data.date!,
            yValueMapper: (SugarData data, _) => data.value,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            markerSettings: const MarkerSettings(
              isVisible: true, // Enables dots at data points
              shape: DataMarkerType.circle, // Shape of the dots
              borderWidth: 2, // Border width of the dots
              borderColor: Colors.red, // Border color
            ),
            color: Colors.red,
          ),
          LineSeries<SugarData, DateTime>(
            name: 'Post Meal Values',
            dataSource: postMealData ?? [],
            xValueMapper: (SugarData data, _) => data.date!,
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
      return null;
    }
  }
}

class SugarData {
  final DateTime date;
  final double value;

  SugarData({required this.date, required this.value});
}

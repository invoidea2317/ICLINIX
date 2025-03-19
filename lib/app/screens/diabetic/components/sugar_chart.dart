import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../controller/diabetic_controller.dart';

class SugarChart extends StatefulWidget {
  final String isBp;

  SugarChart({super.key, required this.isBp});

  @override
  State<SugarChart> createState() => _SugarChartState();
}

class _SugarChartState extends State<SugarChart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      animationDuration: 200,
      header: '',
      format: 'point.x : point.y',
      canShowMarker: true,
      tooltipPosition: TooltipPosition.pointer, // Try this explicitly
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiabeticController>(builder: (diabeticController) {
      final sugarList = (widget.isBp == "Blood Pressure")
          ? diabeticController.bpChartList
          : diabeticController.sugarChartList;

      final isListEmpty =
          sugarList == null || sugarList.monthlySugarValues.isEmpty;
      final isSugarLoading = diabeticController.isDailySugarCheckupLoading;

      // Convert to data source for fasting and post-meal values
      List<SugarData> fastingData = [];
      List<SugarData> postMealData = [];

      sugarList?.monthlySugarValues.forEach((element) {
        DateTime? date = _parseDate(element.testDate);
        debugPrint('Date: $date');

        if (date != null) {
          // Fasting data
          final fastingValue = element.measureValues.isNotEmpty
              ? double.tryParse((widget.isBp == "Blood Pressure")
                  ? element.measureValues[0].systolic
                  : element.measureValues[0].fastingSugar)
              : 0.0;
          if (fastingValue != null && fastingValue != 0) {
            fastingData.add(SugarData(date: date, value: fastingValue));
          }

          // Post-meal data
          final postMealValue = element.measureValues.isNotEmpty
              ? double.tryParse((widget.isBp == "Blood Pressure")
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
        final fastingMax = fastingData
            .map((data) => data.value)
            .reduce((a, b) => a > b ? a : b);
        final postMealMax = postMealData
            .map((data) => data.value)
            .reduce((a, b) => a > b ? a : b);
        return (fastingMax > postMealMax ? fastingMax : postMealMax) +
            50; // Add padding
      }

      debugPrint('Fasting data: $fastingData');
      debugPrint('post data: $postMealData');

      // Debug: Log data

      return isSugarLoading
          ? const Center(child: CircularProgressIndicator())
          : isListEmpty
              ? const Center(child: Text('Add Sugar Level For Track Details'))
              : GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    print('check');
                    // Get the tapped position
                    final position = details.localPosition;
                    print(details.localPosition);
                    print('check2');

                    // Trigger the tooltip to show at the tapped position
                    _tooltipBehavior.showByPixel(position.dx, position.dy);
                    print('check3');
                    print(_tooltipBehavior.tooltipPosition);
                  },
                  child: SfCartesianChart(
                    // onTooltipRender: ( args) {
                    //   print("Check 4===${args.dataPoints}");
                    // },
                    tooltipBehavior: _tooltipBehavior,
                    margin: const EdgeInsets.all(8),
                    enableAxisAnimation: true,
                    borderWidth: 0,
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat('dd/MM'),
                      interval: 1,
                      intervalType: DateTimeIntervalType.days,
                      minimum: fastingData.isNotEmpty
                          ? fastingData.first.date
                          : DateTime.now(),
                      maximum: fastingData.isNotEmpty
                          ? fastingData.last.date.add(const Duration(days: 1))
                          : DateTime.now(),
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 1),
                    ),
                    primaryYAxis: NumericAxis(
                  // maximum: widget.isBp == "Blood Pressure"?400:700,
                      minimum: 0,
                      interval: 100,
                      majorGridLines: MajorGridLines(width: 0),
                      axisLine: AxisLine(width: 1),
                    ),
                    series: <SplineSeries<SugarData, DateTime>>[
                      if (widget.isBp == "Blood Pressure" ||
                          widget.isBp == "fasting")
                        SplineSeries<SugarData, DateTime>(
                          name: 'Fasting Values',
                          dataSource: fastingData,
                          xValueMapper: (SugarData data, _) => data.date,
                          yValueMapper: (SugarData data, _) => data.value,
                          dataLabelSettings:
                              const DataLabelSettings(
                                  isVisible: true,
                                alignment: ChartAlignment.center,
                                  labelAlignment: ChartDataLabelAlignment.top,
                                  margin: EdgeInsets.all(0)
                              ),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            borderWidth: 5,
                            borderColor: widget.isBp == "fasting"
                                ? const Color(0xFFCC9531)
                                : const Color.fromRGBO(255, 159, 64, 1),
                          ),
                          color: widget.isBp == "fasting"
                              ? const Color(0xFFCC9531)
                              : const Color.fromRGBO(255, 159, 64, 1),
                        ),
                      if (widget.isBp == "Blood Pressure" ||
                          widget.isBp == "postMeal")
                        SplineSeries<SugarData, DateTime>(
                          name: 'Post Meal Values',
                          dataSource: postMealData,
                          xValueMapper: (SugarData data, _) => data.date,
                          yValueMapper: (SugarData data, _) => data.value,
                          dataLabelSettings:
                              const DataLabelSettings(
                                  isVisible: true,
                                  // alignment: ChartAlignment.far,
                                  margin: EdgeInsets.all(0),
                                labelAlignment: ChartDataLabelAlignment.bottom,
                              ),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            borderWidth: 5,
                            borderColor: widget.isBp == "postMeal"
                                ? const Color(0xFF31CC64)
                                : const Color.fromRGBO(153, 102, 255, 1),
                          ),
                          color: widget.isBp == "postMeal"
                              ? const Color(0xFF31CC64)
                              : const Color.fromRGBO(153, 102, 255, 1),
                        ),
                    ],
                  ),
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

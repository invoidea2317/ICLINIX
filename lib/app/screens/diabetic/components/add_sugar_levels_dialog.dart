import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/blood_sugar_input_field.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/helper/date_converter.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/styles.dart';

import '../../../../data/models/response/diabetic_dashboard_detail_model.dart';
import '../../../widget/custom_dropdown_field.dart';
import '../../dashboard/dashboard_screen.dart';

class AddSugarLevelsDialog extends StatefulWidget {
  final bool? isBp;

  AddSugarLevelsDialog({super.key, this.isBp = false});

  @override
  State<AddSugarLevelsDialog> createState() => _AddSugarLevelsDialogState();
}

class _AddSugarLevelsDialogState extends State<AddSugarLevelsDialog> {
  final _fastingSugarController = TextEditingController();

  final _diastolicController = TextEditingController();

  final _systolicController = TextEditingController();

  final _measuredValueController = TextEditingController();

  final afterLunchController = TextEditingController();

  final afterDinnerController = TextEditingController();

  final randomEntryController = TextEditingController();

  final _dateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fastingTest = 'Fasting Blood Sugar';
  String postPrandialTest = 'Postprandial Sugars';
  String PleaseSelectDropdown = 'Please select Blood Sugar';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fastingTest = widget.isBp! ? 'Blood Pressure' : 'Fasting Blood Sugar';
     postPrandialTest = widget.isBp! ? 'Blood Pressure' : 'Postprandial Sugars';
     PleaseSelectDropdown =
    widget.isBp! ? 'Blood Pressure' : 'Please select Blood Sugar';

    if((widget.isBp ?? false)){
      _diastolicController.text = ((Get.find<DiabeticController>().todayBpValue ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues.isEmpty)?"0":(Get.find<DiabeticController>().todayBpValue ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues[0].diastolic;
      _systolicController.text = ((Get.find<DiabeticController>().todayBpValue ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues.isEmpty)?"0":(Get.find<DiabeticController>().todayBpValue ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues[0].systolic;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.find<DiabeticController>().updateDate(DateTime.parse((Get.find<DiabeticController>().todayBpValue ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).testDate));
          _dateController.text = Get.find<DiabeticController>().formattedDate!;
        }
      });

    } else {
      _fastingSugarController.text = ((Get.find<DiabeticController>().todaySugar ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues.isEmpty)?"0":(Get.find<DiabeticController>().todaySugar ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues[0].fastingSugar;
      _measuredValueController.text = ((Get.find<DiabeticController>().todaySugar ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues.isEmpty)?"0":(Get.find<DiabeticController>().todaySugar ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).measureValues[0].measuredValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.find<DiabeticController>().updateDate(DateTime.parse((Get.find<DiabeticController>().todaySugar ?? MonthlySugarValue(testDate: DateTime.now().toString(),measureValues: [])).testDate));
          _dateController.text = Get.find<DiabeticController>().formattedDate!;
        }
      });
    }
  }


  Widget whichWidget(DiabeticController controller){
    if(controller.sugarChartList!.monthlySugarValues.isNotEmpty && !(widget.isBp ?? false)){
      return SizedBox(
        height: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.sugarChartList!.monthlySugarValues.length,
          itemBuilder: (context, index) {
            final checkup = controller.sugarChartList!.monthlySugarValues[index];
            String heading;
            switch (int.parse(checkup.measureValues.isEmpty?"5":checkup.measureValues[0].checkingTime)) {
              case 1:
                heading = "Before Meal";
                break;
              case 2:
                heading = "After Breakfast";
                break;
              case 3:
                heading = "After Lunch";
                break;
              case 4:
                heading = "After Dinner";
                break;
              case 5:
                heading = "Random Entry";
                break;
              default:
                heading = "Unknown";
            }
            return ListTile(
              title: Text(
                  "Date: ${AppointmentDateTimeConverter.formatDate(checkup.testDate.toString())}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Fasting Sugar: ${checkup.measureValues.isEmpty?"0":checkup.measureValues[0].fastingSugar} mg/dL"),
                  Text(
                      "$heading: ${checkup.measureValues.isEmpty?"0":checkup.measureValues[0].measuredValue} mg/dL"),
                ],
              ),
            );
          },
        ),
      );
    }

    if(controller.bpChartList!.monthlySugarValues.isNotEmpty && (widget.isBp ?? false)) {
      return SizedBox(
        height: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.bpChartList!.monthlySugarValues.length,
          itemBuilder: (context, index) {
            final checkup = controller.bpChartList!.monthlySugarValues[index];
            String heading;
            return ListTile(
              title: Text(
                  "Date: ${AppointmentDateTimeConverter.formatDate(checkup.testDate.toString())}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Diastolic: ${checkup.measureValues.isEmpty?"0":checkup.measureValues[0].diastolic} mmHg"),
                  Text(
                      "Systolic: ${checkup.measureValues.isEmpty?"0":checkup.measureValues[0].systolic} mmHg"),
                ],
              ),
            );
          },
        ),
      );
    }

    return const Center(
        child: Text("No sugar history available"));
  }
  @override
  Widget build(BuildContext context) {


    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize10),
      child: GetBuilder<DiabeticController>(builder: (diabeticControl) {
        _dateController.text = Get.find<DiabeticController>().formattedDate!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Get.size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius5)),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  // color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        diabeticControl.showHistory == true
                            ? widget.isBp!
                                ? 'Bp history'
                                : 'Sugar History'
                            : widget.isBp!
                                ? 'Add Blood Pressure Data'
                                : 'Add Sugar',
                        style: openSansSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).cardColor),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // await diabeticControl.getSugarCheckUpHistory();
                              diabeticControl.toggleShowHistory(true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: diabeticControl.showHistory
                                      ? Theme.of(context)
                                          .cardColor
                                          .withOpacity(0.10)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius10)),
                              child: Icon(
                                Icons.history,
                                size: Dimensions.fontSize30,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              diabeticControl.toggleShowHistory(false);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: diabeticControl.showHistory == false
                                      ? Theme.of(context)
                                          .cardColor
                                          .withOpacity(0.10)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius10)),
                              child: Icon(
                                Icons.add,
                                size: Dimensions.fontSize30,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    diabeticControl.showHistory
                        ?  whichWidget(diabeticControl)
                        : Form(
                            key: _formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sizedBox20(),
                                  Text(
                                    'Test Date',
                                    style: openSansRegular.copyWith(
                                        fontSize: Dimensions.fontSize12),
                                  ),
                                  sizedBox5(),
                                  CustomTextField(
                                    controller: _dateController,
                                    readOnly: true,
                                    onChanged: (val) {
                                      _dateController.text = diabeticControl
                                          .formattedDate
                                          .toString();
                                    },
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate: DateTime(2100),
                                      );
                                      if (pickedDate != null) {
                                        diabeticControl.updateDate(pickedDate);
                                      }
                                    },
                                    validation: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a test date';
                                      }
                                      return null;
                                    },
                                    hintText: 'Select Test Date',
                                    isCalenderIcon: true,
                                    editText: true,
                                    suffixText: '',
                                  ),
                                  sizedBox10(),
                                  Text(
                                    fastingTest,
                                    style: openSansRegular.copyWith(
                                        fontSize: Dimensions.fontSize12),
                                  ),
                                  Visibility(
                                      visible: widget.isBp!,
                                      child: BloodSugarInput(
                                        maxLength: 3,
                                        suffixText: "mmHg",
                                        title: "Systolic ",
                                        hintText: "Systolic ",
                                        controller: _systolicController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter a Value';
                                          }
                                          return null;
                                        },
                                      )),
                                  BloodSugarInput(
                                      maxLength: 3,
                                    suffixText: widget.isBp! ? "mmHg" : "mg/dL",
                                    title: widget.isBp! ? "Diastolic " : fastingTest,
                                    hintText:
                                        widget.isBp! ? "Diastolic " : fastingTest,
                                    controller: widget.isBp!
                                        ? _diastolicController
                                        : _fastingSugarController,
                                    validator: (value) {
                                      if(widget.isBp!) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter a Value';
                                        }
                                      } else {
                                        if(_measuredValueController.text.isEmpty && value!.isEmpty){
                                          return "Enter PostPrandial Sugars or Fasting Sugar";
                                        }
                                      }
                                      return null;
                                    }
                                  ),
                                  sizedBox10(),
                                  Visibility(
                                    visible: !widget.isBp!,
                                    child: CustomDropdownField(
                                      hintText: postPrandialTest,
                                      selectedValue: diabeticControl
                                              .selectedSugarCheck.isEmpty
                                          ? null
                                          : diabeticControl.selectedSugarCheck,
                                      options: diabeticControl
                                          .uniqueSugarCheckOptions,
                                      // Use the unique options list here
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          diabeticControl
                                              .updateSugarCheck(newValue);
                                          print(diabeticControl
                                              .selectedSugarCheck);
                                          print(
                                              "Selected Value: ${diabeticControl.selectedSugarCheckValue}"); // Numeric value
                                        }
                                      },
                                      validator: (value) {
                                        if(_fastingSugarController.text.isEmpty && (value ?? "").isEmpty){
                                          return "Enter PostPrandial Sugars or Fasting Sugar";
                                        }
                                        return null;
                                      },
                                      showTitle:
                                          true, // Set to true to show title
                                    ),
                                  ),
                                  sizedBox10(),
                                  diabeticControl.selectedSugarCheck.isEmpty
                                      ? const SizedBox()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              diabeticControl
                                                  .selectedSugarCheck,
                                              style: openSansRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSize12),
                                            ),
                                            BloodSugarInput(
                                              maxLength: 3,
                                              suffixText:
                                                  widget.isBp! ? "mm/Hg" : "mg/dL",
                                              title: diabeticControl
                                                  .selectedSugarCheck,
                                              hintText: diabeticControl
                                                  .selectedSugarCheck,
                                              controller:
                                                  _measuredValueController,
                                              validator: (value){
                                                if(_fastingSugarController.text.isEmpty && value!.isEmpty){
                                                  return "Enter PostPrandial Sugars or Fasting Sugar";
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                  widget.isBp!
                                      ? SizedBox()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            sizedBox10(),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'HbA1c %',
                                                    style: openSansRegular.copyWith(
                                                        fontSize:
                                                            Dimensions.fontSize12),
                                                  ),
                                                ),

                                                Checkbox(
                                                  value: diabeticControl.isHba1c,
                                                  activeColor: Theme.of(context).primaryColor,
                                                  fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                                    if (states.contains(MaterialState.selected)) {
                                                      return Theme.of(context).primaryColor; // Active color
                                                    }
                                                    return Colors.grey; // Inactive color
                                                  }),
                                                  onChanged: (value) {
                                                    diabeticControl.updateIsHba1c(!diabeticControl.isHba1c);
                                                  },
                                                )

                                              ],
                                            ),
                                            Visibility(
                                              visible: diabeticControl.isHba1c,
                                              child: Obx(() {
                                                return Slider(
                                                  value: diabeticControl
                                                      .hbA1cPercentage.value,
                                                  min: 5.0,
                                                  max: 7.0,
                                                  divisions: 20,
                                                  label: diabeticControl
                                                      .hbA1cPercentage.value
                                                      .toStringAsFixed(1),
                                                  onChanged: (double newValue) {
                                                    diabeticControl
                                                        .hbA1cPercentage
                                                        .value = newValue;
                                                  },
                                                );
                                              }),
                                            ),
                                            Visibility(
                                              visible: diabeticControl.isHba1c,
                                              child: Obx(() {
                                                return Text(
                                                  'Selected Percentage: ${diabeticControl.hbA1cPercentage.value} %',
                                                  style: openSansRegular.copyWith(
                                                      fontSize:
                                                          Dimensions.fontSize12),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                  sizedBoxDefault(),
                                  sizedBoxDefault(),
                                  diabeticControl.isDailySugarCheckupLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : Row(
                                          children: [
                                            Flexible(
                                              child: CustomButtonWidget(
                                                buttonText: 'Cancel',
                                                transparent: true,
                                                isBold: false,
                                                fontSize: Dimensions.fontSize14,
                                                onPressed: () {
                                                  Get.back();
                                                  diabeticControl.selectedSugarCheck = "";
                                                },
                                              ),
                                            ),
                                            sizedBoxW10(),
                                            Flexible(
                                              child: CustomButtonWidget(
                                                buttonText: 'Save',
                                                isBold: false,
                                                fontSize: Dimensions.fontSize14,
                                                onPressed: () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    diabeticControl.addSugarApi(
                                                      widget.isBp! ? 'bp' : 'sugar',
                                                      diabeticControl
                                                          .selectedSugarCheckValue
                                                          .toString(),
                                                      _fastingSugarController
                                                          .text == "0"?null:_fastingSugarController
                                                          .text,
                                                      _measuredValueController
                                                          .text == "0"?null:_measuredValueController
                                                          .text,
                                                      _dateController.text,
                                                        diabeticControl.isHba1c?diabeticControl
                                                          .hbA1cPercentage.value
                                                          .toString():"",
                                                        widget.isBp! ? _systolicController.text : null,
                                                        widget.isBp! ? _diastolicController.text : null
                                                    ).then((value){
                                                      if(value){
                                                        Get.to(()=>DashboardScreen(pageIndex: 1));
                                                      }
                                                      diabeticControl.selectedSugarCheck = "";
                                                    });

                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                  sizedBoxDefault(),
                                ]),
                          ),
                  ],
                ),

                // sizedBoxDefault(),

                // diabeticControl.showHistory
                //     ? diabeticControl.isDailySugarCheckupLoading
                //     ? const Center(child: CircularProgressIndicator())
                //     : diabeticControl.sugarCheckUpList!.isNotEmpty
                //     ? SizedBox(height: 500,
                //       child: ListView.builder(
                //         shrinkWrap: true,
                //         itemCount:
                //         diabeticControl.sugarCheckUpList!.length,
                //         itemBuilder: (context, index) {
                //       final checkup =
                //       diabeticControl.sugarCheckUpList![index];
                //       String heading;
                //       switch (checkup.checkingTime) {
                //         case 1:
                //           heading = "Before Meal";
                //           break;
                //         case 2:
                //           heading = "After Breakfast";
                //           break;
                //         case 3:
                //           heading = "After Lunch";
                //           break;
                //         case 4:
                //           heading = "After Dinner";
                //           break;
                //         case 5:
                //           heading = "Random Entry";
                //           break;
                //         default:
                //           heading = "Unknown";
                //       }
                //       return ListTile(
                //         title: Text("Date: ${AppointmentDateTimeConverter.formatDate(checkup.testDate.toString())}"),
                //         subtitle: Text(
                //             "$heading: ${checkup.measuredValue ?? 'N/A'}"),
                //       );
                //                         },
                //                       ),
                //     )
                //     : const Center(
                //     child: Text("No sugar history available"))
                //     : Form(
                //   key: _formKey,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       sizedBox20(),
                //       Text(
                //         'Test Date',
                //         style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                //       ),
                //       sizedBox5(),
                //       CustomTextField(
                //         controller: _dateController,
                //         readOnly: true,
                //         onChanged: (val) {
                //           _dateController.text = diabeticControl.formattedDate.toString();
                //         },
                //
                //         onTap: () async {
                //           DateTime? pickedDate = await showDatePicker(
                //             context: context,
                //             initialDate: DateTime.now(),
                //             firstDate: DateTime(2010),
                //             lastDate: DateTime(2100),
                //           );
                //           if (pickedDate != null) {
                //             diabeticControl.updateDate(pickedDate);
                //
                //           }
                //         },
                //         validation: (value) {
                //           if (value == null || value.isEmpty) {
                //             return 'Please select a test date';
                //           }
                //           return null;
                //         },
                //         hintText: 'Select Test Date',
                //         isCalenderIcon: true,
                //         editText: true,
                //         suffixText: '',
                //       ),
                //       sizedBox10(),
                //       Text(
                //         fastingTest,
                //         style:   openSansRegular.copyWith(
                //             fontSize: Dimensions.fontSize12
                //         ), //,
                //       ),
                //       BloodSugarInput(
                //         title: fastingTest,
                //         hintText: fastingTest,
                //         controller: _fastingSugarController,
                //         validator: (value) {
                //           if (value == null || value.isEmpty) {
                //             return 'Add Value';
                //           }
                //           return null;
                //         },
                //       ),
                //       sizedBox10(),
                //       CustomDropdownField(
                //         hintText: postPrandialTest,
                //         selectedValue: diabeticControl.selectedSugarCheck.isEmpty ? null : diabeticControl.selectedSugarCheck,
                //         options: diabeticControl.uniqueSugarCheckOptions,  // Use the unique options list here
                //         onChanged: (String? newValue) {
                //           if (newValue != null) {
                //             diabeticControl.updateSugarCheck(newValue);
                //             print(diabeticControl.selectedSugarCheck);
                //             print("Selected Value: ${diabeticControl.selectedSugarCheckValue}");  // Numeric value
                //           }
                //         },
                //         validator: (value) {
                //           if (value == null || value.isEmpty) {
                //             return PleaseSelectDropdown;
                //           }
                //           return null;
                //         },
                //         showTitle: true, // Set to true to show title
                //       ),
                //
                //       sizedBox10(),
                //       diabeticControl.selectedSugarCheck.isEmpty ? const SizedBox() :
                //       Column(crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             diabeticControl.selectedSugarCheck,
                //             style:   openSansRegular.copyWith(
                //                 fontSize: Dimensions.fontSize12
                //             ), //,
                //           ),
                //           BloodSugarInput(
                //             title:  diabeticControl.selectedSugarCheck,
                //             hintText:  diabeticControl.selectedSugarCheck,
                //             controller: _measuredValueController,
                //             validator: (value) {
                //               if (value == null || value.isEmpty) {
                //                 return 'Add Value';
                //               }
                //               return null;
                //             },
                //           ),
                //         ],
                //       ),
                //       isBp! ? SizedBox() :
                //       Column(crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           sizedBox10(),
                //           Text(
                //           'HbA1c %',
                //           style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),),
                //           Obx(() {
                //             return Slider(
                //               value: diabeticControl.hbA1cPercentage.value,
                //               min: 5.0,
                //               max: 7.0,
                //               divisions: 20,
                //               label: diabeticControl.hbA1cPercentage.value.toStringAsFixed(1),
                //               onChanged: (double newValue) {
                //                 diabeticControl.hbA1cPercentage.value = newValue;
                //               },
                //             );
                //           }),
                //           Obx(() {
                //             return Text(
                //               'Selected Percentage: ${diabeticControl.hbA1cPercentage.value} %',
                //               style: openSansRegular.copyWith(
                //                   fontSize: Dimensions.fontSize12
                //               ),
                //             );
                //           }),
                //         ],
                //       ),
                //       sizedBoxDefault(),
                //       sizedBoxDefault(),
                //       diabeticControl.isDailySugarCheckupLoading
                //           ? const Center(
                //           child: CircularProgressIndicator())
                //           : Row(
                //         children: [
                //           Flexible(
                //             child: CustomButtonWidget(
                //               buttonText: 'Cancel',
                //               transparent: true,
                //               isBold: false,
                //               fontSize: Dimensions.fontSize14,
                //               onPressed: () {
                //                 Get.back();
                //               },
                //             ),
                //           ),
                //           sizedBoxW10(),
                //           Flexible(
                //             child: CustomButtonWidget(
                //               buttonText: 'Save',
                //               isBold: false,
                //               fontSize: Dimensions.fontSize14,
                //               onPressed: () {
                //                 if (_formKey.currentState!.validate()) {
                //                   diabeticControl.addSugarApi(
                //                     isBp! ?  '1' :'0',
                //                     diabeticControl.selectedSugarCheckValue.toString(),
                //                       _fastingSugarController.text,
                //                       _measuredValueController.text,
                //                       _dateController.text,
                //                       diabeticControl.hbA1cPercentage.value.toString(),
                //                   );
                //                 }
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //       sizedBoxDefault(),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

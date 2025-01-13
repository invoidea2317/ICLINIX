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

import '../../../widget/custom_dropdown_field.dart';

class AddSugarLevelsDialog extends StatelessWidget {
  final bool? isBp;
  AddSugarLevelsDialog({super.key, this.isBp = false});

  final _fastingSugarController = TextEditingController();
  final _measuredValueController = TextEditingController();
  final afterLunchController = TextEditingController();
  final afterDinnerController = TextEditingController();
  final randomEntryController = TextEditingController();
  final _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String fastingTest = isBp! ? 'Blood Pressure' : 'Fasting Blood Sugar';
    String postPrandialTest =isBp! ? 'Blood Pressure' : 'Postprandial Sugars';
    String PleaseSelectDropdown =isBp! ? 'Blood Pressure' : 'Please select Blood Sugar';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize10),
      child: GetBuilder<DiabeticController>(builder: (diabeticControl) {
        _dateController.text = diabeticControl.formattedDate!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Get.size.width,
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius5)
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  // color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(diabeticControl.showHistory == true ? isBp! ? 'Bp history' :'Sugar History' : isBp! ? 'Add Blood Pressure Data' : 'Add Sugar',
                      style: openSansSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).cardColor),),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await diabeticControl.getSugarCheckUpHistory();
                                  diabeticControl.toggleShowHistory(true);
                              },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: diabeticControl.showHistory ?
                                  Theme.of(context).cardColor.withOpacity(0.10) :
                                      Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimensions.radius10)
                              ),

                              child: Icon(Icons.history,
                                size: Dimensions.fontSize30,
                                color: Theme.of(context).cardColor,),
                            ),
                          ),

                          GestureDetector(
                            onTap: () async {
                                  diabeticControl.toggleShowHistory(false);
                            },
                            child: Container(padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: diabeticControl.showHistory == false ?
                                  Theme.of(context).cardColor.withOpacity(0.10) :
                                  Colors.transparent,
                                  borderRadius: BorderRadius.circular(Dimensions.radius10)
                              ),
                              child: Icon(Icons.add,
                                size: Dimensions.fontSize30,
                                color: Theme.of(context).cardColor,),
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
                        ? diabeticControl.isDailySugarCheckupLoading
                        ? const Center(child: CircularProgressIndicator())
                        : diabeticControl.sugarCheckUpList!.isNotEmpty
                        ? SizedBox(
                      height: 500,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: diabeticControl.sugarCheckUpList!
                            .where((checkup) =>
                        (isBp! && checkup.testType == 1) || // Show test_type 1 for BP
                            (!isBp! && checkup.testType == 0)) // Show test_type 0 for sugar
                            .toList()
                            .length,
                        itemBuilder: (context, index) {
                          final checkup = diabeticControl.sugarCheckUpList!
                              .where((checkup) =>
                          (isBp! && checkup.testType == 1) || // Show test_type 1 for BP
                              (!isBp! && checkup.testType == 0)) // Show test_type 0 for sugar
                              .toList()[index];
                          String heading;
                          switch (checkup.checkingTime) {
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
                            title: Text("Date: ${AppointmentDateTimeConverter.formatDate(checkup.testDate.toString())}"),
                            subtitle: Text("$heading: ${checkup.measuredValue ?? 'N/A'}"),
                          );
                        },
                      ),
                    )
                        : const Center(child: Text("No sugar history available"))
                        : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sizedBox20(),
                          Text(
                            'Test Date',
                            style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                          ),
                          sizedBox5(),
                          CustomTextField(
                            controller: _dateController,
                            readOnly: true,
                            onChanged: (val) {
                              _dateController.text = diabeticControl.formattedDate.toString();
                            },
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
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
                            style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                          ),
                          BloodSugarInput(
                            suffixText: isBp!?"mm/Hg":"mg/dL",
                            title: fastingTest,
                            hintText: fastingTest,
                            controller: _fastingSugarController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Add Value';
                              }
                              return null;
                            },
                          ),
                          sizedBox10(),
                          CustomDropdownField(
                            hintText: postPrandialTest,
                            selectedValue: diabeticControl.selectedSugarCheck.isEmpty ? null : diabeticControl.selectedSugarCheck,
                            options: diabeticControl.uniqueSugarCheckOptions, // Use the unique options list here
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                diabeticControl.updateSugarCheck(newValue);
                                print(diabeticControl.selectedSugarCheck);
                                print("Selected Value: ${diabeticControl.selectedSugarCheckValue}"); // Numeric value
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return PleaseSelectDropdown;
                              }
                              return null;
                            },
                            showTitle: true, // Set to true to show title
                          ),
                          sizedBox10(),
                          diabeticControl.selectedSugarCheck.isEmpty
                              ? const SizedBox()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diabeticControl.selectedSugarCheck,
                                style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                              ),
                              BloodSugarInput(
                                suffixText: isBp!?"mm/Hg":"mg/dL",
                                title: diabeticControl.selectedSugarCheck,
                                hintText: diabeticControl.selectedSugarCheck,
                                controller: _measuredValueController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Add Value';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          isBp!
                              ? SizedBox()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sizedBox10(),
                              Text(
                                'HbA1c %',
                                style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                              ),
                              Obx(() {
                                return Slider(
                                  value: diabeticControl.hbA1cPercentage.value,
                                  min: 5.0,
                                  max: 7.0,
                                  divisions: 20,
                                  label: diabeticControl.hbA1cPercentage.value.toStringAsFixed(1),
                                  onChanged: (double newValue) {
                                    diabeticControl.hbA1cPercentage.value = newValue;
                                  },
                                );
                              }),
                              Obx(() {
                                return Text(
                                  'Selected Percentage: ${diabeticControl.hbA1cPercentage.value} %',
                                  style: openSansRegular.copyWith(fontSize: Dimensions.fontSize12),
                                );
                              }),
                            ],
                          ),
                          sizedBoxDefault(),
                          sizedBoxDefault(),
                          diabeticControl.isDailySugarCheckupLoading
                              ? const Center(child: CircularProgressIndicator())
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
                                    if (_formKey.currentState!.validate()) {
                                      diabeticControl.addSugarApi(
                                        isBp! ? '1' : '0',
                                        diabeticControl.selectedSugarCheckValue.toString(),
                                        _fastingSugarController.text,
                                        _measuredValueController.text,
                                        _dateController.text,
                                        diabeticControl.hbA1cPercentage.value.toString(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          sizedBoxDefault(),
                        ],
                      ),
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

import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/diabetic/components/add_sugar_levels_dialog.dart';
import 'package:iclinix/app/widget/blood_sugar_input_field.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:get/get.dart';

import '../../../../utils/styles.dart';
import '../../../widget/custom_snackbar.dart';

class AddHealthParameterDialog extends StatefulWidget {
  final String patientId;
  const AddHealthParameterDialog({super.key,required this.patientId});

  @override
  _AddHealthParameterDialogState createState() => _AddHealthParameterDialogState();
}

class _AddHealthParameterDialogState extends State<AddHealthParameterDialog> with SingleTickerProviderStateMixin {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final waistController = TextEditingController();
  final hipController = TextEditingController();
  final bMIController = TextEditingController();
  final daibetesController = TextEditingController();
  final yearController = TextEditingController();
  final monthController = TextEditingController();
  final systolicBpController = TextEditingController();
  final diastolicBpController = TextEditingController();
  final bpDateController = TextEditingController();
  final bpTimeController = TextEditingController();
  final otherHealthController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DiabeticController>().getSubscribedPatientDataApi();
      yearController.text ="0";
      monthController.text ="0";
    });
  }

  void _calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double heightInMeters = (double.tryParse(heightController.text) ?? 0.0) / 100;

    if (heightInMeters > 0) {
      double bmi = weight / (heightInMeters * heightInMeters);
      bMIController.text = bmi.toStringAsFixed(2);
    } else {
      bMIController.clear();
    }
  }

  String durationType = "Months";
  void _toggleDurationType(String value) {
    if (value != durationType) {
      setState(() {
        durationType = value;

        // Convert existing duration value between months and years
        if (daibetesController.text.isNotEmpty) {
          double duration = double.tryParse(daibetesController.text) ?? 0.0;
          if (value == "Years") {
            // Convert months to years
            daibetesController.text = (duration / 12).toStringAsFixed(1);
          } else {
            // Convert years to months
            daibetesController.text = (duration * 12).toStringAsFixed(0);
          }
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize10),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: GetBuilder<DiabeticController>(builder: (controller) {
            WidgetsBinding.instance.addPostFrameCallback((_) {

              bpDateController.text = controller.formattedDate ?? '';
              bpTimeController.text = controller.formattedTime ?? '';
              weightController.text = controller.subscribedPatientData?.weight ?? '';
              heightController.text = controller.subscribedPatientData?.height?.toString() ?? '';
              waistController.text = controller.subscribedPatientData?.waistCircumference?.toString() ?? '';
              hipController.text = controller.subscribedPatientData?.hipCircumference?.toString() ?? '';
              yearController.text = controller.subscribedPatientData?.duraDiabetes?["year"] ?? '';
              monthController.text = controller.subscribedPatientData?.duraDiabetes?["month"] ?? '';
              double weight = double.tryParse(weightController.text) ?? 0;
              double height = double.tryParse(heightController.text) ?? 0;
              String bmi = '';
              if (height > 0) {
                bmi = (weight / ((height / 100) * (height / 100))).toStringAsFixed(2); // height in cm
              }
              bMIController.text = bmi;
            });


            return Padding(
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
                    child:
                    Text('Heath Data',style: openSansMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).cardColor),),
                  ),
                  sizedBox10(),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BloodSugarInput(
                          title: 'Weight',
                          hintText: 'Weight',
                          controller: weightController,
                          suffixText: 'Kg',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight'; // Validation message
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue <= 0) {
                              return 'Please enter a valid weight'; // Validation message for invalid number
                            }
                            return null; // Return null if valid
                          },
                          onChanged: (value) => _calculateBMI(), // Update BMI on weight change
                        ),
                        sizedBox10(),
                        BloodSugarInput(
                          title: 'Height',
                          hintText: 'Height',
                          controller: heightController,
                          suffixText: 'Cm',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height'; // Validation message
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue <= 0) {
                              return 'Please enter a valid height'; // Validation message for invalid number
                            }
                            return null; // Return null if valid
                          },
                          onChanged: (value) => _calculateBMI(), // Update BMI on height change
                        ),
                        sizedBox10(),
                        BloodSugarInput(
                          title: 'Waist Circumference',
                          hintText: 'Waist Circumference',
                          controller: waistController,
                          suffixText: 'Cm',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your waist circumference'; // Validation message
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue <= 0) {
                              return 'Please enter a valid waist circumference'; // Validation message for invalid number
                            }
                            return null; // Return null if valid
                          },
                        ),
                        sizedBox10(),
                        BloodSugarInput(
                          title: 'Hip Circumference',
                          hintText: 'Hip Circumference',
                          suffixText: 'Cm',
                          controller: hipController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your hip circumference'; // Validation message
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue <= 0) {
                              return 'Please enter a valid hip circumference'; // Validation message for invalid number
                            }
                            return null; // Return null if valid
                          },
                        ),
                        sizedBox10(),
                        BloodSugarInput(
                          title: 'BMI',
                          hintText: 'BMI',
                          controller: bMIController,
                          suffixText: 'KG/M2',
                          readOnly: true, // Make BMI field read-only
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your BMI'; // Validation message
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue <= 0) {
                              return 'Please enter a valid BMI'; // Validation message for invalid number
                            }
                            return null; // Return null if valid
                          },
                        ),
                        sizedBox10(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     Radio<String>(
                        //       value: "Months",
                        //       groupValue: durationType,
                        //       onChanged: (value) => _toggleDurationType(value!),
                        //     ),
                        //     Text("Months", style: openSansRegular),
                        //     Radio<String>(
                        //       value: "Years",
                        //       groupValue: durationType,
                        //       onChanged: (value) => _toggleDurationType(value!),
                        //     ),
                        //     Text("Years", style: openSansRegular),
                        //   ],
                        // ),
                        // sizedBox10(),
                        Text("Duration of Diabetes", style: openSansRegular),
                        // Duration of Diabetes Input
                        BloodSugarInput(
                          isDouble: true,
                          titleSecond: '',
                          hintTextSecond: 'Months',

                          controllerSecond: monthController,
                          suffixTextSecond: "Month",
                          validatorSecond: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the duration of diabetes';
                            }
                            final numericValue = double.tryParse(value);
                            if (numericValue == null || numericValue < 0) {
                              return 'Please enter a valid duration';
                            }
                            return null;
                          },
                          title: '', hintText: 'Year',
                          controller: yearController,
                          suffixText: "Year",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the years';
                            }
                            final numericValue = int.tryParse(value);
                            if (numericValue == null || numericValue < 0) {
                              return 'Please enter a valid number of years';
                            }
                            return null;
                          },
                        ),
                        sizedBox10(),
                        BloodSugarInput(
                          inputType: TextInputType.text,
                          title: 'Any Other Health Condition / Co-Morbidities',
                          hintText: 'Any Other Health Condition / Co-Morbidities',
                          controller: otherHealthController,
                          suffixText: '',
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your waist circumference'; // Validation message
                          //   }
                          //   final numericValue = double.tryParse(value);
                          //   if (numericValue == null || numericValue <= 0) {
                          //     return 'Please enter a valid waist circumference'; // Validation message for invalid number
                          //   }
                          //   return null; // Return null if valid
                          // },
                        ),

                        sizedBox30(),
                        controller.isDailySugarCheckupLoading
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
                                    debugPrint('Save button clicked==> ${widget.patientId}');
                                    controller.addHealthApi(
                                      widget.patientId,
                                      heightController.text,
                                      weightController.text,
                                      waistController.text,
                                      hipController.text,
                                     yearController.text,
                                      monthController.text,
                                      otherHealthController.text,
                                    ).then((value){
                                      Get.find<DiabeticController>().getSubscribedPatientDataApi();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

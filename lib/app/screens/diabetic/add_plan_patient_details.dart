import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_dropdown_field.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/app/widget/group_radio_button.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/data/models/response/add_patient_model.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

import '../../../controller/auth_controller.dart';

class AddPlanPatientDetails extends StatelessWidget {
  final String? planId;

  AddPlanPatientDetails({super.key, required this.planId});

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _otherProblemController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getPatientList();
      Get.find<AppointmentController>().togglePlanNewPatientSelection(false);
    });

    return Form(
        key: _formKey,
        child: GetBuilder<AppointmentController>(builder: (appointmentControl) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Diabetic Clinic',
              isBackButtonExist: true,
            ),
            bottomNavigationBar: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: !appointmentControl.isLoading
                      ? CustomButtonWidget(
                          isBold: false,
                          fontSize: Dimensions.fontSize14,
                          buttonText: appointmentControl.isPlanNewPatientEnabled
                              ? 'Add Patient'
                              : 'Next',
                          onPressed: () {
                            if(!(Get.find<AuthController>()
                                .isGuestMain)){
                              if (appointmentControl.isPlanNewPatientEnabled) {
                                if (_formKey.currentState!.validate()) {
                                  print(
                                      'Print _firstnameController  ${_firstnameController.text}');
                                  print(
                                      'Print _lastnameController  ${_lastnameController.text}');
                                  print(
                                      'Print _phoneController  ${_phoneController.text}');
                                  print(
                                      'Print selectedGender  ${appointmentControl.getGenderStatus()}');
                                  print(
                                      'Print _dateController  ${_dateController.text}');
                                  print(
                                      'Print getDiabetesStatus  ${appointmentControl.getDiabetesStatus()}');
                                  print(
                                      'Print selectedBp  ${appointmentControl.getBpStatus()}');
                                  print(
                                      'Print selectedGlasses  ${appointmentControl.getGlassesStatus()}');
                                  print(
                                      'Print _otherProblemController  ${_otherProblemController.text}');
                                  print(
                                      'Print selectedPatientId  ${appointmentControl.selectedPatientId.value.toString()}');
                                  print(
                                      'print bool ${appointmentControl.bookingDiabeticType}');

                                  AddPatientModel addPatientModel =
                                      AddPatientModel(
                                    firstName: _firstnameController.text,
                                    lastName: _lastnameController.text,
                                    mobileNo: _phoneController.text,
                                    gender:
                                        appointmentControl.getGenderStatus(),
                                    dob: _dateController.text,
                                    diabetesProblem:
                                        appointmentControl.getDiabetesStatus(),
                                    bpProblem: appointmentControl.getBpStatus(),
                                    eyeProblem:
                                        appointmentControl.getGlassesStatus(),
                                    initial: appointmentControl.selectedInitial,
                                  );
                                  appointmentControl
                                      .addPatientApi(addPatientModel);
                                }
                              } else {
                                Get.toNamed(RouteHelper.getPlanPaymentRoute(
                                    appointmentControl.selectedPatientId.value
                                        .toString(),
                                    planId));
                                // appointmentControl.purchasePlanApi(appointmentControl.selectedPatientId.value.toString(),
                                //     planId, planId)

                                // Get.toNamed(RouteHelper.getDiabeticDashboardRoute());
                              }
                            } else {
                              Get.defaultDialog(
                                title: "Login Required",
                                middleText: "You need to login to book an appointment.",
                                textConfirm: "Login Now",
                                textCancel: "Cancel",
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  Get.back(); // Close the dialog
                                  Get.toNamed(RouteHelper.getLoginRoute()); // Navigate to login screen
                                },
                                onCancel: () {
                                  Get.back(); // Just close the dialog
                                },
                              );
                            }
                          },
                        )
                      : const Center(child: CircularProgressIndicator())),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Patient To Purchase Plan For',
                      style: openSansRegular.copyWith(
                          color: Theme.of(context)
                              .disabledColor
                              .withOpacity(0.60)),
                    ),
                    !appointmentControl.isPlanNewPatientEnabled
                        ? (appointmentControl.patientList ?? []).isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : Obx(() {
                                final patients =
                                    appointmentControl.patientList ?? [];

                                // Set the default selected patient to the first one if no patient is selected yet
                                if (patients.isNotEmpty &&
                                    appointmentControl
                                        .selectedPatient.value.isEmpty) {
                                  final firstPatient = patients.first;
                                  appointmentControl.selectPatient(
                                      firstPatient.id!,
                                      '${firstPatient.firstName} ${firstPatient.lastName}');
                                }

                                return CustomRadioButton(
                                  items: patients.map((patient) {
                                    return '${patient.firstName} ${patient.lastName}';
                                  }).toList(),
                                  selectedValue:
                                      appointmentControl.selectedPatient.value,
                                  // Unwrap RxString
                                  onChanged: (value) {
                                    // Find the selected patient based on the selected name
                                    final selectedPatient = patients.firstWhere(
                                      (patient) =>
                                          '${patient.firstName} ${patient.lastName}' ==
                                          value!,
                                    );

                                    // Update the selected patient in the controller
                                    appointmentControl.selectPatient(
                                        selectedPatient.id!, value!);

                                    // Print the selected patient ID
                                    print(
                                        'Selected Patient ID: ${appointmentControl.selectedPatientId.value}');
                                  },
                                );
                              })
                        : const SizedBox(),
                    TextButton(
                      onPressed: () {
                        appointmentControl.togglePlanNewPatientSelection();
                      },
                      child: Text(
                        appointmentControl.isPlanNewPatientEnabled
                            ? 'Pick From Existing'
                            : '+ Add New',
                        style: openSansSemiBold.copyWith(
                          fontSize: Dimensions.fontSize14,
                          color: Theme.of(context).disabledColor, // Text color
                        ),
                      ),
                    ),
                    !appointmentControl.isPlanNewPatientEnabled
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sizedBox10(),
                              CustomTextField(
                                showTitle: true,
                                capitalization: TextCapitalization.words,
                                validation: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your First Name';
                                  } else if (RegExp(r'[^\p{L}\s]',
                                          unicode: true)
                                      .hasMatch(value)) {
                                    return 'Full name must not contain special characters';
                                  }
                                  return null;
                                },
                                controller: _firstnameController,
                                hintText: 'FIRST NAME',
                              ),
                              sizedBox10(),
                              CustomTextField(
                                showTitle: true,
                                capitalization: TextCapitalization.words,
                                validation: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Last Name';
                                  } else if (RegExp(r'[^\p{L}\s]',
                                          unicode: true)
                                      .hasMatch(value)) {
                                    return 'Full name must not contain special characters';
                                  }
                                  return null;
                                },
                                controller: _lastnameController,
                                hintText: 'LAST NAME',
                              ),
                              sizedBox10(),
                              CustomDropdownField(
                                hintText: 'PATIENT GENDER',
                                selectedValue:
                                    appointmentControl.selectedGender.isEmpty
                                        ? null
                                        : appointmentControl.selectedGender,
                                options: appointmentControl.genderOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    appointmentControl.updateGender(
                                        newValue); // Update controller
                                  }
                                },
                                showTitle: true, // Set to true to show title
                              ),
                              sizedBox10(),
                              const Text(
                                'ENTER PHONE',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                maxLength: 10,
                                isNumber: true,
                                inputType: TextInputType.number,
                                controller: _phoneController,
                                hintText: "ENTER PHONE",
                                validation: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Phone No';
                                  } else if (!RegExp(r'^\d{10}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid 10-digit Phone No';
                                  }
                                  return null;
                                },
                              ),
                              sizedBox10(),
                              const Text(
                                'PATIENT DOB',
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () async {
                                  DateTime initialDate =
                                      appointmentControl.selectedDobDate ??
                                          DateTime.now();
                                  DateTime lastDate = DateTime(2018);
                                  if (initialDate.isAfter(lastDate)) {
                                    initialDate = lastDate;
                                  }
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: DateTime(1900), // Minimum date
                                    lastDate:
                                        lastDate, // Prevents future date selection
                                  );
                                  if (pickedDate != null &&
                                      pickedDate.isBefore(DateTime.now())) {
                                    appointmentControl
                                        .updateDobDate(pickedDate);
                                    _dateController.text = appointmentControl
                                        .formattedDobDate
                                        .toString();
                                  } else {
                                    _dateController.clear();
                                  }
                                },
                                validation: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a date of birth.';
                                  }
                                  DateTime selectedDate = DateTime.parse(value);
                                  if (selectedDate.isAfter(DateTime.now())) {
                                    return 'Date of birth cannot be in the future.';
                                  }
                                  return null;
                                },
                                hintText: 'PATIENT DOB',
                                isCalenderIcon: true,
                                // editText: true,
                              ),
                              sizedBox10(),
                              sizedBox10(),
                              CustomDropdownField(
                                hintText: 'Do you have diabetes?',
                                selectedValue:
                                    appointmentControl.selectedDiabetes.isEmpty
                                        ? null
                                        : appointmentControl.selectedDiabetes,
                                options: appointmentControl.diabetesOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    appointmentControl.updateDiabetes(newValue);
                                    print(appointmentControl.selectedDiabetes);
                                  }
                                },
                                showTitle: true, // Set to true to show title
                              ),
                              sizedBox10(),
                              CustomDropdownField(
                                hintText: 'Do you wear glasses?',
                                selectedValue:
                                    appointmentControl.selectedGlasses.isEmpty
                                        ? null
                                        : appointmentControl.selectedGlasses,
                                options: appointmentControl.glassesOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    appointmentControl.updateGlasses(newValue);
                                    print(appointmentControl.selectedGlasses);
                                  }
                                },
                                showTitle: true,
                              ),
                              sizedBox10(),
                              CustomDropdownField(
                                hintText: 'Any Previous Health Issue',
                                selectedValue:
                                    appointmentControl.selectedBp.isEmpty
                                        ? null
                                        : appointmentControl.selectedBp,
                                options: appointmentControl.bpOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    appointmentControl.updateHealth(newValue);
                                    print(appointmentControl.selectedBp);
                                  }
                                },
                                showTitle: true,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}

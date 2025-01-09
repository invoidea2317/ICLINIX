import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/appointment/components/select_slot_card.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/profile_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/styles.dart';
import '../../../data/models/response/clinic_model.dart';
import '../../../data/models/response/search_model.dart';
import 'components/select_slot_time_component.dart';

class SelectSlotScreen extends StatelessWidget {
  final String? branchImg;
  final String? branchName;
  final String? branchContactNo;
  final String? clinicId;

  SelectSlotScreen({
    super.key,
    required this.branchImg,
    required this.branchName,
    required this.branchContactNo,
    required this.clinicId,
  });

  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getAppointmentSlotsApi(clinicId!,
          Get.find<AppointmentController>().formattedDate.toString());
    });
    return GetBuilder<AppointmentController>(builder: (appointmentControl) {
      _dateController.text = appointmentControl.formattedDate!;
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Appointments Slot',
          isBackButtonExist: true,
        ),
        body: GetBuilder<ProfileController>(builder: (profileControl) {
          return Column(
            children: [
              SelectSlotCard(
                  img: branchImg!,
                  branchName: branchName!,
                  branchContactNo: branchContactNo!),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizedBoxDefault(),
                    const Text(
                      'APPOINTMENT DATE',
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // Current date is the default selected date
                          firstDate: DateTime.now(),  // Current date is selectable
                          lastDate: DateTime(2100),   // Upper limit for date selection
                          selectableDayPredicate: (DateTime date) {
                            // Allow all days except Sundays
                            return date.weekday != DateTime.sunday;
                          },
                        );
                        if (pickedDate != null) {
                          // Update the date in your controller or state management
                          appointmentControl.updateDate(
                            pickedDate,
                            clinicId.toString(),
                          );
                          _dateController.text =
                              appointmentControl.formattedDate.toString(); // Update the text field
                        }
                      },
                      hintText: 'Select',
                      isCalenderIcon: true,
                      editText: true,
                      suffixText: '',
                    ),

                    sizedBox20(),
                    appointmentControl.isSlotLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SelectSlotTimeComponent(),
                    // SizedBox(height: 500,),

                    // CustomButtonWidget(buttonText: 'Continue',
                    //   onPressed: () {
                    //   if(_dateController.text.isNotEmpty && appointmentControl.selectedTime!.isNotEmpty) {
                    //     Get.toNamed(RouteHelper.getAddPatientDetailsRoute(_dateController.text,
                    //         appointmentControl.selectedTime.toString(),
                    //         clinicId
                    //         ));
                    //   } else {
                    //     showCustomSnackBar('Please Add Appointment Date and Time');
                    //   }
                    //   },),
                    sizedBox40(),
                  ],
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
            child: CustomButtonWidget(
              buttonText: 'Proceed to Pay',
              onPressed: () {
                if (_dateController.text.isNotEmpty &&
                    appointmentControl.selectedTime != null &&
                    appointmentControl.selectedTime!.isNotEmpty) {

                  Get.toNamed(RouteHelper.getAddPatientDetailsRoute(
                    _dateController.text,
                    appointmentControl.selectedTime.toString(),
                    clinicId,
                  ));


                } else {
                  showCustomSnackBar('Please Add Appointment Date and Time');
                }
              },
            ),
          ),
        ),
      );
    });
  }
}

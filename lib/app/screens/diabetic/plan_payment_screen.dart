import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/appointment/components/booking_summary_widget.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/data/models/body/appointment_model.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';

import '../../widget/group_radio_button.dart';

class PlanPaymentScreen extends StatelessWidget {
  final String? patientId;
  final String? planId;

  PlanPaymentScreen({super.key, this.patientId, this.planId, });
  final _referralController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(builder: (appointmentControl) {
      return Scaffold(
        appBar:  const CustomAppBar(
            isBackButtonExist: true,
            title: 'Payment Method',
            menuWidget: Row(
              children: [
                NotificationButton(),
              ],
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Code (Optional)',
                  style: openSansRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSize14),
                ),
                sizedBox5(),
                CustomTextField(
                  controller: _referralController,
                  hintText: 'Apply Referral Code',
                ),
                sizedBoxDefault(),
              // CustomDecoratedContainer(
              //   child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Booking Summary',style: openSansMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
              //           color: Theme.of(context).primaryColor),),
              //       // sizedBox10(),
              //       Text('Booking Summary',style: openSansMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
              //           color: Theme.of(context).primaryColor),),
              //
              //
              //     ],
              //   ),
              // ),
              //   sizedBoxDefault(),
                // Obx(() {
                //   return CustomRadioButton(
                //     items: appointmentControl.paymentMethods,
                //     selectedValue: appointmentControl.selectedPaymentMethod.value,
                //     onChanged: (value) {
                //       if (value == 'Razorpay') {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             content: Text('Online payments are currently unavailable.'),
                //           ),
                //         );
                //       } else {
                //         appointmentControl.selectPaymentMethod(value!);
                //       }
                //     },
                //
                //   );
                // }),
                // sizedBoxDefault(),
                // Text('PAY NOW',style: openSansRegular.copyWith(color: Theme.of(context).hintColor,
                //     fontSize: Dimensions.fontSize14),),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SingleChildScrollView(
            child: !appointmentControl.isPurchasePlanLoading ?  CustomButtonWidget(
              buttonText: 'Purchase Plan',
              onPressed: () {
                if(!(Get.find<AuthController>()
                    .isGuestMain)) {
                  appointmentControl.setPlanRenewing(false);
                  appointmentControl.purchasePlanApi(patientId,planId,'razorpay',false);
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
              fontSize: Dimensions.fontSize14,
              isBold: false,
            ) :const Center(child: CircularProgressIndicator())
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/diabetic/components/diabetic_eye_care_plans_component.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import '../../../helper/route_helper.dart';
import '../../widget/custom_drawer_widget.dart';


class DiabeticScreen extends StatelessWidget {
  DiabeticScreen({super.key});
  final GlobalKey<SliderDrawerWidgetState> drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getPlansList();
    });
    return SliderDrawerWidget(
      key: drawerKey,
      drawer: const CustomDrawer(),
      option: SliderDrawerOption(
        backgroundColor: Theme.of(context).primaryColor,
        sliderEffectType: SliderEffectType.Rounded,
        upDownScaleAmount: 30,
        radiusAmount: 30,
        direction: SliderDrawerDirection.LTR,
      ),
      body: Scaffold(
        appBar: CustomAppBar(
          title: 'Diabetic IClinic',
          menuWidget: const Row(
            children: [
              NotificationButton(),
            ],
          ),
            drawerButton : CustomMenuButton(tap: () {
              drawerKey.currentState!.toggleDrawer();
            })
        ),
        body: GetBuilder<AuthController>(builder: (appointControl) {
          return GetBuilder<AppointmentController>(builder: (appointControl) {
          return  SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Appointment',
                      style: openSansBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    sizedBox10(),
                    Image.asset(Images.icDiabeticBanner),
                    sizedBox20(),
                    CustomButtonWidget(
                      useGradient: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xff67D7C3), Color(0xff19BB94)],
                        stops: [0, 1],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      buttonText: 'Book Appointment',
                      onPressed: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Diabetic Clinic currently unavailable.'),
                        //   ),
                        // );
                        appointControl.selectBookingType(true);
                        //debugPrint("value====>"+appointControl.bookingDiabeticType.toString());
                        Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));
                      },
                    ),
                    sizedBox20(),
                    const DiabeticEyeCarePlansComponent(),
                  ],
                ),
              ),
            );
          });
        }),
      ),
    );
  }
}

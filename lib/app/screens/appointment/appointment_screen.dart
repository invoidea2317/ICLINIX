import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/appointment/components/clinic_content_card.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:get/get.dart';
import '../../../utils/sizeboxes.dart';
import '../../widget/custom_drawer_widget.dart';

class AppointmentScreen extends StatelessWidget {
  final bool? isBackButton;

  AppointmentScreen({super.key, this.isBackButton});

  final GlobalKey<SliderDrawerWidgetState> drawerKey = GlobalKey<SliderDrawerWidgetState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ClinicController>().getClinicList();
    });
    return GetBuilder<ClinicController>(builder: (clinicControl) {
      final dataList = clinicControl.clinicList;
      final isLoading = clinicControl.isClinicLoading;
      final isListEmpty = dataList == null || dataList.isEmpty;
      // if (isLoading) {
      //   LoadingDialog.showLoading(message: "Please wait...");
      // } else {
      //   // Dismiss loading dialog when loading is complete
      //   LoadingDialog.hideLoading();
      // }
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
        body: Stack(
          children: [
            Scaffold(
              appBar: CustomAppBar(
                title: isBackButton! ? 'Select Clinic' : 'Schedule Appointment',
                isBackButtonExist: isBackButton!,
                menuWidget: const Row(
                  children: [
                    NotificationButton(),
                  ],
                ),
                drawerButton: CustomMenuButton(tap: () {
                  drawerKey.currentState!.toggleDrawer();
                }),
              ),
              body: isListEmpty && !isLoading
                  ? Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Center(
                  child: EmptyDataWidget(
                    text: 'Nothing Available',
                    image: Images.icEmptyDataHolder,
                    fontColor: Theme.of(context).disabledColor,
                  ),
                ),
              )
                  : ListView.separated(
                itemCount: Get.find<AppointmentController>().bookingDiabeticType?1:(dataList?.length ?? 0),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  bottom: Dimensions.paddingSize100,),
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  return ClinicContentCard(clinicList: dataList![i]);
                },
                separatorBuilder: (BuildContext context, int index) => sizedBoxDefault(),
              ),
            ),

          ],
        ),
      );
    });
  }
}

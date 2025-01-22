import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
class VerticalBannerComponents extends StatefulWidget {
  const VerticalBannerComponents({super.key});

  @override
  State<VerticalBannerComponents> createState() => _VerticalBannerComponentsState();
}

class _VerticalBannerComponentsState extends State<VerticalBannerComponents> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getReferBanner();
      Get.find<AppointmentController>().getisDiscount();
      Get.find<AppointmentController>().getisDiabeticBanner();
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(builder: (controller) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GestureDetector(onTap: () {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text('Refer System Currently Unavailable.'),
            //     ),
            //   );
            // },
            // child: controller.isLoadingRefer?const Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     CircularProgressIndicator(),
            //   ],
            // ):Image.network(controller.referImage)),
            // sizedBoxDefault(),
            // GestureDetector(
            //     onTap: () {
            //   controller.selectBookingType(false);
            //   Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));
            // },
            //     child: controller.isDiscount?const Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         CircularProgressIndicator(),
            //       ],
            //     ):Image.network(controller.discount)),
            // sizedBoxDefault(),
            InkWell(onTap: () {
              controller.selectBookingType(true);
              Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));
            },
                child: controller.isDiabeticBanner?const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ):Image.network(controller.diabeticBanner)),


          ],
        ),
      );
    });



  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';

class NeedForHelpComponent extends StatelessWidget {
  NeedForHelpComponent({super.key});


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ClinicController>().getServicesList();
    });

    return GetBuilder<ClinicController>(
      builder: (clinicController) {
        final dataList = clinicController.servicesList;
        final isListEmpty = dataList == null || dataList.isEmpty;
        final isLoading = clinicController.isServicesLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: SingleChildScrollView( // Add SingleChildScrollView here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Need Help For?',
                //   style: openSansBold.copyWith(
                //     fontSize: Dimensions.fontSizeDefault,
                //   ),
                // ),
                SizedBox(
                  height: 300,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isListEmpty
                      ? Center(
                    child: EmptyDataWidget(
                      text: 'Nothing Available',
                      image: Images.icEmptyDataHolder,
                      fontColor: Theme.of(context).disabledColor,
                    ),
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          print('chck');
                          Get.toNamed(RouteHelper.getServiceDetailRoute(dataList[i].id.toString(), dataList[i].name.toString(),dataList[i].videoUrl));

                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomRoundNetworkImage(
                              image:
                              '${AppConstants.serviceImageUrl}${dataList[i].image.toString()}',
                              height: 80,width: 80,
                            ),
                            sizedBox4(),
                            Text(
                              textAlign: TextAlign.center,
                              dataList[i].name,
                              style: openSansMedium.copyWith(
                                fontSize: Dimensions.fontSize14,
                                color: Theme.of(context).hintColor,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // sizedBox5(),
                CustomButtonWidget(
                  buttonText: 'View All Services',
                  onPressed: () {
                    Get.toNamed(RouteHelper.getAllServicesRoute());
                  },
                  isBold: false,
                  transparent: true,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

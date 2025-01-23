import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/helper/route_helper.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/images.dart';
import '../../../../utils/sizeboxes.dart';
import '../../../../utils/styles.dart';
import '../../../widget/custom_button_widget.dart';
import '../../../widget/custom_image_widget.dart';
import '../../../widget/empty_data_widget.dart';
import '../../diabetic/components/resources_component.dart';

class ViewAllServicesScreen extends StatelessWidget {
  const ViewAllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ClinicController>().getServicesList();
    });
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Services',isBackButtonExist: true,),
      body: GetBuilder<ClinicController>(builder: (clinicController) {
        final dataList = clinicController.servicesList;
        final isListEmpty = dataList == null || dataList.isEmpty;
        final isLoading = clinicController.isServicesLoading;
        return isListEmpty && !isLoading
            ? Padding(
          padding:  const EdgeInsets.only(top: Dimensions.paddingSize100),
          child: Center(
              child: EmptyDataWidget(
                text: 'Nothing Available',
                image: Images.icEmptyDataHolder,
                fontColor: Theme.of(context).disabledColor,
              )),
        )
            : isLoading
            ? const Center(child: CircularProgressIndicator())
            :
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
          child: SizedBox(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                // mainAxisExtent: 170,
                childAspectRatio: 0.8,
              ),
              itemCount: dataList!.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteHelper.getServiceDetailRoute(dataList[i].id.toString(), dataList[i].name.toString(),dataList[i].videoUrl.toString()));
                  },
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRoundNetworkImage(image:'${AppConstants.serviceImageUrl}${dataList[i].image.toString()}',
                        height: 80,width: 80,),
                      sizedBox4(),
                      Text(textAlign: TextAlign.center,
                          dataList[i].name,
                          style: openSansMedium.copyWith(fontSize:Dimensions.fontSize14,
                              color: Theme.of(context).hintColor))
                    ],),
                );
              },),),
        );

      }),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_card_container.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/data/models/response/clinic_model.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iclinix/utils/themes/light_theme.dart';

class ClinicContentCard extends StatelessWidget {
  final ClinicModel clinicList;
  const ClinicContentCard({super.key, required this.clinicList});

  @override
  Widget build(BuildContext context) {
    return CustomCardContainer(
      radius: Dimensions.radius5,
      tap: () {
        Get.toNamed(RouteHelper.getSelectSlotRoute(clinicList.image, clinicList.branchName, clinicList.branchContactNo, clinicList.apiBranchId.toString()));
      },
      child: Column(
        children: [
          CustomNetworkImageWidget(
            height: 200,
            image: clinicList.image,),
          sizedBox4(),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSize10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinicList.branchName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: openSansBold.copyWith(fontSize: Dimensions.fontSize14),
                ),
                sizedBox4(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Branch Contact: ",
                        style: openSansRegular.copyWith(
                            fontSize: Dimensions.fontSize12,
                            color: Theme.of(context).primaryColor), // Different color for "resend"
                      ),
                      TextSpan(
                        text: clinicList.branchContactNo,
                        style: openSansRegular.copyWith(
                            fontSize: Dimensions.fontSize13,
                            color: Theme.of(context)
                                .hintColor), // Different color for "resend"
                      ),
                    ],
                  ),
                ),
                sizedBox4(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row(
                    //   children: [
                    //     Text(
                    //       '4.8',
                    //       style: openSansRegular.copyWith(
                    //           fontSize: Dimensions.fontSize14,
                    //           color: Theme.of(context).hintColor),
                    //     ),
                    //     RatingBar.builder(
                    //       itemSize:  Dimensions.fontSize14,
                    //       initialRating: 4,
                    //       minRating: 1,
                    //       direction: Axis.horizontal,
                    //       allowHalfRating: true,
                    //       itemCount: 5,
                    //       itemBuilder: (context, _) => const Icon(
                    //         Icons.star,
                    //         color: Colors.amber,
                    //         size: Dimensions.fontSize14,
                    //       ),
                    //       onRatingUpdate: (rating) {
                    //         print(rating);
                    //       },
                    //     ),
                    //   ],
                    // ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Open: ",
                              style: openSansRegular.copyWith(
                                  fontSize: Dimensions.fontSize12,
                                  color: greenColor), // Different color for "resend"
                            ),
                            TextSpan(
                              text: "08AM-06PM",
                              style: openSansRegular.copyWith(
                                  fontSize: Dimensions.fontSize13,
                                  color: Theme.of(context)
                                      .hintColor), // Different color for "resend"
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSize12,left: Dimensions.paddingSizeDefault,right: Dimensions.paddingSizeDefault),
            child: CustomButtonWidget(height: 40, buttonText: 'Book Appointment',
              transparent: true,isBold: false,
              fontSize: Dimensions.fontSize14,
              onPressed: () {
                Get.toNamed(RouteHelper.getSelectSlotRoute(clinicList.image, clinicList.branchName, clinicList.branchContactNo, clinicList.apiBranchId.toString()));

              },),
          ),
        ],
      ),
    );;
  }
}

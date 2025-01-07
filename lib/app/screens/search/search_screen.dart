import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_card_container.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

import '../../../data/models/response/search_model.dart';
import '../../../utils/themes/light_theme.dart';
import '../../widget/custom_button_widget.dart';
import '../appointment/select_slot_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ClinicController>().clearSearchList();
    });
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Search',
        isBackButtonExist: true,
      ),
      body: SingleChildScrollView(
        child: GetBuilder<ClinicController>(builder: (clinicControl) {
          final dataList = clinicControl.searchList;
          final dataList2 = clinicControl.serviceDetailsSearchData;
          final isListEmpty =
              (dataList ?? []).isEmpty && (dataList2 ?? []).isEmpty;
          final isLoading = clinicControl.isSearchLoading;
          return Column(
            children: [
              sizedBoxDefault(),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault),
                child: TypeAheadField<SearchModel>(
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: _searchController,
                      focusNode: focusNode,
                      obscureText: false,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          clinicControl.getSearchList(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search for Clinic',
                        border: OutlineInputBorder(),
                      ),
                      // decoration: InputDecoration(
                      //   border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   labelText: 'Password',
                      // ),
                    );
                  },

                  // TextFieldConfiguration(
                  //   controller: _searchController,
                  //   onSubmitted: (value) {
                  //     if (value.isNotEmpty) {
                  //       clinicControl.getSearchList(value);
                  //     }
                  //   },
                  //   decoration: const InputDecoration(
                  //     labelText: 'Search for Clinic',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  // suggestionsCallback: (pattern) async {
                  //   if (pattern.isNotEmpty) {
                  //     // Add a small delay before fetching data to avoid modifying state during build.
                  //     await Future.delayed(Duration(milliseconds: 100));
                  //
                  //     await clinicControl.getSearchList(_searchController
                  //         .text); // Fetch search list from the API
                  //
                  //     // Return the filtered list of clinics
                  //     return clinicControl.searchList!
                  //         .where((item) => item.branchName!
                  //             .toLowerCase()
                  //             .contains(pattern.toLowerCase()))
                  //         .toList();
                  //   }
                  //   return [];
                  // },

                  itemBuilder: (context, SearchModel suggestion) {
                    return ListTile(
                      onTap: () {
                        Get.toNamed(RouteHelper.getSelectSlotRoute(
                            suggestion.image,
                            suggestion.branchName,
                            suggestion.branchContactNo,
                            suggestion.apiBranchId.toString()));

                        // GetPage(
                        //   name: RouteHelper.selectSlot,
                        //   page: () => SelectSlotScreen(model: Get.arguments['model'], isSearchModel: Get.arguments['isSearchModel']),
                        // );
                      },
                      title: Text(
                        suggestion.branchName.toString(),
                        style: openSansRegular,
                      ),
                    );
                  },
                  // onSuggestionSelected: (SearchModel suggestion) {},
                  errorBuilder: (context, error) {
                    return const Center(
                      child: Text('No results found.'),
                    );
                  },
                  // },
                  loadingBuilder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  onSelected: (value) {},
                  suggestionsCallback: (String search) {},
                ),
              ),
              sizedBoxDefault(),
              isListEmpty && !isLoading
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: Dimensions.paddingSize100),
                      child: Center(
                          child: EmptyDataWidget(
                        text: 'Search For Clinic',
                        image: Images.icEmptySearchHolder,
                        fontColor: Theme.of(context).disabledColor,
                      )),
                    )
                  : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            if (dataList != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Row(
                                  children: [
                                    Text("Branches",
                                        style: openSansBold.copyWith(
                                            fontSize: Dimensions.fontSize18)),
                                  ],
                                ),
                              ),
                            if (dataList == null || dataList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.fontSize8),
                                child: Center(
                                    child: EmptyDataWidget(
                                  text: 'No Branches Found',
                                  image: Images.icEmptySearchHolder,
                                  fontColor: Theme.of(context).disabledColor,
                                )),
                              ),
                            if (dataList != null)
                              ListView.separated(
                                itemCount: dataList.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, i) {
                                  return CustomCardContainer(
                                    radius: Dimensions.radius5,
                                    tap: () {
                                      Get.toNamed(
                                          RouteHelper.getSelectSlotRoute(
                                              dataList[i].image,
                                              dataList[i].branchName,
                                              dataList[i].branchContactNo,
                                              dataList[i]
                                                  .apiBranchId
                                                  .toString()));
                                      // GetPage(
                                      //   name: RouteHelper.selectSlot,
                                      //   page: () => SelectSlotScreen(model:dataList[i], isSearchModel: true),
                                      // );
                                      // Get.toNamed(
                                      //   RouteHelper.getSelectSlotRoute(),
                                      //   arguments: dataList[
                                      //       i], // Pass the clinicModel as an argument
                                      // );
                                    },
                                    child: Column(
                                      children: [
                                        // CustomNetworkImageWidget(
                                        //     height: 200,
                                        //     image:
                                        //         '${AppConstants.branchImageUrl}${dataList[i].image.toString()}'),
                                        // sizedBox4(),
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSize10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dataList[i]
                                                    .branchName
                                                    .toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: openSansBold.copyWith(
                                                    fontSize:
                                                        Dimensions.fontSize14),
                                              ),
                                              sizedBox4(),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Branch Contact: ",
                                                      style: openSansRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSize12,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor), // Different color for "resend"
                                                    ),
                                                    TextSpan(
                                                      text: dataList[i]
                                                          .branchContactNo,
                                                      style: openSansRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSize13,
                                                          color: Theme.of(
                                                                  context)
                                                              .hintColor), // Different color for "resend"
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              sizedBox4(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '4.8',
                                                        style: openSansRegular
                                                            .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSize14,
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor),
                                                      ),
                                                      RatingBar.builder(
                                                        itemSize: Dimensions
                                                            .fontSize14,
                                                        initialRating: 4,
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemBuilder:
                                                            (context, _) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: Dimensions
                                                              .fontSize14,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          print(rating);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Flexible(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "Open: ",
                                                            style: openSansRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSize12,
                                                                color:
                                                                    greenColor), // Different color for "resend"
                                                          ),
                                                          TextSpan(
                                                            text: "10AM-7PM",
                                                            style: openSansRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSize13,
                                                                color: Theme.of(
                                                                        context)
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
                                          padding: const EdgeInsets.only(
                                              bottom: Dimensions.paddingSize12,
                                              left:
                                                  Dimensions.paddingSizeDefault,
                                              right: Dimensions
                                                  .paddingSizeDefault),
                                          child: CustomButtonWidget(
                                            height: 40,
                                            buttonText: 'Book Appointment',
                                            transparent: true,
                                            isBold: false,
                                            fontSize: Dimensions.fontSize14,
                                            onPressed: () {
                                              Get.toNamed(RouteHelper
                                                  .getSelectSlotRoute(
                                                      dataList[i].image,
                                                      dataList[i].branchName,
                                                      dataList[i]
                                                          .branchContactNo,
                                                      dataList[i]
                                                          .apiBranchId
                                                          .toString()));

                                              // Get.toNamed(
                                              //   RouteHelper.getSelectSlotRoute(),
                                              //   arguments: dataList[
                                              //       i], // Pass the clinicModel as an argument
                                              // );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        sizedBoxDefault(),
                              ),
                            if (dataList2 != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Row(
                                  children: [
                                    Text("Services",
                                        style: openSansBold.copyWith(
                                            fontSize: Dimensions.fontSize18)),
                                  ],
                                ),
                              ),
                            if (dataList2 == null || dataList2.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.fontSize8),
                                child: Center(
                                    child: EmptyDataWidget(
                                  text: 'No Branches Found',
                                  image: Images.icEmptySearchHolder,
                                  fontColor: Theme.of(context).disabledColor,
                                )),
                              ),
                            if (dataList2 != null)
                              ListView.separated(
                                itemCount: dataList2.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, i) {
                                  return CustomCardContainer(
                                    radius: Dimensions.radius5,
                                    tap: () {
                                      Get.toNamed(
                                          RouteHelper.getServiceDetailRoute(
                                              dataList2[i].id.toString(),
                                              dataList2[i].name.toString()));

                                      // Get.toNamed(RouteHelper.getSelectSlotRoute(
                                      //     dataList2[i].image,
                                      //     dataList2[i].branchName,
                                      //     dataList2[i].branchContactNo,
                                      //     dataList2[i].apiBranchId.toString()));
                                      // GetPage(
                                      //   name: RouteHelper.selectSlot,
                                      //   page: () => SelectSlotScreen(model:dataList[i], isSearchModel: true),
                                      // );
                                      // Get.toNamed(
                                      //   RouteHelper.getSelectSlotRoute(),
                                      //   arguments: dataList[
                                      //       i], // Pass the clinicModel as an argument
                                      // );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // CustomNetworkImageWidget(
                                        //     height: 200,
                                        //     image:
                                        //         '${AppConstants.branchImageUrl}${dataList2[i].image.toString()}'),
                                        // sizedBox4(),
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSize10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                dataList2[i].name.toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: openSansBold.copyWith(
                                                    fontSize:
                                                        Dimensions.fontSize14),
                                              ),
                                              // sizedBox4(),
                                              // RichText(
                                              //   text: TextSpan(
                                              //     children: [
                                              //       TextSpan(
                                              //         text: "Branch Contact: ",
                                              //         style: openSansRegular.copyWith(
                                              //             fontSize:
                                              //                 Dimensions.fontSize12,
                                              //             color: Theme.of(context)
                                              //                 .primaryColor), // Different color for "resend"
                                              //       ),
                                              //       TextSpan(
                                              //         text:
                                              //             dataList[i].branchContactNo,
                                              //         style: openSansRegular.copyWith(
                                              //             fontSize:
                                              //                 Dimensions.fontSize13,
                                              //             color: Theme.of(context)
                                              //                 .hintColor), // Different color for "resend"
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                              // ),
                                              // sizedBox4(),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.spaceBetween,
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Text(
                                              //           '4.8',
                                              //           style:
                                              //               openSansRegular.copyWith(
                                              //                   fontSize: Dimensions
                                              //                       .fontSize14,
                                              //                   color:
                                              //                       Theme.of(context)
                                              //                           .hintColor),
                                              //         ),
                                              //         RatingBar.builder(
                                              //           itemSize:
                                              //               Dimensions.fontSize14,
                                              //           initialRating: 4,
                                              //           minRating: 1,
                                              //           direction: Axis.horizontal,
                                              //           allowHalfRating: true,
                                              //           itemCount: 5,
                                              //           itemBuilder: (context, _) =>
                                              //               const Icon(
                                              //             Icons.star,
                                              //             color: Colors.amber,
                                              //             size: Dimensions.fontSize14,
                                              //           ),
                                              //           onRatingUpdate: (rating) {
                                              //             print(rating);
                                              //           },
                                              //         ),
                                              //       ],
                                              //     ),
                                              //     Flexible(
                                              //       child: RichText(
                                              //         text: TextSpan(
                                              //           children: [
                                              //             TextSpan(
                                              //               text: "Open: ",
                                              //               style: openSansRegular.copyWith(
                                              //                   fontSize: Dimensions
                                              //                       .fontSize12,
                                              //                   color:
                                              //                       greenColor), // Different color for "resend"
                                              //             ),
                                              //             TextSpan(
                                              //               text: "10AM-7PM",
                                              //               style: openSansRegular.copyWith(
                                              //                   fontSize: Dimensions
                                              //                       .fontSize13,
                                              //                   color: Theme.of(
                                              //                           context)
                                              //                       .hintColor), // Different color for "resend"
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: Dimensions.paddingSize12,
                                              left:
                                                  Dimensions.paddingSizeDefault,
                                              right: Dimensions
                                                  .paddingSizeDefault),
                                          child: CustomButtonWidget(
                                            height: 40,
                                            buttonText: 'Go To Service',
                                            transparent: true,
                                            isBold: false,
                                            fontSize: Dimensions.fontSize14,
                                            onPressed: () {
                                              Get.toNamed(RouteHelper
                                                  .getServiceDetailRoute(
                                                      dataList2[i]
                                                          .id
                                                          .toString(),
                                                      dataList2[i]
                                                          .name
                                                          .toString()));
                                              // Get.toNamed(
                                              // RouteHelper.getSelectSlotRoute(
                                              //     dataList[i].image,
                                              //     dataList[i].branchName,
                                              //     dataList[i].branchContactNo,
                                              //     dataList[i]
                                              //         .apiBranchId
                                              //         .toString()));

                                              // Get.toNamed(
                                              //   RouteHelper.getSelectSlotRoute(),
                                              //   arguments: dataList[
                                              //       i], // Pass the clinicModel as an argument
                                              // );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        sizedBoxDefault(),
                              ),
                            sizedBoxDefault(),
                          ],
                        ),
            ],
          );
        }),
      ),
    );
  }
}

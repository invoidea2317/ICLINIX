import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_card_container.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
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


    final Map<String, List<String>> keywordGroups = {
      'appointment': [
        'book appointment',
        'appointment',
        "a"
        "ap"
        "app"
        "app"
        "appo"
        "appoi"
        "appoin"
        "appoint"
        "appointm"
        "appointme"
        "appointmen"
        'appointments',
        'schedule appointment',
        'doctor appointment',
        'clinic appointment',
        'fix appointment',
        'confirm appointment',
        'appointment booking',
        'reschedule appointment',
        'cancel appointment',
        'next appointment',
        'check appointment',
        'appointment reminder',
        'health appointment',
        'new appointment',
        'appointment request',
        'upcoming appointment',
        'appointment details',
        'appointment time',
        'set appointment',
        'appointment check',
        'online appointment',
        'appointment status',
        'clinic visit',
        'doctor visit',
        'hospital appointment',
        'manage appointment',
        'edit appointment',
        'appointment slot',
        'appointment confirmation',
      ],
      'diabetic': [
        'diabetic',
        'diabetic appointment',
        'sugar check',
        'blood sugar',
        'glucose level',
        'diabetes test',
        'diabetes management',
        'diabetes checkup',
        'diabetic treatment',
        'diabetic health',
        'diabetic care',
        'diabetic clinic',
        'diabetes control',
        'diabetic monitoring',
        'glucose reading',
        'diabetic doctor',
        'diabetes check',
        'insulin check',
        'diabetic advice',
        'sugar monitoring',
        'diabetic specialist',
        'diabetes diet',
        'diabetic lifestyle',
        'diabetes care center',
        'type 1 diabetes',
        'type 2 diabetes',
        'sugar test',
        'diabetes appointment',
        'diabetic program',
        'sugar level check',
      ],
      'newMessages': [
        "complain",
        "ticket",
        "support",
        "support ticket",
        'new message',
        'new messages',
        'start new chat',
        'create new message',
        'new chat',
        'new chats',
        'send new message',
        'start messaging',
        'compose message',
        'write message',
        'draft message',
        'create chat',
        'begin new chat',
        'initiate chat',
        'initiate message',
        'open new chat',
        'start conversation',
        'new conversation',
        'compose chat',
        'write new chat',
        'send first message',
        'begin messaging',
        'draft new chat',
        'create conversation',
        'start fresh chat',
        'new texting',
        'start a message',
        'begin a message',
        'write first message',
        'new interaction',
        'launch chat',
        'initiate conversation',
        'start a text',
        'open fresh chat',
      ],
      'messages': [
        'all messages',
        'message',
        'messages',
        'text message',
        'send message',
        'view messages',
        'check messages',
        'chat',
        'chatting',
        'chat history',
        'chat conversation',
        'inbox',
        'outbox',
        'message inbox',
        'message outbox',
        'send chat',
        'reply to message',
        'reply to chat',
        'message notification',
        'chat notification',
        'chat with clinic',
        'message doctor',
        'chat with doctor',
        'doctor chat',
        'clinic chat',
        'chat app',
        'view chat',
        'open chat',
      ],
    };


    Map<String, dynamic> _triggerActionBasedOnKeyword(String keyword) {
      // debugPrint("KeyWord: $keyword");
      final lowerCaseKeyword = keyword.toLowerCase();

      // Helper function to get the best match from a group
      Map<String, dynamic> getBestMatch(String groupName) {
        final matches = keywordGroups[groupName]!
            .where((k) => lowerCaseKeyword.contains(k))
            .toList();
        return {
          'group': groupName,
          'mostMatched': matches.isNotEmpty ? matches.first : null,
          'allMatches': matches,
          'matchCount': matches.length,
        };
      }

      // Get best matches for each keyword group
      final diabeticMatch = getBestMatch('diabetic');
      final messagesMatch = getBestMatch('messages');
      final newMessagesMatch = getBestMatch('newMessages');
      final appointmentMatch = getBestMatch('appointment');

      // Add a priority check for new messages first
      if (newMessagesMatch['matchCount'] > 0) {
        return {
          'action': 'newMessages',
          'mostMatched': newMessagesMatch['mostMatched'],
        };
      }

      // Sort the results by match count (largest to smallest) after prioritizing newMessages
      List<Map<String, dynamic>> results = [
        diabeticMatch,
        messagesMatch,
        appointmentMatch,
      ];

      // Sort by match count (largest to smallest)
      results.sort((a, b) => b['matchCount'].compareTo(a['matchCount']));

      // Find the best matched group with the highest count
      final bestMatch = results.first;

      // Trigger actions based on the best matched group
      if (bestMatch['group'] == 'appointment') {
        return {
          'action': 'appointment',
          'mostMatched': appointmentMatch['mostMatched'],
        };
      } else if (bestMatch['group'] == 'diabetic') {
        return {
          'action': 'diabetic',
          'mostMatched': diabeticMatch['mostMatched'],
        };
      } else if (bestMatch['group'] == 'messages') {
        return {
          'action': 'messages',
          'mostMatched': messagesMatch['mostMatched'],
        };
      }

      return {}; // Return an empty map if no match is found
    }



    bool _isKeyword(String suggestion) {
     // debugPrint("suggestion: $suggestion");
      return keywordGroups.values.any((group) => group.contains(suggestion.trim().toLowerCase()));
    }

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
          final dataList3 = clinicControl.keywordList;
          final isListEmpty =
              (dataList ?? []).isEmpty && (dataList2 ?? []).isEmpty && (dataList3 ?? []).isEmpty;
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
                      onTap: (){
                        clinicControl.setKeywordList([]);
                        clinicControl.getSearchList("");
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Check if a matching keyword exists
                          bool keywordMatched =  _isKeyword(value);
                          if (!keywordMatched) {
                            List<Map<String,dynamic>> data = [];
                            clinicControl.setKeywordList(data);
                            // If no keyword matches, search in the clinic list
                            clinicControl.getSearchList(value);
                          } else {
                          final values =  _triggerActionBasedOnKeyword(value);
                        //  debugPrint("values==> ${values}");
                          List<Map<String,dynamic>> data = [];
                          data.add(values);
                          clinicControl.setKeywordList(data);
                          }
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
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
                        text: 'Search',
                        image: Images.icEmptySearchHolder,
                        fontColor: Theme.of(context).disabledColor,
                      )),
                    )
                  : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [



                            if (dataList3 != null)
                              ListView.separated(
                                itemCount: dataList3.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, i) {
                                  return CustomCardContainer(
                                    radius: Dimensions.radius5,
                                    tap: () {
                                 if(dataList3[i]['action'] == 'diabetic'){
                                   Get.find<AppointmentController>().selectBookingType(true);
                                   Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));
                                 }

                                 if(dataList3[i]['action'] == 'appointment') {
                                   Get.find<AppointmentController>().selectBookingType(false);
                                   Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));

                                 }
                                 if(dataList3[i]['action'] == 'messages'){
                                   Get.toNamed(RouteHelper.getMessageRoute());

                                 }
                                 if(dataList3[i]['action'] == 'newMessages'){
                                   Get.toNamed(RouteHelper.getChatRoute());
                                 }

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
                                                dataList3[i]['mostMatched'].toString(),
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
                                            buttonText: 'Open',
                                            transparent: true,
                                            isBold: false,
                                            fontSize: Dimensions.fontSize14,
                                            onPressed: () {

                                              if(dataList3[i]['action'] == 'diabetic'){
                                                Get.find<AppointmentController>().selectBookingType(true);
                                                Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));
                                              }

                                              if(dataList3[i]['action'] == 'appointment') {
                                                Get.find<AppointmentController>().selectBookingType(false);
                                                Get.toNamed(RouteHelper.getAllClinicRoute(isBackButton: true));

                                              }
                                              if(dataList3[i]['action'] == 'messages'){
                                                Get.toNamed(RouteHelper.getMessageRoute());

                                              }
                                              if(dataList3[i]['action'] == 'newMessages'){
                                                Get.toNamed(RouteHelper.getChatRoute());
                                              }
                                              // Get.toNamed(RouteHelper
                                              //     .getServiceDetailRoute(
                                              //     dataList2[i]
                                              //         .id
                                              //         .toString(),
                                              //     dataList2[i]
                                              //         .name
                                              //         .toString()));
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


                            // if (dataList != null)
                            //   Padding(
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: Dimensions.paddingSizeDefault),
                            //     child: Row(
                            //       children: [
                            //         Text("Branches",
                            //             style: openSansBold.copyWith(
                            //                 fontSize: Dimensions.fontSize18)),
                            //       ],
                            //     ),
                            //   ),
                            // if (dataList == null || dataList.isEmpty)
                            //   Padding(
                            //     padding: const EdgeInsets.only(
                            //         top: Dimensions.fontSize8),
                            //     child: Center(
                            //         child: EmptyDataWidget(
                            //       text: 'No Branches Found',
                            //       image: Images.icEmptySearchHolder,
                            //       fontColor: Theme.of(context).disabledColor,
                            //     )),
                            //   ),
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
                            // if (dataList2 != null)
                            //   Padding(
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: Dimensions.paddingSizeDefault),
                            //     child: Row(
                            //       children: [
                            //         Text("Services",
                            //             style: openSansBold.copyWith(
                            //                 fontSize: Dimensions.fontSize18)),
                            //       ],
                            //     ),
                            //   ),
                            // if (dataList2 == null || dataList2.isEmpty)
                            //   Padding(
                            //     padding: const EdgeInsets.only(
                            //         top: Dimensions.fontSize8),
                            //     child: Center(
                            //         child: EmptyDataWidget(
                            //       text: 'No Branches Found',
                            //       image: Images.icEmptySearchHolder,
                            //       fontColor: Theme.of(context).disabledColor,
                            //     )),
                            //   ),
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
                                              dataList2[i].name.toString(),dataList2[i].videoUrl.toString()));

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
                                                          .toString(),
                                                  dataList2[i].videoUrl.toString()

                                              ));
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

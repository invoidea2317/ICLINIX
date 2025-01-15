import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/diabetic/components/add_health_goal.dart';
import 'package:iclinix/app/screens/diabetic/components/add_sugar_levels_dialog.dart';
import 'package:iclinix/app/screens/diabetic/components/routine_component.dart';
import 'package:iclinix/app/screens/diabetic/components/sugar_chart.dart';
import 'package:iclinix/app/screens/diabetic/plan_renew_option.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/app/widget/custom_drawer_widget.dart';
import 'package:iclinix/app/widget/custom_dropdown_field.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/data/models/response/diabetic_dashboard_detail_model.dart';
import 'package:iclinix/data/models/response/user_data.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/themes/light_theme.dart';
import '../../widget/custom_snackbar.dart';
import 'components/health_parameter_dialog.dart';
import 'components/horizontalView.dart';
import 'components/resources_component.dart';
import 'diabetic_screen.dart';

class DiabeticDashboard extends StatefulWidget {
  DiabeticDashboard({super.key});

  @override
  State<DiabeticDashboard> createState() => _DiabeticDashboardState();
}

class _DiabeticDashboardState extends State<DiabeticDashboard> {
  final GlobalKey<SliderDrawerWidgetState> drawerKey =
      GlobalKey<SliderDrawerWidgetState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DiabeticController>().getDiabeticDashboard();
    });
  }

  static String calculateTimeLeft(String expirationDate) {
    try {
      final DateTime expiry = DateTime.parse(expirationDate);
      final DateTime now = DateTime.now();

      if (expiry.isBefore(now)) {
        return "Expired";
      }

      final Duration difference = expiry.difference(now);
      final int daysLeft = difference.inDays;

      if (daysLeft > 365) {
        int years = daysLeft ~/ 365;
        return "$years year${years > 1 ? 's' : ''}";
      } else if (daysLeft > 30) {
        int months = daysLeft ~/ 30;
        return "$months month${months > 1 ? 's' : ''}";
      } else {
        return "$daysLeft day${daysLeft > 1 ? 's' : ''}";
      }
    } catch (e) {
      return "Invalid date";
    }
  }

  bool  isExpanded = false;
  bool  bpGraph = false;

  @override
  Widget build(BuildContext context) {
    log(
      "renew==>${Get.find<AppointmentController>().isRenew}",
    );
    log(
      "old==>${Get.find<AppointmentController>().isOld}",
    );
    return SliderDrawerWidget(
      key: drawerKey,
      option: SliderDrawerOption(
        backgroundColor: Theme.of(context).primaryColor,
        sliderEffectType: SliderEffectType.Rounded,
        upDownScaleAmount: 30,
        radiusAmount: 30,
        direction: SliderDrawerDirection.LTR,
      ),
      drawer: const CustomDrawer(),
      body: Scaffold(
          appBar: CustomAppBar(
            title: 'Diabetic',
            iconColor: Theme.of(context).primaryColor,
            drawerButton: CustomMenuButton(tap: () {
              drawerKey.currentState!.toggleDrawer();
            }),
            menuWidget: Row(
              children: [
                PopupMenuButton<String>(
                  icon: Icon(
                    CupertinoIcons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  onSelected: (String value) {
                    print('Selected: $value');
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      onTap: () {
                        Get.dialog(AddSugarLevelsDialog());
                      },
                      value: 'Add Sugar',
                      child: const Text('Add Sugar'),
                    ),
                    PopupMenuItem<String>(
                      onTap: () {
                        Get.dialog(AddSugarLevelsDialog(
                          isBp: true,
                        ));
                      },
                      value: 'Add Bp',
                      child: const Text('Add Bp'),
                    ),
                    PopupMenuItem<String>(
                      onTap: () {
                        Get.dialog(const AddHealthParameterDialog());
                      },
                      value: 'Add Health Data',
                      child: const Text('Add Health Data'),
                    ),
                  ],
                ),
                sizedBoxW15(),
                const NotificationButton()
              ],
            ),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: GetBuilder<DiabeticController>(builder: (diabeticControl) {
              final sugarList = diabeticControl.sugarChartList;
              final bpList = diabeticControl.bpChartList;
              final isListEmpty =( sugarList == null || sugarList.monthlySugarValues.isEmpty) && (bpList== null || bpList.monthlySugarValues.isEmpty);
              final isSugarLoading = diabeticControl.isDailySugarCheckupLoading;
              final planDetails = diabeticControl.planDetails;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Get.find<AppointmentController>().selectBookingType(true);
                      //debugPrint("value====>" +
                      //     Get.find<AppointmentController>()
                      //         .bookingDiabeticType
                      //         .toString());
                      Get.toNamed(
                          RouteHelper.getAllClinicRoute(isBackButton: true));
                    },
                  ),
                  sizedBox10(),
                  Container(
                    width: Get.size.width,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage(Images.icDiabeticBg),
                            fit: BoxFit.cover),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius10)),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  diabeticControl.planDetails != null
                                      ? diabeticControl.planDetails!.planName
                                      .toString()
                                      : "N/A",
                                  style: openSansRegular.copyWith(
                                      color: Theme.of(context).cardColor,
                                      fontSize: Dimensions.fontSizeDefault),
                                ),
                              ),



                              Visibility(
                                visible: () {
                                  final expiredAt = diabeticControl
                                      .subscriptionModel?.expiredAt ??
                                      "${DateTime.now()}";
                                  int daysLeft = 0;

                                  try {
                                    final DateTime expiry =
                                    DateTime.parse(expiredAt);
                                    final DateTime now = DateTime.now();

                                    if (expiry.isAfter(now)) {
                                      daysLeft = expiry.difference(now).inDays;
                                    } else {
                                      daysLeft = 0; // Expired case
                                    }
                                  } catch (e) {
                                    // Handle invalid date
                                    debugPrint("Error parsing expiration date: $e");
                                    daysLeft = 0; // Default fallback
                                  }

                                  return !(daysLeft <= 7);
                                }(),
                                child: IconButton(onPressed: (){
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                }, icon: Icon(Icons.keyboard_arrow_down_rounded),color: Colors.white,),
                              ),


                              Visibility(
                                visible: () {
                                  final expiredAt = diabeticControl
                                      .subscriptionModel?.expiredAt ??
                                      "${DateTime.now()}";
                                  int daysLeft = 0;

                                  try {
                                    final DateTime expiry =
                                    DateTime.parse(expiredAt);
                                    final DateTime now = DateTime.now();

                                    if (expiry.isAfter(now)) {
                                      daysLeft = expiry.difference(now).inDays;
                                    } else {
                                      daysLeft = 0; // Expired case
                                    }
                                  } catch (e) {
                                    // Handle invalid date
                                    debugPrint("Error parsing expiration date: $e");
                                    daysLeft = 0; // Default fallback
                                  }

                                  return daysLeft <= 7;
                                }(),
                                child: ElevatedButton(
                                    onPressed: () {

                                      // debugPrint("${diabeticControl.subscriptionModel?.patientId}");
                                      Get.to(() => PlanPaymentRenewScreen(
                                        patientId: (diabeticControl.subscriptionModel?.patientId ??
                                            "")
                                            .toString(),
                                        planId: ((diabeticControl.planDetails ??
                                            PlanDetailsModel(
                                                planId: 0,
                                                planName: "",
                                                price: 0,
                                                discount: 0,
                                                sellingPrice: 0,
                                                discountType: 0,
                                                duration: 9,
                                                sortDesc: '',
                                                description: '',
                                                tagLine: '',
                                                status: 0,
                                                sortOrder: 0,
                                                createdAt:
                                                DateTime.now(),
                                                updateAt:
                                                DateTime.now(),
                                                planResources: [],
                                                subscription:
                                                SubscriptionModel(
                                                    subscriptionId:
                                                    0,
                                                    subscriptionUniqueId:
                                                    '',
                                                    patientId:
                                                    0,
                                                    userId: 0,
                                                    planId: 0,
                                                    subsHistoryId:
                                                    0,
                                                    status: 0,
                                                    expiredAt:
                                                    '',
                                                    expired: 0,
                                                    createdAt:
                                                    '',
                                                    updatedAt:
                                                    '')))
                                            .planId ??
                                            "")
                                            .toString(),
                                        patientModel: diabeticControl
                                            .planDetails ??
                                            PlanDetailsModel(
                                                planId: 0,
                                                planName: "",
                                                price: 0,
                                                discount: 0,
                                                sellingPrice: 0,
                                                discountType: 0,
                                                duration: 9,
                                                sortDesc: '',
                                                description: '',
                                                tagLine: '',
                                                status: 0,
                                                sortOrder: 0,
                                                createdAt: DateTime.now(),
                                                updateAt: DateTime.now(),
                                                planResources: [],
                                                subscription: SubscriptionModel(
                                                    subscriptionId: 0,
                                                    subscriptionUniqueId: '',
                                                    patientId: 0,
                                                    userId: 0,
                                                    planId: 0,
                                                    subsHistoryId: 0,
                                                    status: 0,
                                                    expiredAt: '',
                                                    expired: 0,
                                                    createdAt: '',
                                                    updatedAt: '')),
                                      ));
                                    },
                                    child: const Text("Renew Plan")),
                              ),

                            ],
                          ),
                          diabeticControl.planDetails != null?Visibility(
                            visible: isExpanded,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "First Name: ",
                                        style: openSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${Get.find<AppointmentController>().patientData.firstName}",
                                        // Provide a fallback value if planDetails is null
                                        style: openSansSemiBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Last Name: ",
                                        style: openSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${Get.find<AppointmentController>().patientData.lastName}",
                                        // Provide a fallback value if planDetails is null
                                        style: TextStyle(
                                            fontSize: Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                            color: yellowColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Diabetic: ",
                                        style: openSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${Get.find<AppointmentController>().patientData.diabetesProblem == 0?"No":"Yes"}",
                                        // Provide a fallback value if planDetails is null
                                        style: TextStyle(
                                            fontSize: Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                            color: yellowColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Eye Problem: ",
                                        style: openSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${Get.find<AppointmentController>().patientData.eyeProblem == 0?"No":"Yes"}",
                                        // Provide a fallback value if planDetails is null
                                        style: TextStyle(
                                            fontSize: Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                            color: yellowColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "BP Problem: ",
                                        style: openSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: yellowColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${Get.find<AppointmentController>().patientData.bloodPressureProblem == 0?"No":"Yes"}",
                                        // Provide a fallback value if planDetails is null
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: yellowColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Your Plan Expires in ",
                                  style: openSansRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: yellowColor,
                                  ),
                                ),
                                TextSpan(
                                  text: diabeticControl.planDetails != null
                                      ? calculateTimeLeft(diabeticControl
                                      .subscriptionModel!
                                      .expiredAt ??
                                      "")
                                      : "N/A",
                                  // Provide a fallback value if planDetails is null
                                  style: openSansSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: yellowColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // sizedBoxDefault(),
                  // Row(
                  //   children: [
                  //     Flexible(
                  //       child: CustomButtonWidget(
                  //         buttonText: 'Blood Sugar Level',
                  //         onPressed: () {
                  //           Get.dialog(AddSugarLevelsDialog());
                  //         },
                  //         isBold: false,
                  //         fontSize: Dimensions.fontSize14,
                  //         transparent: true,
                  //       ),
                  //     ),
                  //     sizedBoxW15(),
                  //     Flexible(
                  //       child: CustomButtonWidget(
                  //         buttonText: 'Health Parameters',
                  //         onPressed: () {
                  //           Get.dialog(AddHealthParameterDialog());
                  //         },
                  //         isBold: false,
                  //         fontSize: Dimensions.fontSize14,
                  //         transparent: true,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // sizedBoxDefault(),

                  // Check for null or empty list

                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                                  SubscriptionModel(
                                      subscriptionId: 0,
                                      subscriptionUniqueId: "",
                                      patientId: 0,
                                      userId: 0,
                                      planId: 0,
                                      subsHistoryId: 0,
                                      status: 0,
                                      expiredAt: "2021-12-19",
                                      expired: 0,
                                      createdAt: "",
                                      updatedAt: ""))
                              .expiredAt ??
                          "") !=
                      "Expired")
                    sizedBoxDefault(),

                    if (!isListEmpty) ...[
                      const Text('Today’s Blood Sugar Parameters',
                          style: openSansSemiBold),
                      sizedBoxDefault(),
                   Row(
                     children: [
                       Expanded(
                         child: CustomDropdownField(
                           selectedValue: bpGraph?"Blood Pressure":"Sugar",
                             hintText: "Select Option", options: ["Sugar","Blood Pressure"], onChanged: (value){
                          if(value == "Blood Pressure"){
                            if(bpList!.monthlySugarValues.isNotEmpty) {
                                    setState(() {
                                      bpGraph = true;
                                    });
                                  } else {
                              showCustomSnackBar("No Data in Blood Pressure", isError: false);
                            }
                                }
                          else {
                            if(sugarList!.monthlySugarValues.isNotEmpty) {
                              setState(() {
                                bpGraph = false;
                              });
                            } else {
                              showCustomSnackBar("No Data in Sugar", isError: false);
                            }


                          }
                         }),
                       ),
                     ],
                   ),
                      sizedBoxDefault(),
                      SugarChart(isBp: bpGraph,),
                      sizedBoxDefault(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.red, // First box color
                              ),
                        SizedBox(width: 10,),
                              Text(bpGraph?"Diastolic":"Fasting Sugar"),
                            ],
                          ),
                          SizedBox(width: 10), // Space between boxes
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.blue, // Second box color
                              ),
                              SizedBox(width: 10,),
                              Text(bpGraph?"Systolic":"Post Meal Sugar"),
                            ],
                          ),
                        ],
                      ),
                      sizedBoxDefault(),
                    ],
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                      SubscriptionModel(
                          subscriptionId: 0,
                          subscriptionUniqueId: "",
                          patientId: 0,
                          userId: 0,
                          planId: 0,
                          subsHistoryId: 0,
                          status: 0,
                          expiredAt: "2024-12-19",
                          expired: 0,
                          createdAt: "",
                          updatedAt: ""))
                      .expiredAt ??
                      "") !=
                      "Expired")
                    sizedBoxDefault(),
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                                  SubscriptionModel(
                                      subscriptionId: 0,
                                      subscriptionUniqueId: "",
                                      patientId: 0,
                                      userId: 0,
                                      planId: 0,
                                      subsHistoryId: 0,
                                      status: 0,
                                      expiredAt: "2024-12-19",
                                      expired: 0,
                                      createdAt: "",
                                      updatedAt: ""))
                              .expiredAt ??
                          "") !=
                      "Expired")
                    // sizedBoxDefault(),
                    HorizontalviewDiabetic(),
                  sizedBoxDefault(),
                    AddHealthGoal(),
                  sizedBoxDefault(),
                  // HorizontalviewDiabetic(),
                  // sizedBoxDefault(),
                  // const RoutineComponent(),
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                      SubscriptionModel(
                          subscriptionId: 0,
                          subscriptionUniqueId: "",
                          patientId: 0,
                          userId: 0,
                          planId: 0,
                          subsHistoryId: 0,
                          status: 0,
                          expiredAt: "2024-12-19",
                          expired: 0,
                          createdAt: "",
                          updatedAt: ""))
                      .expiredAt ??
                      "") !=
                      "Expired")
                    sizedBoxDefault(),
                  // const CurrentMedicationComponent(),
                  // sizedBoxDefault(),
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                      SubscriptionModel(
                          subscriptionId: 0,
                          subscriptionUniqueId: "",
                          patientId: 0,
                          userId: 0,
                          planId: 0,
                          subsHistoryId: 0,
                          status: 0,
                          expiredAt: "2024-12-19",
                          expired: 0,
                          createdAt: "",
                          updatedAt: ""))
                      .expiredAt ??
                      "") !=
                      "Expired")
                    const ResourcesComponent(),
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                      SubscriptionModel(
                          subscriptionId: 0,
                          subscriptionUniqueId: "",
                          patientId: 0,
                          userId: 0,
                          planId: 0,
                          subsHistoryId: 0,
                          status: 0,
                          expiredAt: "2024-12-19",
                          expired: 0,
                          createdAt: "",
                          updatedAt: ""))
                      .expiredAt ??
                      "") !=
                      "Expired")
                    sizedBoxDefault(),
                  if (calculateTimeLeft((diabeticControl.subscriptionModel ??
                      SubscriptionModel(
                          subscriptionId: 0,
                          subscriptionUniqueId: "",
                          patientId: 0,
                          userId: 0,
                          planId: 0,
                          subsHistoryId: 0,
                          status: 0,
                          expiredAt: "2024-12-19",
                          expired: 0,
                          createdAt: "",
                          updatedAt: ""))
                      .expiredAt ??
                      "") ==
                      "Expired")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        EmptyDataWidget(
                          text:
                          'Nothing Available', // Change this text if needed
                          image: Images.icEmptyDataHolder,
                          fontColor: Theme.of(context).disabledColor,
                        ),
                      ],
                    ),
                  sizedBox100(),
                ],
              );
            }),
          ))),
    );
  }
}

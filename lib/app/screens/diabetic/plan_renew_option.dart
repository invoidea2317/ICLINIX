import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/appointment/components/booking_summary_widget.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/data/models/body/appointment_model.dart';
import 'package:iclinix/data/models/response/plans_model.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../data/models/response/diabetic_dashboard_detail_model.dart';
import '../../../data/models/response/patients_model.dart';
import '../../../data/models/response/user_data.dart';
import '../../widget/group_radio_button.dart';
import 'components/diabetic_eye_care_plans_component.dart';



bool isPurchaseDone = false;
class PlanPaymentRenewScreen extends StatefulWidget {
  final String? patientId;
  final String? planId;
  final PlanDetailsModel patientModel;

  PlanPaymentRenewScreen({
    super.key,
    this.patientId,
    this.planId,
    required this.patientModel,
  });

  @override
  State<PlanPaymentRenewScreen> createState() => _PlanPaymentRenewScreenState();
}

class _PlanPaymentRenewScreenState extends State<PlanPaymentRenewScreen> {
  String planId = '';
  String price = '';
  String name = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Get.find<AppointmentController>().setPlanRenewingCondition(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getPlansList();

    });
    setState(() {
      planId = widget.planId!;
      price = widget.patientModel.price.toString() ?? "";
      name = widget.patientModel.planName.toString() ?? "";
    });
  }

  final _referralController = TextEditingController();

  static String calculateTimeLeft(String expirationDate) {
 //   debugPrint("Expiration date: $expirationDate");
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(builder: (appointmentControl)
        {
          if(appointmentControl.isPlanRenewingDone){
            appointmentControl.purchasePlanApi(widget.patientId,planId,'cod',true).then((value){
              LoadingDialog.hideLoading();
              Get.back();
            });
          }
      return Scaffold(
        appBar: const CustomAppBar(
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Column(
                    children: [
                      sizedBoxDefault(),
                      Text(
                        'Current Plan Summary',
                        style: openSansMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      sizedBoxDefault(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Plan Name: ',
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSize14),
                            ),
                            Text(
                              widget.patientModel!.planName,
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.fontSize14),
                            ),
                          ],
                        ),
                      ),
                      sizedBoxDefault(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Plan Price: ',
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSize14),
                            ),
                            Text(
                              " Rs. ${widget.patientModel!.price}",
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.fontSize14),
                            ),
                          ],
                        ),
                      ),
                      sizedBoxDefault(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Plan Status: ',
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSize14),
                            ),
                            Text(
                              widget.patientModel.status == 0
                                  ? "Active"
                                  : "Expired",
                              style: openSansRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.fontSize14),
                            ),
                          ],
                        ),
                      ),
                      sizedBoxDefault(),
                    ],
                  ),
                ),
                sizedBoxDefault(),
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

                DiabeticEyeCarePlansComponent(
                  isPlanRenewing: true,
                  onPlanSelected: (plan) {

                    if (plan.planName.isNotEmpty) {
                      setState(() {
                        planId = plan.planId.toString();
                        price = plan.price.toString();
                        name = plan.planName.toString();
                      });

                    } else {
                      setState(() {
                        planId = widget.planId!;
                        price = widget.patientModel.price.toString();
                        name = widget.patientModel.planName.toString();
                      });
                    }
                //    debugPrint("Plan id: $planId");
                  },
                ),
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
                sizedBoxDefault(),

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
              child: !appointmentControl.isPurchasePlanLoading
                  ? CustomButtonWidget(
                      buttonText: 'Purchase Plan',
                      onPressed: () {
                        LoadingDialog.showLoading();
                     //   debugPrint("Plan id: rzorpay");
                        appointmentControl.setPlanRenewing(true);
                        appointmentControl.purchasePlanApi(widget.patientId,planId,'razorpay',true);
                        // razorpayImplement(name, price, planId);
                      },
                      fontSize: Dimensions.fontSize14,
                      isBold: false,
                    )
                  : const Center(child: CircularProgressIndicator())),
        ),
      );
    });
  }
}

Razorpay _razorpay = Razorpay();

void razorpayImplement(String name, String price, String planId,String key,String Currency) async {
  try {
    _razorpay.open({
      'key': key,
      'amount': int.parse((double.parse(price).round()).toString()) * 100,
      // in the smallest currency sub-unit
      'name': name,
      // Generate order_id using Orders API
      "order": {
        "id": planId,
        "entity": 100,
        "amount_paid": 0,
        "amount_due": 0,
        "currency": Currency,
        "receipt": "Receipt #20",
        "status": "created",
        "attempts": 0,
      },
      'description': 'Demo',
      'timeout': 300,
      // in seconds
      'prefill': {'contact': "9971104827", 'email': "yv48184@gmail.com"}
    });
    // Correct event handlers for success, failure, and external wallet
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  } catch (e) {
    //debugPrint('Error====>: ${e.toString()}');
    // _razorpay.clear();
  }
}


void _handlePaymentSuccess(
    PaymentSuccessResponse response,
    )
{
  Map<String, dynamic> requestBody = {
    "paymentId": "${response.paymentId}",
    "historyId": Get.find<AppointmentController>().HistoryId,
    "paymentStatus": "success"
  };
  // debugPrint("requestBody==> $requestBody");
  // debugPrint('EVENT_PAYMENT_SUCCESS: ${response.data}');
  bool? value = Get.find<AppointmentController>().isPlanRenewing;
  //debugPrint("value==> $value");
  Get.find<AppointmentController>().postDataBackPlans(requestBody,Get.find<AppointmentController>().isPlanRenewing);
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Do something when payment fails
  //debugPrint('EVENT_PAYMENT_ERROR: ${response.code} - ${response.message}');
}

void _handleExternalWallet(ExternalWalletResponse response) {
  // Do something when an external wallet was selected
  //debugPrint('EVENT_EXTERNAL_WALLET: ${response.walletName}');
}

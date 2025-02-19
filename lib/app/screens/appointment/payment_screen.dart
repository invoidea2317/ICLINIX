import 'package:flutter/material.dart';
import 'package:iclinix/app/screens/appointment/components/booking_summary_widget.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/appointment_controller.dart';

import 'package:iclinix/data/models/body/appointment_model.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../helper/invoice.dart';
import '../../widget/group_radio_button.dart';

class PaymentScreen extends StatefulWidget {
  final AppointmentModel appointmentModel;

  PaymentScreen({
    super.key,
    required this.appointmentModel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _referralController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().setAmount("");
      Get.find<AppointmentController>().setPromotionalCode(false);
      Get.find<AppointmentController>().bookAppointmentApi(
        widget.appointmentModel,
        Get.find<AppointmentController>().ScheduleType,
        Get.find<AppointmentController>().Scheduleid,
      );
      Get.find<AppointmentController>().setisPaymentSuccessFull(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(builder: (appointmentControl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.find<AppointmentController>().isPaymentSuccessFull!) {
          Get.toNamed(RouteHelper.getBookingSuccessfulRoute(
            widget.appointmentModel.appointmentTime,
            widget.appointmentModel.appointmentDate,
            appointmentControl.apptId,
          ));
        }
      });

      if (Get.find<AppointmentController>().amount.isEmpty) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
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
                BookingSummaryWidget(
                  patientName:
                      '${widget.appointmentModel.firstName}${widget.appointmentModel.lastName}',
                  appointmentDate: '${widget.appointmentModel.appointmentDate}',
                  appointmentTime: '${widget.appointmentModel.appointmentTime}',
                  bookingFee: appointmentControl.amount,
                ),
                sizedBoxDefault(),
                // Obx(() {
                //   return CustomRadioButton(
                //     items: appointmentControl.paymentMethods,
                //     selectedValue: appointmentControl.selectedPaymentMethod.value,
                //     onChanged: (value) {
                //       debugPrint('Selected Payment Method: $value');
                //       if (value == 'Pay via debit/credit card/upi/NetBanking') {
                //         appointmentControl.selectPaymentMethod(value!);
                //       } else {
                //         // Update selected payment method
                //         appointmentControl.selectPaymentMethod(value!);
                //       }
                //
                //     },
                //   );
                // }),

                Row(
                  children: [
                    Text(
                      'Promotional Code (Optional)',
                      style: openSansRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSize14),
                    ),
                    Spacer(),
                    Checkbox(
                        checkColor: Colors.blue,
                        // Tick color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: BorderSide(color: Colors.blue),
                        value: appointmentControl.isPromotionalCode,
                        onChanged: (value) {
                          appointmentControl.setPromotionalCode();
                        })
                  ],
                ),
                sizedBox5(),
                Visibility(
                  visible: appointmentControl.isPromotionalCode!,
                  child: CustomTextField(
                    controller: _referralController,
                    hintText: 'Apply Referral Code',
                  ),
                ),
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
            child: CustomButtonWidget(
              buttonText: 'Pay via Debit card/credit card/UPI/NetBanking',
              onPressed: () {
                razorpayImplement(
                    widget.appointmentModel,
                    appointmentControl.orderId,
                    appointmentControl.amount,
                    appointmentControl.currency,
                    appointmentControl.razorPayKey);
                // razorpayImplement(appointmentModel);

                // if(appointmentControl.selectedPaymentMethod.value == 'Pay via debit/credit card/upi/NetBanking'){
                //   // appointmentControl.bookAppointmentApi(appointmentModel);
                //   // razorpayImplement(appointmentModel);
                //   // appointmentControl.bookAppointmentApi(appointmentModel);
                // }else{
                //   appointmentControl.bookAppointmentApi(appointmentModel);
                // }
              },
              fontSize: Dimensions.fontSize14,
              isBold: false,
            ),
          ),
        ),
      );
    });
  }
}

Razorpay _razorpay = Razorpay();

void razorpayImplement(AppointmentModel appointment, String orderId,
    String amount, String currency, String key) async {
  try {
    _razorpay.open({
      'key': key,
      'amount': int.parse(amount) * 100, // in the smallest currency sub-unit
      'name': appointment.firstName, // Generate order_id using Orders API
      "order": {
        "id": orderId,
        "entity": 100,
        "amount_paid": 0,
        "amount_due": 0,
        "currency": currency,
        "receipt": "Receipt #20",
        "status": "created",
        "attempts": 0,
      },
      // 'description': 'Demo',
      'timeout': 300, // in seconds
      // 'prefill': {'contact': appointment.mobileNo, 'email': "yv48183@gmail.com"}
    });
    // Correct event handlers for success, failure, and external wallet
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  } catch (e) {
    // debugPrint('Error====>: ${e.toString()}');
    // _razorpay.clear();
  }
}

void _handlePaymentSuccess(
  PaymentSuccessResponse response,
) {
  Map<String, dynamic> requestBody = {
    "paymentId": "${response.paymentId}",
    "orderId": Get.find<AppointmentController>().orderId,
    "paymentStatus": "success"
  };
  // debugPrint("requestBody==> $requestBody");
  // debugPrint('EVENT_PAYMENT_SUCCESS: ${response.data}');

  Get.find<AppointmentController>().postDataBack(requestBody);
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Do something when payment fails
 // debugPrint('EVENT_PAYMENT_ERROR: ${response.code} - ${response.message}');
}

void _handleExternalWallet(ExternalWalletResponse response) {
  // Do something when an external wallet was selected
  //debugPrint('EVENT_EXTERNAL_WALLET: ${response.walletName}');
}

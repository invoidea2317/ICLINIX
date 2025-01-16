import 'dart:async';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNo;
  OtpVerificationScreen({super.key, this.phoneNo});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _remainingTime = 60*5;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isResendEnabled = false;
      _remainingTime = 60 * 5; // 5 minutes in seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _resendOtp() {
    if (_isResendEnabled) {
      Get.find<AuthController>().sendOtpApi(widget.phoneNo.toString());
      _startTimer();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: GetBuilder<AuthController>(builder: (authControl) {
        return Form(
          key: _formKey,
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  Images.loginScreenBG,
                  fit: BoxFit.cover,
                ),
              ),
              // Bottom content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ensures content is compact
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Text(
                        'OTP Verification',
                        style: openSansExtraBold.copyWith(
                          fontSize: Dimensions.fontSize32,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                    sizedBox20(),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      width: Get.size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radius20),
                          topRight: Radius.circular(Dimensions.radius20),
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enter OTP',style: openSansBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).disabledColor.withOpacity(0.50) ),),
                          Text("We have sent verification code to you number",style: openSansRegular.copyWith(
                              fontSize: Dimensions.fontSize13,
                              color: Theme.of(context).disabledColor.withOpacity(0.40) ),),
                          sizedBox12(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize25),
                            child: PinCodeTextField(
                              length: 6,
                              appContext: context,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.slide,
                              controller: _otpController,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                fieldHeight: 40,
                                fieldWidth: 40,
                                borderWidth: 1,
                                activeBorderWidth: 1,
                                inactiveBorderWidth: 1,
                                errorBorderWidth: 1,
                                selectedBorderWidth: 1,
                                borderRadius: BorderRadius.circular(Dimensions.radius10),
                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                selectedFillColor: Colors.white,
                                inactiveFillColor: Colors.white,
                                inactiveColor: Theme.of(context).primaryColor,
                                activeColor: Theme.of(context).primaryColor,
                                activeFillColor: Colors.white,
                              ),
                              animationDuration: const Duration(milliseconds: 300),
                              backgroundColor: Colors.transparent,
                              enableActiveFill: true,
                              validator: (value) {
                                if (_otpController.text.length != 6) {
                                  return 'Please enter a valid 6-digit OTP';
                                }
                                return null;
                              },
                              beforeTextPaste: (text) => true,
                            ),
                          ),
                          sizedBox10(),
                          GestureDetector(
                            onTap: _isResendEnabled ? _resendOtp : null,
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "If you didn’t receive a code. ",
                                      style: openSansRegular.copyWith(
                                        fontSize: Dimensions.fontSize12,
                                        color: Theme.of(context).disabledColor.withOpacity(0.40),
                                      ),
                                    ),
                                    TextSpan(
                                      text: _isResendEnabled
                                          ? "Resend"
                                          : "Resend in ${_formatTime(_remainingTime)}",
                                      style: openSansBold.copyWith(
                                        fontSize: Dimensions.fontSize12,
                                        color: _isResendEnabled
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          sizedBox30(),
                          authControl.isLoginLoading ?
                              const Center(child: CircularProgressIndicator()) :
                          CustomButtonWidget(
                            buttonText: "Continue",
                            onPressed: () {
                              if(_formKey.currentState!.validate()) {
                                authControl.verifyOtpApi(widget.phoneNo, _otpController.text);


                              }
                            },
                          ),
                          sizedBox10(),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      })


    );
  }
}

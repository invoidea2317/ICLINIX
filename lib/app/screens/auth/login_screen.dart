import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Form(
        key: _formKey,
        child:
        Stack(
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
                      'Login / Register',
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
                        Text('Enter your Phone Number',style: openSansBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).disabledColor.withOpacity(0.50) ),),
                        Text("You'll get a verification code from us.",style: openSansRegular.copyWith(
                            fontSize: Dimensions.fontSize13,
                            color: Theme.of(context).disabledColor.withOpacity(0.40) ),),
                        sizedBox12(),
                        CustomTextField(
                          maxLength: 10,
                          isNumber: true,
                          inputType: TextInputType.number,
                          controller: _phoneController,
                          isPhone: true,
                          hintText: "Enter your mobile number here",
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Phone No';
                            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit Phone No';
                            }
                            return null;
                          },
                        ),
                        sizedBox12(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Enter as",style: openSansRegular.copyWith(
                                fontSize: Dimensions.fontSize13,
                                color: Theme.of(context).disabledColor.withOpacity(0.40) ),),

                            GetBuilder<AuthController>(
                              builder: (controller) {
                                return GestureDetector(
                                  onTap: (){
                                    controller.sendGuestOtp();
                                  },
                                  child: Text(" Guest?",style: openSansRegular.copyWith(
                                      fontSize: Dimensions.fontSize13,
                                      color: Colors.blue ),),
                                );
                              }
                            ),
                          ],
                        ),
                        // sizedBox10(),
                        // InkWell(
                        //   onTap: () {
                        //     // Get.toNamed(RouteHelper.getLoginRoute());
                        //     Get.toNamed(RouteHelper.getLetsBeginRoute());
                        //   },
                        //   child: RichText(
                        //     text: TextSpan(
                        //       children: [
                        //         TextSpan(
                        //           text: "Already a Member? ",
                        //           style: openSansRegular.copyWith(
                        //             fontSize: Dimensions.fontSize14,
                        //             color: Theme.of(context).disabledColor.withOpacity(0.40),
                        //           ),
                        //         ),
                        //         TextSpan(
                        //           text: "Login",
                        //           style: openSansBold.copyWith(
                        //             fontSize: Dimensions.fontSize14,
                        //             color: Theme.of(context).primaryColor,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        sizedBox30(),
                        GetBuilder<AuthController>(builder: (authControl) {
                          return  authControl.isLoginLoading ?
                          const Center(child: CircularProgressIndicator()) :
                          CustomButtonWidget(
                            buttonText: "Continue",
                            onPressed: () {
                              if(_formKey.currentState!.validate()) {
                                authControl.sendOtpApi(_phoneController.text);
                              }
                            },
                          );
                        }),
                        sizedBox10(),


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

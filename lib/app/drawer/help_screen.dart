import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:get/get.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';


class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBar(
        title: 'Help',
        isBackButtonExist: true,
        bgColor: Theme.of(context).primaryColor,
        iconColor: Theme.of(context).cardColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(Images.icHelpHolder)
                // Other content can go here
                // Example: Padding for spacing
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                height: Get.size.height * 0.5,
                width: Get.size.width,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Dimensions.paddingSizeDefault),
                    topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sizedBoxDefault(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildInkWell(context, tap: () async {
                          const phoneNumber = '9899118030';
                          final Uri phoneUri =
                              Uri(scheme: 'tel', path: phoneNumber);

                          if (await canLaunch(phoneUri.toString())) {
                            await launch(phoneUri.toString());
                          } else {
                            showCustomSnackBar(
                                'Direct Call Unavailable at this moment');
                          }
                        }, icon: CupertinoIcons.phone_solid),
                        sizedBoxW15(),
                        buildInkWell(context, tap: () async {
                          _launchURL();
                        }, icon: CupertinoIcons.mail_solid),
                        // buildInkWell(context, tap: () {}, icon: CupertinoIcons.phone_solid)
                      ],
                    ),
                    sizedBox30(),
                    Text(
                      'Contact Information',
                      style: openSansBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSize28,
                      ),
                    ),
                    sizedBox10(),
                    buildRichText(context,
                        title: 'Website: ', data: 'https://iclinix.in/'),
                    sizedBox10(),
                    buildRichText(context,
                        title: 'Mail: ', data: 'iclinix@gmail.com'),
                    sizedBox10(),
                    buildRichText(context,
                        title: 'Contact No: ', data: '+91-9899118030'),
                    sizedBox10(),
                    // buildRichText(context,
                    //     title: 'Website ', data: 'https://iclinix.in/'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'iclinix@gmail.com',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  InkWell buildInkWell(BuildContext context,
      {required VoidCallback tap, required IconData icon}) {
    return InkWell(
      onTap: tap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  RichText buildRichText(
    BuildContext context, {
    required String title,
    required String data,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: openSansRegular.copyWith(
              fontSize: Dimensions.fontSize14,
              color: Theme.of(context).disabledColor.withOpacity(0.80),
            ),
          ),
          TextSpan(
            text: data,
            style: openSansBold.copyWith(
              fontSize: Dimensions.fontSize14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

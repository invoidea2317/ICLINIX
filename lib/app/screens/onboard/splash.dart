import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _route();
    super.initState();
  }

  void _route() {
    final AuthController authController = Get.find<AuthController>();
    Timer(const Duration(seconds: 1), () async {
      await Get.find<AuthController>().isLoggedIn().then((value){
        //debugPrint("isTokenAvailable: $value");
        if (value ?? false) {
          Get.offNamed(RouteHelper.getDashboardRoute());
        } else {
          Get.offNamed(RouteHelper.getLoginRoute());
        }
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(height: Get.size.height,
        width: Get.size.width,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          // color: Colors.white,
          image: DecorationImage(image: AssetImage(Images.splashScreenBG),fit: BoxFit.cover)
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSize50),
          child: Image.asset(Images.logo,height: 140,width: 100,),
        ),
      ),
    );
  }
}

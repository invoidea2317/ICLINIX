import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';
import 'package:iclinix/data/models/response/user_data.dart';
import 'package:iclinix/data/repo/auth_repo.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../app/screens/privacy/privacy_policy.dart';
import '../app/widget/loading_widget.dart';
import '../helper/date_converter.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final SharedPreferences sharedPreferences;
  AuthController({required this.authRepo,required this.sharedPreferences, }) ;

  Future<bool> isLoggedIn() async {
    bool value = await  authRepo.isLoggedIn();
    return value;
  }
  DateTime? selectedDate;
  String? formattedDate;
  String? privacyPolicy;

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    formattedDate = SimpleDateConverter.formatDateToCustomFormat(selectedDate!);
    update();
  }

  var selectedGender = 'Male'; // Observable for selected gender
  final List<String> genderOptions = ['Male', 'Female',]; // List of options

  void updateGender(String gender) {
    selectedGender = gender; // Update selected gender
    update(); // Call update to refresh listeners (not using Obx)
  }

  var selectedDiabetes = 'No';
  final List<String> diabetesOptions = ['No','Yes']; // List of options

  void updateDiabetes(String val) {
    selectedDiabetes = val;
    update();
  }

  var selectedGlasses = 'No';
  final List<String> glassesOptions = ['No','Yes'];
  void updateGlasses(String val) {
    selectedGlasses = val;
    update();
  }

  var selectedBp= 'No';
  final List<String> bpOptions = ['No','Yes'];

  void updateHealth(String val) {
    selectedBp = val;
    update();
  }


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? lastBackPressTime;
  Future<bool> handleOnWillPop() async {
    final now = DateTime.now();

    if (lastBackPressTime == null || now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      updateLastBackPressTime(now);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      SystemNavigator.pop();
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> getPrivacyPolicy(String value) async {

    _isLoginLoading = true;
    update();
    Response response = await authRepo.getPrivacyPolicy(value);

    final Map<String, dynamic> data = response.body['data'] as Map<String, dynamic>;    log(data.toString(),name: "Privacy Policy");

      privacyPolicy = data['content'].toString();
      if(value == "1") {
      Get.to(() => PrivacyPolicy(
            privacyPolicy: privacyPolicy ?? "",
            title: "Privacy Policy",
          ));
    } else {
        Get.to(() => PrivacyPolicy(
          privacyPolicy: privacyPolicy ?? "",
          title: "Terms & Condition",
        ));
      }
    _isLoginLoading = false;
    update();
  }



  void updateLastBackPressTime(DateTime time) {
    lastBackPressTime = time;
    update();
  }

  ///################ Apis ########################


  bool _isLoginLoading = false;
  bool get isLoginLoading => _isLoginLoading;

 bool _isShowingBottomBar = true;
  bool get isShowingBottomBar => _isShowingBottomBar;


  void updateBottomBarVisibility(bool isVisible) {
    _isShowingBottomBar = isVisible;
    //debugPrint('Bottom bar visibility: $isVisible');
    update();
  }
  Future<void> sendOtpApi(String? phoneNo) async {
    _isLoginLoading = true;
    update();
    Response response = await authRepo.sendOtpRepo(phoneNo);
    if (response.statusCode == 200) {
      var responseData = response.body;
      if (responseData["message"].contains("OTP sent to your mobile number")) {
        String otp = responseData['otp'].toString();
        _isLoginLoading = false;
        update();
        // showCustomSnackBar(responseData['message'], isError: false);
        Get.toNamed(RouteHelper.getOtpVerificationRoute(phoneNo));
      } else {
        _isLoginLoading = false;
        update();
        return showCustomSnackBar(responseData['message'], isError: true);
      }
    } else {
      _isLoginLoading = false;
      update();
      print('Failed to send OTP');
    }
    _isLoginLoading = false;
    update();
  }

  Future<void> saveSubscriptionStatus(bool isActive) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSubscriptionActive', isActive);
  }


  Future<bool> getSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSubscriptionActive') ?? false;
  }

  Future<void> verifyOtpApi(String? phoneNo, String? otp) async {
    if (phoneNo == null || otp == null) {
      showCustomSnackBar('Phone number and OTP cannot be null', isError: true);
      return;
    }

    _isLoginLoading = true;
    update();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? deviceToken = await prefs.getString('FCM');
    //debugPrint('Device token: $deviceToken');
    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lab5.invoidea.in/iclinix/public/api/verify-otp'),
      );

      // Add fields to the request
      request.fields.addAll({
        'mobile': "+91${phoneNo}",
        'otp': otp,
        "device_token": deviceToken ?? "",
      });
      //debugPrint('Device token: ${request.fields}');
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseString = await response.stream.bytesToString();
        var responseData = json.decode(responseString);
        if (responseData.containsKey('token')) {
          authRepo.saveUserToken(responseData['token']);
          print('Token saved: ${responseData['token']}');
          var user = responseData['user'];
          var subscription = responseData['subscription'];
          // Save subscription status in SharedPreferences
          bool isSubscriptionActive = false;
          if (subscription is Map<String, dynamic> && subscription['status'] == 'active') {
            isSubscriptionActive = true;
          }
          await saveSubscriptionStatus(isSubscriptionActive);
          // Navigate based on the user's first name
          if (user != null) {
            if (user.containsKey('first_name') && user['first_name'] != null && user['first_name'].isNotEmpty) {
              Get.toNamed(RouteHelper.getDashboardRoute());
            } else {
              Get.toNamed(RouteHelper.getLetsBeginRoute());
            }
          }
          showCustomSnackBar('Verified Successfully', isError: false);
        } else {
          showCustomSnackBar('Token not found in response', isError: true);
        }
      } else {
        print(response.reasonPhrase);
        showCustomSnackBar('Error: ${response.reasonPhrase}', isError: true);
      }
    } catch (e) {
      print('Error occurred: $e');
      showCustomSnackBar('An error occurred while verifying OTP', isError: true);
    } finally {
      _isLoginLoading = false;
      update();
    }
  }


  bool _userDataLoading = false;
  bool get userDataLoading => _userDataLoading;


  UserData? _userData;
  PatientData? _patientData;

  UserData? get userData => _userData;
  PatientData? get patientData => _patientData;

  Future<ApiResponse?> userDataApi() async {
    // LoadingDialog.showLoading(message: "Please wait...");
    _userDataLoading = true;
    _userData = null;
    _patientData = null;
    update();
    Response response = await authRepo.getUserData();
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = response.body;
      ApiResponse apiResponse = ApiResponse.fromJson(responseData);
      _userData = apiResponse.userData;
      _patientData = apiResponse.patientData;
      bool isSubscriptionActive = (responseData['subscriptionArray']['status'] ??false) as bool;
      debugPrint("Subscription status: ${responseData['subscriptionArray']['status']}");
      await saveSubscriptionStatus(isSubscriptionActive);
    } else {

    }
    _userDataLoading = false;
    // LoadingDialog.hideLoading();
    update();
    return ApiResponse(userData: _userData, patientData: _patientData); // Return the combined response
  }


}
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/screens/dashboard/dashboard_screen.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';
import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/models/response/diabetic_dashboard_detail_model.dart';
import 'package:iclinix/data/models/response/health_goal_model.dart';
import 'package:iclinix/data/models/response/patient_data_model.dart';
import 'package:iclinix/data/models/response/patients_model.dart';
import 'package:iclinix/data/models/response/sugar_checkup_model.dart';
import 'package:iclinix/data/repo/diabetic_repo.dart';
import 'package:iclinix/helper/date_converter.dart';
import 'package:iclinix/helper/route_helper.dart';

import '../data/models/response/user_data.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';



class DiabeticController extends GetxController implements GetxService {
  final DiabeticRepo diabeticRepo;
  final ApiClient apiClient;

  DiabeticController({required this.diabeticRepo, required this.apiClient});

  bool _isHba1c = false;
  bool get isHba1c => _isHba1c;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  @override
  void onInit() {
    super.onInit();
    formattedDate = SimpleDateConverter.formatDateToCustomFormat(selectedDate);
    formattedTime = SimpleTimeConverter.formatTimeToCustomFormat(bpSelectedTime);
    generateUniqueSugarCheckOptions();
  }


  DateTime selectedDate = DateTime.now(); // Default to current date
  String? formattedDate;



  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    formattedDate = SimpleDateConverter.formatDateToCustomFormat(selectedDate);
    update(); // Trigger GetX update to refresh UI if necessary
  }
  void updateIsHba1c(bool value) {
    _isHba1c = value;
    update(); // Trigger GetX update to refresh UI if necessary
  }

  DateTime bpSelectedTime = DateTime.now(); // Default to current time
  String? formattedTime;



  void updateTime(DateTime newTime) {
    bpSelectedTime = newTime;
    formattedTime = SimpleTimeConverter.formatTimeToCustomFormat(bpSelectedTime);
    update(); // Trigger GetX update to refresh UI if necessary
  }

  void updateTimeOfDay(TimeOfDay newTimeOfDay) {
    final now = DateTime.now();
    // Convert TimeOfDay to DateTime by using the current date
    bpSelectedTime = DateTime(now.year, now.month, now.day, newTimeOfDay.hour, newTimeOfDay.minute);
    formattedTime = SimpleTimeConverter.formatTimeToCustomFormat(bpSelectedTime);
    update(); // Trigger GetX update to refresh UI if necessary
  }
  String selectedValue = '';

  bool showHistory = false;

  void toggleShowHistory(bool value) {
    showHistory = value;
    update();
  }

  var isHealthDataTabActive = true.obs; // Default to Health Data Tab
  void toggleTab(bool isHealthData) {
    isHealthDataTabActive.value = isHealthData;
  }
  var selectedSugarCheck = '';  // Initialize as an empty string
  final List<String> sugarCheckOptions = ['Post Breakfast', 'Post Lunch', 'Post Dinner', 'Bedtime'];
  late List<String> uniqueSugarCheckOptions = [];  // Initialize as empty list

// This will map string values to corresponding numeric values
  final Map<String, int> sugarCheckMapping = {
    'Post Breakfast': 1,
    'Post Lunch': 2,
    'Post Dinner': 3,
    'Bedtime': 4,
  };

  int selectedSugarCheckValue = 0; // Initialize numeric variable for the selected value

  void generateUniqueSugarCheckOptions() {
    uniqueSugarCheckOptions = sugarCheckOptions.toSet().toList();  // Remove duplicates
  }

  void updateSugarCheck(String val) {
    selectedSugarCheck = val;
    selectedSugarCheckValue = sugarCheckMapping[val] ?? 0;  // Convert to numeric value
    update();  // Use GetX to update state
  }

  var hbA1cPercentage = 5.7.obs;

  String? selectedTime;
  List<String> timeSlot = [
    '12:30',
    '1:00',
    '2:00',
    '3:00',
    '4:00',
    '5:00',
    '6:00',
    '7:00',
    '8:00',
  ];

  void selectTimeSlot(int index) {
    selectedTime = timeSlot[index];
    print("Selected Time: $selectedTime");
    update(); // Update the state
  }

  var selectedInitial = 'Mr';
  var selectedGender = 'Male';
  final List<String> genderOptions = ['Male', 'Female'];

  String getGenderStatus() {
    return '${selectedGender == 'Male' ? 'M' : 'F'}';
  }

  void updateGender(String gender) {
    selectedGender = gender;
    selectedInitial = (selectedGender == 'Male') ? 'Mr' : 'Mrs';
    update();
  }

  DateTime? selectedDobDate;
  String? formattedDobDate;

  void updateDobDate(DateTime newDate) {
    selectedDobDate = newDate;
    formattedDobDate = SimpleDateConverter.formatDateToCustomFormat(selectedDobDate!);
    update();
  }

  var selectedDiabetes = 'No';
  final List<String> diabetesOptions = ['No', 'Yes'];

  void updateDiabetes(String val) {
    selectedDiabetes = val;
    update();
  }

  String getDiabetesStatus() {
    return '${selectedDiabetes == 'No' ? '0' : '1'}';
  }

  var selectedGlasses = 'No';
  final List<String> glassesOptions = ['No', 'Yes'];

  void updateGlasses(String val) {
    selectedGlasses = val;
    update();
  }

  String getGlassesStatus() {
    return '${selectedGlasses == 'No' ? '0' : '1'}';
  }

  var selectedBp = 'No';
  final List<String> bpOptions = ['No', 'Yes'];

  void updateHealth(String val) {
    selectedBp = val;
    update();
  }

  String getBpStatus() {
    return '${selectedBp == 'No' ? '0' : '1'}';
  }

  String extractVideoId(String url) {
    // Use RegExp to extract the video ID from the URL
    final RegExp regExp = RegExp(
      r'(?<=v=|\/)([0-9A-Za-z_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match != null ? match.group(0) ?? '' : '';
  }

  bool _isDailySugarCheckupLoading = false;
  bool get isDailySugarCheckupLoading => _isDailySugarCheckupLoading;

  Future<dynamic> addSugarApi(String? testType, String? checkingTime, String? fastingSugar, String? measuredValue, String? checkingDate,
      String? hbA1c,String? systolic,String? diastolic) async {
    _isDailySugarCheckupLoading = true;
    update();
    Response response = await diabeticRepo.dailySugarCheckUpRepo(
        testType, checkingTime,fastingSugar, measuredValue,checkingDate,hbA1c,systolic,diastolic
    );
    if(response.statusCode == 200) {
      var responseData = response.body;
      log("${responseData}",name: "Response Data From AddSugar");
      if(responseData["msg"]  == "Data Inserted/Updated Successfully") {

        _isDailySugarCheckupLoading = false;
        //
        // Get.back();
        // log()
        // showCustomSnackBar('Added Successfully', );

        update();
        return true;
      } else {
        showCustomSnackBar(responseData["msg"], isError: true);
        _isDailySugarCheckupLoading = false;
        update();
      }
      _isDailySugarCheckupLoading = false;
      update();
    } else {
      _isDailySugarCheckupLoading = false;
      update();
    }
    _isDailySugarCheckupLoading = false;
    update();
  }

  List<SugarCheckupModel>? _sugarCheckUpList;
  List<SugarCheckupModel>? get sugarCheckUpList => _sugarCheckUpList;

  Future<void> getSugarCheckUpHistory() async {
    _isDailySugarCheckupLoading = true;
    update();
    try {
      Response response = await diabeticRepo.fetchDailySugarCheckUpRepo();
      if (response.statusCode == 200) {
        print("Full API Response: ${response.body}");
        if (response.body != null && response.body.containsKey('dailyChekupsList')) {
          List<dynamic> responseData = response.body['dailyChekupsList'];
          _sugarCheckUpList = responseData.map((json) => SugarCheckupModel.fromJson(json as Map<String, dynamic>)).toList();
          print("Appointment dailyChekupsList fetched successfully: $_sugarCheckUpList");
          } else {
          print("No dailyChekupsList key found in the response.");
          _sugarCheckUpList = [];
          }
      } else {
        print("Error while fetching dailyChekupsList history. Status code: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching dailyChekupsList history: $error");
    } finally {
      _isDailySugarCheckupLoading = false;
      update();
    }
  }


  MonthlySugarValues? _sugarChartList;
  MonthlySugarValue? todaySugar;
  MonthlySugarValue? todayBpValue;




  MonthlySugarValues? get sugarChartList => _sugarChartList;
  MonthlySugarValues? _bpChartList;




  MonthlySugarValues? get bpChartList => _bpChartList;

  DietPlanModel? get dietPlan => _dietPlan;
  DietPlanModel? _dietPlan;
  SubscriptionModel? _subscriptionModel;
  SubscriptionModel? get subscriptionModel => _subscriptionModel;
  PlanDetailsModel? _planDetails;
  PlanDetailsModel? get planDetails => _planDetails;


  List<PlanResourceModel> videoResources = [];
  List<PlanResourceModel> imageResources = [];
  List<PlanResourceModel> pdfResources = [];
  List<PlanResourceModel> textResources = [];

  Future<void> getDiabeticDashboard() async {
    _isDailySugarCheckupLoading = true;
    LoadingDialog.showLoading(message: "Please wait...");
    update();
    try {
      Response response = await diabeticRepo.fetchDashboardDataRepo();

      if (response.statusCode == 200) {
        var data = response.body['data'];
        // log("Data: ${response.body['data']["patientDetails"]}");
         var renewOption = response.body["renew_option"];
         var oldSubs = response.body["old_subs"];


        // print("Full API Response: ${renewOption}");
        // print("Full API Response: ${oldSubs}");
        if (data != null) {
          // Process monthly sugar values if they exist
          if (data.containsKey('monthlySugerValues') && data['monthlySugerValues'] != null) {
            // List<dynamic> monthlyValues = data['monthlySugerValues'];
            _sugarChartList = MonthlySugarValues.fromJson(data['monthlySugerValues']);
            print("Sugar Checkup List fetched successfully: $_sugarChartList");
          } else {
            _sugarChartList = MonthlySugarValues(monthlySugarValues: []);
            print("No monthlySugerValues key found in the response.");
          }




          if (data.containsKey('monthlyBpValues') && data['monthlyBpValues'] != null) {
            List<dynamic> monthlyValues = data['monthlyBpValues'];
            _bpChartList = MonthlySugarValues.fromJson(data['monthlyBpValues']);
            print("Sugar Checkup List fetched successfully: $_bpChartList");
          } else {
            _bpChartList = MonthlySugarValues(monthlySugarValues: []);
            print("No monthlySugerValues key found in the response.");
          }

          if (data['todaySugerValues'] != null) {
            dynamic monthlyValues = data['todaySugerValues'];
            todaySugar =  MonthlySugarValue.fromJson(monthlyValues as Map<String, dynamic>);

            print("Sugar Checkup List fetched successfully: $_bpChartList");
          } else {
            todaySugar = MonthlySugarValue(testDate: DateTime.now().toString(), measureValues: [],);
            print("No monthlySugerValues key found in the response.");
          }

          if (data['todayBpValues'] != null) {
            dynamic monthlyValues = data['todayBpValues'];
            todayBpValue =  MonthlySugarValue.fromJson(monthlyValues as Map<String, dynamic>);

            print("Sugar Checkup List fetched successfully: $_bpChartList");
          } else {
            todayBpValue = MonthlySugarValue(testDate: DateTime.now().toString(), measureValues: [],);
            print("No monthlySugerValues key found in the response.");
          }


          // Process diet plan
          if (data.containsKey('dietPlan') && data['dietPlan'] != null) {
            _dietPlan = DietPlanModel.fromJson(data['dietPlan'] as Map<String, dynamic>);
            print("Diet Plan fetched successfully: $_dietPlan");
          } else {
            _dietPlan = null;
            print("No dietPlan key found in the response.");
          }

          if(data['subscription'] != null) {
            var subscriptionData = data["subscription"];
            //debugPrint("Subscription Data: ${data["subscription"]}");
            _subscriptionModel = SubscriptionModel.fromJson(subscriptionData);
          } else {
            print("No subscription key found in the response.");
          }
          // Process plan details and resources
          if (data.containsKey('planDetails') && data['planDetails'] != null) {
            var planDetailsData = data['planDetails'];
            _planDetails = PlanDetailsModel.fromJson(planDetailsData);

            // Clear previous resources
            videoResources.clear();
            imageResources.clear();
            pdfResources.clear();
            textResources.clear();

            // Categorize resources by type
            if (planDetailsData.containsKey('plan_resources') && planDetailsData['plan_resources'] != null) {
              for (var resourceData in planDetailsData['plan_resources']) {
                final PlanResourceModel resource = PlanResourceModel.fromJson(resourceData);
                switch (resource.type) {
                  case 1:
                    videoResources.add(resource);
                    break;
                  case 2:
                    imageResources.add(resource);
                    break;
                  case 3:
                    pdfResources.add(resource);
                    break;
                  case 4:
                    textResources.add(resource);
                    break;
                  default:
                    print("Unknown resource type: ${resource.type}");
                }
              }
              print('Text Resources Length: ${textResources.length}');
            } else {
              print("No attachedPlanResources found in planDetails.");
            }
          } else {
            print("No planDetails key found in the response.");
          }
        } else {
          print("No data found in the response.");
        }
        var PatientData = PatientModel.fromJson(response.body['data']["patientDetails"]);
        Get.find<AppointmentController>().setisRenew(renewOption);
        Get.find<AppointmentController>().setisOld(oldSubs);
        Get.find<AppointmentController>().setpatientData(PatientData);
      } else {
        print("Error fetching dashboard data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching diabetic dashboard data: $error");
    } finally {
      _isDailySugarCheckupLoading = false;
      LoadingDialog.hideLoading();
      update();
    }
  }


  Future<void> addHealthApi(String? height, String? weight, String? waistCircumference,
      String? hipCircumference, String? year,String? month) async {
    _isDailySugarCheckupLoading = true;
    update();
    Response response = await diabeticRepo.healthCheckUpRepo(height,weight,waistCircumference,
        hipCircumference,year,month);
    if(response.statusCode == 200) {
      var responseData = response.body;
      if(responseData["msg"]  == "Data updated successfully") {
        Get.back();
        _isDailySugarCheckupLoading = false;

        Get.to(()=>DashboardScreen(pageIndex: 1));
        update();
        return showCustomSnackBar('Added Successfully', );
      } else {
        showCustomSnackBar(responseData["msg"], isError: true);
        _isDailySugarCheckupLoading = false;

        update();
      }
      _isDailySugarCheckupLoading = false;


      update();
    } else {
      _isDailySugarCheckupLoading = false;

      update();
    }
    _isDailySugarCheckupLoading = false;
    update();
  }



  bool _userDataLoading = false;
  bool get userDataLoading => _userDataLoading;


  UserData? _userData;
  PatientData? _patientData;

  UserData? get userData => _userData;
  PatientData? get patientData => _patientData;

  bool _isResourceDetailsLoading = false;
  bool get isResourceDetailsLoading => _isResourceDetailsLoading;

  PlanResourceModel? _resourceDetail;
  PlanResourceModel? get resourceDetail => _resourceDetail;

  Future<PlanResourceModel?> getResourceDetailsApi(String id) async {
    _isResourceDetailsLoading = true;
    _resourceDetail = null;
    update();

    try {
      Response response = await diabeticRepo.fetchResourceContentRepo(id);
      if (response.statusCode == 200) {
        final data = response.body['data'];
        _resourceDetail = PlanResourceModel.fromJson(data);
      } else {
        // Handle non-200 status codes
        print("Failed to resourceDetail data: ${response.statusCode}");
        // ApiChecker.checkApi(response);
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }
    _isResourceDetailsLoading = false;
    update();
    return _resourceDetail;
  }

  Future<void> addHealthGoalApi(String? title, String? description) async {
    LoadingDialog.showLoading(message: "Please wait...");
    update();

    // Call API to add health goal
    Response response = await diabeticRepo.addHealthGoal(title, description);

    if (response.statusCode == 200) {
      var responseData = response.body;

      // Check if the health goal was successfully created
      if (responseData["message"] == "health goal created successfully") {
        // Close the loading dialog
        Get.back(); // Close the current screen (dialog or page)

        // Call the method to refresh the health goals data
        await Get.find<DiabeticController>().getHealthGoalApi();

        // Show success message
        showCustomSnackBar('Added Successfully');
      } else {
        // Show error message if creation fails
        showCustomSnackBar(responseData["message"], isError: true);
      }
    } else {
      // Handle the case when the API call fails
      showCustomSnackBar('Failed to add health goal. Please try again.', isError: true);
    }

    // Close the loading dialog
    LoadingDialog.hideLoading();
    update();
  }





  Future<void> downloadImage(String url, String imageName) async {
    if (await Permission.storage.isDenied) {
      PermissionStatus status = await Permission.storage.request();
      if (!status.isGranted) {
        // If permission is denied, show a dialog
        Get.defaultDialog(
          title: "Permission Required",
          content: const Text("Please enable storage permission to download the image."),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
          ],
        );
        return;
      }
    }

    // Continue to download if permission is granted
    if (await Permission.storage.isGranted) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final directory = await getExternalStorageDirectory();
          final filePath = '${directory!.path}/$imageName.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          Get.snackbar("Download", "Image saved to $filePath",
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar("Download Failed", "Unable to download image",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to save image: $e",
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar("Permission Denied", "Storage permission is required",
          snackPosition: SnackPosition.BOTTOM);
    }
  }


  bool _isPatientDataLoading = false;
  bool get isPatientDataLoading => _isPatientDataLoading;

  SubscribedPatientModel? _subscribedPatientData;
  SubscribedPatientModel? get subscribedPatientData => _subscribedPatientData;

  Future<SubscribedPatientModel?> getSubscribedPatientDataApi() async {
    _isPatientDataLoading = true;
    _subscribedPatientData = null;
    update();

    try {
      Response response = await diabeticRepo.fetchSubscribedPatientDataRepo();
      if (response.statusCode == 200) {
        final data = response.body['data'];
        _subscribedPatientData = SubscribedPatientModel.fromJson(data);
      } else {
        // Handle non-200 status codes
        print("Failed to subscribedPatientData data: ${response.statusCode}");
        // ApiChecker.checkApi(response);
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }
    _isPatientDataLoading = false;
    update();
    return _subscribedPatientData;
  }


  bool _loading = false;
  bool get loading => _loading;

  List<MedicalRecord>? _healthGoalData;
  List<MedicalRecord>? get healthGoalData => _healthGoalData;

  String? _healthGoal = '';
  String? get healthGoal => _healthGoal;

  // Call the API to fetch health goal data
  Future<void> getHealthGoalApi() async {
    _loading = true;
    update();  // Trigger UI update for loading state
    try {
      Response response = await diabeticRepo.fetchHealthGoatDataRepo();
      if (response.statusCode == 200) {
        print("Full API Response: ${response.body}");
        if (response.body != null && response.body.containsKey('data')) {
          List<dynamic> responseData = response.body['data'];
          _healthGoalData = responseData.map((json) => MedicalRecord.fromJson(json as Map<String, dynamic>)).toList();
          print("Appointment data fetched successfully: $_healthGoalData");
        } else {
          print("No data key found in the response.");
          _healthGoalData = [];
        }
      } else {
        print("Error while fetching data history. Status code: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching data history: $error");
    } finally {
      _loading = false;
      update();  // Trigger UI update for loading state
    }
  }

  // Update the health goal value when the dropdown is changed
  void updateHealthGoal(String newValue) {
    _healthGoal = newValue;
    update();  // Trigger UI update for the selected value
  }




}

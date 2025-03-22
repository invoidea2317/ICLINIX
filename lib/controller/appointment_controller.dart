import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/screens/diabetic/plan_renew_option.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/models/response/add_patient_model.dart';
import 'package:iclinix/data/models/response/appointment_history_model.dart';
import 'package:iclinix/data/models/response/patients_model.dart';
import 'package:iclinix/data/models/response/plans_model.dart';
import 'package:iclinix/data/repo/appointment_repo.dart';
import 'package:iclinix/helper/date_converter.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/images.dart';

import '../app/widget/loading_widget.dart';
import '../data/models/body/appointment_model.dart';

class AppointmentController extends GetxController implements GetxService {
  final AppointmentRepo appointmentRepo;
  final ApiClient apiClient;

  AppointmentController(
      {required this.appointmentRepo, required this.apiClient});

  AppointmentController get appointmentController =>
      Get.find<AppointmentController>();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isPlanRenewingDone = false;

  bool get isPlanRenewingDone => _isPlanRenewingDone;

  void setPlanRenewingCondition([bool? val]) {
    _isPlanRenewingDone = val ?? false;
    update();
  }
  bool _isPlanRenewing = false;

  bool get isPlanRenewing => _isPlanRenewing;

  PatientModel _patientData = PatientModel();

  PatientModel get patientData => _patientData;

  void setPlanRenewing([bool? val]) {
    _isPlanRenewing = val ?? false;
    update();
  }
 void setpatientData(PatientModel data) {
    debugPrint("data===>: $data");
   _patientData = data;
    update();
  }

  bool? _isPromotionalCode = false;

  bool? get isPromotionalCode => _isPromotionalCode;

  void setPromotionalCode([bool? val]) {
    _isPromotionalCode = val ?? !isPromotionalCode!;
    update();
  }

  bool? _isRenew = false;

  bool? get isRenew => _isRenew;

  void setisRenew(bool? val) {
    _isRenew = val;
    update();
  }
  bool? _isOld = false;

  bool? get isOld => _isOld;

  void setisOld(bool val) {
    _isOld = val ;
    update();
  }

  dynamic _patientAppointments = [];

  dynamic get patientAppointment => _patientAppointments;

  void setPatientAppointment(dynamic val) {
    if(val.isEmpty){
      //debugPrint("empty");
      _patientAppointments.clear;
    } else {
      _patientAppointments = val;
    }
    update();
  }


  bool?  _isComing = false;

  bool? get isComing => _isComing;

  void setisComing([bool? val]) {
    _isComing = val ;
    update();

  }
  bool?  _isVisiting = false;

  bool? get isVisiting => _isVisiting;

  void setisVisiting([bool? val]) {
    _isVisiting = val ;
    update();
  }
  bool?  _isCancelled = false;

  bool? get isCancelled => _isCancelled;

  void setisCancelled([bool? val]) {
    _isCancelled = val ;
    update();
  }

  bool? _isPaymentSuccessFull = false;

  bool? get isPaymentSuccessFull => _isPaymentSuccessFull;
  dynamic _apptId = "";

  dynamic get apptId => _apptId;

  dynamic _invoiceId = "";

  dynamic get invoiceId => _invoiceId;

  void setisPaymentSuccessFull([bool? val]) {
    _isPaymentSuccessFull = val!;
    update();
  }

  void setapptId([dynamic val]) {
    _apptId = val;
    update();
  }

  void setInvoiceId([dynamic val]) {
    _invoiceId = val;
    update();
  }

  dynamic _prescription = "";

  dynamic get prescription => _prescription;


  void setPrescription([dynamic val]) {
    _prescription = val;
    update();
  }


  String _orderId = "";

  String get orderId => _orderId;

  void setOrderId(String orderId) {
    _orderId = orderId;
    update();
  }
  String _HistoryId = "";

  String get HistoryId => _HistoryId;

  void setHistoryId(String historyId) {
    _HistoryId = historyId;
    update();
  }

  String _amount = "";

  String get amount => _amount;

  void setAmount(String amount) {
    _amount = amount;
    update();
  }

  String _razorPayKey = "";

  String get razorPayKey => _razorPayKey;

  void setRazorPayKey(String Key) {
    _razorPayKey = Key;
    update();
  }

  String _currency = "";

  String get currency => _currency;

  void setCurrency(String Currency) {
    _currency = Currency;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    formattedDate = SimpleDateConverter.formatDateToCustomFormat(selectedDate);
  }

  DateTime selectedDate =
      DateTime.now().add(Duration(days: 1)); // Default to current date
  String? formattedDate;

  String _scheduleType = "";

  String get ScheduleType => _scheduleType;
  String _scheduleid = "";

  String get Scheduleid => _scheduleid;

  void updateDate(DateTime newDate, String branchId) {
    selectedDate = newDate;
    formattedDate = SimpleDateConverter.formatDateToCustomFormat(selectedDate);
    getAppointmentSlotsApi(
        branchId, formattedDate!); // Fetch the slots for the selected date
    update(); // Trigger GetX update to refresh UI if necessary
  }

  String selectedValue = '';

  String? selectedTime;
  List<Map<String, dynamic>> timeSlot = [
    {'Time': "12:00", "ScheduleType": "General", "ScheduleTypeId": "1"}
  ];

  void selectTimeSlot(int index) {
    selectedTime = timeSlot[index]["Time"];
    _scheduleType = timeSlot[index]["ScheduleType"];
    _scheduleid = timeSlot[index]["ScheduleTypeId"];
    update(); // Update the state
  }

  var selectedInitial = 'Mr';
  var selectedGender = 'Male';
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  String getGenderStatus() {
    return selectedGender == 'Male'
        ? 'M'
        : selectedGender == 'Female'
            ? 'F'
            : 'O';
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
    formattedDobDate =
        SimpleDateConverter.formatDateToCustomFormat(selectedDobDate!);
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
    return selectedBp == 'No' ? '0' : '1';
  }

  bool _isNewPatientEnabled = false;

  bool get isNewPatientEnabled => _isNewPatientEnabled;

  void toggleNewPatientSelection(bool isNewPatient) {
    _isNewPatientEnabled = isNewPatient;
    update();
  }

  bool _isPlanNewPatientEnabled = true;

  bool get isPlanNewPatientEnabled => _isPlanNewPatientEnabled;

  void togglePlanNewPatientSelection([bool? value]) {
    _isPlanNewPatientEnabled = value ??
        !_isPlanNewPatientEnabled; // If value is provided, set it. Otherwise, toggle.
    update();
  }

  // void togglePlanNewPatientSelection() {
  //   _isPlanNewPatientEnabled = !_isPlanNewPatientEnabled;
  //   update();
  // }
  List<PlanModel>? _planList;

  List<PlanModel>? get planList => _planList;

  bool _isPlansLoading = false;

  bool get isPlansLoading => _isPlansLoading;

  Future<void> getPlansList() async {
    _isPlansLoading = true;
    update();
    try {
      Response response = await appointmentRepo.getPlansList();
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.body['plans'];
        _planList =
            responseData.map((json) => PlanModel.fromJson(json)).toList();
        print("Plans fetched successfully: $_planList");
      } else {
        print(
            "Error while fetching Data Error list: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching Plans list: $error");
    }
    _isPlansLoading = false;
    update();
  }

  List<PatientModel>? _patientList;

  List<PatientModel>? get patientList => _patientList;

  bool _isPatientLoading = false;

  bool get isPatientLoading => _isPatientLoading;

  Future<void> getPatientList() async {
    _isPatientLoading = true;
    update();
    try {
      Response response = await appointmentRepo.getPatientList();
      if (response.statusCode == 200) {
        if (response.body != null && response.body['patients'] != null) {
          List<dynamic> responseData = response.body['patients'];
          _patientList =
              responseData.map((json) => PatientModel.fromJson(json)).toList();
          print("Patients fetched successfully: $_patientList");
        } else {
          print("No patients found in the response.");
          _patientList = [];
        }
      } else {
        print(
            "Error while fetching data. Status code: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching Patient list: $error");
    }
    _isPatientLoading = false;
    update();
  }

  bool _isBookingLoading = false;

  bool get isBookingLoading => _isBookingLoading;

  Future<void> bookAppointmentApi(AppointmentModel appointment,
      String schedule_type, String schedule_Id,) async {
    // _isBookingLoading = true;
    update();
    Response response = await appointmentRepo.bookAppointmentRepo(
       bookingDiabeticType,
        appointment, schedule_type, schedule_Id);
    //debugPrint('Response: ${response.body}');
    if (response.statusCode == 200) {
      //debugPrint("Appointment booked successfully: ${response.body}");
      Get.find<AppointmentController>()
          .setOrderId(response.body['history_id'].toString());
      Get.find<AppointmentController>()
          .setAmount(response.body['amount'].toString());
      Get.find<AppointmentController>()
          .setCurrency(response.body['currency'].toString());
      Get.find<AppointmentController>()
          .setRazorPayKey(response.body['key'].toString());
    } else {
      _isBookingLoading = false;
      update();
      print('Failed to book appointment');
    }
    _isBookingLoading = false;
    update();
  }

  bool _isSlotLoading = false;

  bool get isSlotLoading => _isSlotLoading;

  Future<void> getAppointmentSlotsApi(String branchId, String date) async {
    _isSlotLoading = true;
    update();
    Response response = await appointmentRepo.getSlotList(branchId, date,bookingDiabeticType);
    List<dynamic> val = response.body['available_slots'];
    // //debugPrint('Length: ${val.length}');

    if (response.statusCode == 200) {
      //debugPrint('Response: ${response.body}');

      timeSlot.clear();
      response.body['available_slots'].forEach((slot) {
        // print('Slot: $slot');
        String time = slot['ApptTime'].toString();
        String formattedTime = time.substring(0, time.length - 3);
        timeSlot.add({
          "Time": SimpleTimeConverter.formatTimeToCustomFormat(
                  DateTime.parse("1970-01-01 $formattedTime"))
              .toString(),
          "ScheduleType": slot['ScheduleType'].toString(),
          "ScheduleTypeId": slot['PK_ScheduleTypeId'].toString()
        });
      });
      // showCustomSnackBar('Booking Created Successfully');
    } else {
      _isSlotLoading = false;
      update();
      print('Failed to book appointment');
    }
    _isSlotLoading = false;
    update();
  }

  var selectedPatient = ''.obs; // RxString
  var selectedPatientId = 0.obs;

  void selectPatient(int id, String name) {
    selectedPatient.value = name; // Update the name in RxString
    selectedPatientId.value = id; // Update the ID in RxInt
  }

  List<String> paymentMethods = [
    'Cash',
    'Pay online'
  ];
  List<String> paymentImages = [Images.icCash, Images.icRazorpay];
  var selectedPaymentMethod =
      'Cash'.obs; // RxString for selected payment method
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    update();// Update the selected payment method
  }

  List<AppointmentHistoryModel>? _appointmentHistoryList;

  List<AppointmentHistoryModel>? get appointmentHistoryList =>
      _appointmentHistoryList;

  void setAppointmentHistoryList(List<AppointmentHistoryModel> list) {
    _appointmentHistoryList = list; // Update the selected payment method
  }

  bool _isAppointmentHistoryLoading = false;

  bool get isAppointmentHistoryLoading => _isAppointmentHistoryLoading;

  Future<void> getAppointmentHistory() async {
    _isAppointmentHistoryLoading = true;
    LoadingDialog.showLoading(message: "Please wait...");
    update();

    try {
      Response response = await appointmentRepo.getAppointmentList();

      if (response.statusCode == 200) {
        if (response.body != null && response.body['appointmentData'] != null) {
          List<dynamic> responseData = response.body['appointmentData'];
          //debugPrint("Response patient: ${response.body['appointmentData'][0]["patient_appointments"]}");
          setAppointmentHistoryList(responseData
              .map((json) => AppointmentHistoryModel.fromJson(
                  json as Map<String, dynamic>))
              .toList());
          // _appointmentHistoryList = responseData
          //     .map((json) => AppointmentHistoryModel.fromJson(
          //         json as Map<String, dynamic>))
          //     .toList();

          print(
              "Appointment appointmentData fetched successfully: $_appointmentHistoryList");
        } else {
          print("No appointment appointmentData found in the response.");
          _appointmentHistoryList = [];
        }
      } else {
        print(
            "Error while fetching appointment history. Status code: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching appointment history: $error");
    } finally {
      _isAppointmentHistoryLoading = false;
      LoadingDialog.hideLoading();
      update();
    }
  }

  bool _bookingDiabeticType = false;

  bool get bookingDiabeticType => _bookingDiabeticType;

  void selectBookingType(bool val) {
    _bookingDiabeticType = val;
    update();
  }

  Future<void> addPatientApi(
    AddPatientModel addPatient,
  ) async {
    _isLoading = true;
    update();

    Response response = await appointmentRepo.addPatientDetails(addPatient);
    if (response.statusCode == 200) {
      var responseData = response.body;
      if (responseData["message"] == "Patient added successfully") {
        _isPlanNewPatientEnabled = false;
        getPatientList();
        _isLoading = false;
        update();
        return showCustomSnackBar('Added Successfully', isError: true);
      } else {
        _isLoading = false;
        update();
      }
      _isLoading = false;
      update();
    } else {
      _isLoading = false;
      update();
    }

    _isLoading = false;
    update();
  }

  Future<void> postDataBack(
    Map<String, dynamic> requestBody,
  ) async {
    _isLoading = true;
    LoadingDialog.showLoading(message: "Please wait...");
    update();

    Response response = await appointmentRepo.postDataBack(requestBody);
    if (response.statusCode == 200) {
      var responseData = response.body;
      debugPrint('Response: $responseData');
      if (responseData['message'] == "Appointment Booked Successfully.") {
        setisPaymentSuccessFull(true);
        getInvoice(responseData['appt_id'].toString());
      }
      _isLoading = false;
      update();
    } else {
      _isLoading = false;
      update();
    }

    LoadingDialog.hideLoading();
    _isLoading = false;
    update();
  }


  Future<void> postDataBackPlans(
      Map<String, dynamic> requestBody,
      bool? renew
      ) async {
    _isLoading = true;
    LoadingDialog.showLoading(message: "Please wait...$renew");
    update();

    Response response = await appointmentRepo.postDataBackPlans(requestBody,renew);
    if (response.statusCode == 200) {
      var responseData = response.body;
      //debugPrint('Response: $responseData');
    await Get.find<AuthController>().userDataApi();

      Get.offAllNamed(RouteHelper.dashboard);
      _isLoading = false;
      update();
    } else {
      _isLoading = false;
      update();
    }

    LoadingDialog.hideLoading();
    _isLoading = false;
    update();
  }

  Future<void> getInvoice(
    String Id,
  ) async {
    update();
    Response response = await appointmentRepo.getInvoice(Id);
    //debugPrint('Response: ${response.body['pdfLink']}');
    setapptId(response.body['pdfLink']);

    if (response.statusCode == 200) {
      // //debugPrint('Response: ${response.body}');
      // showCustomSnackBar('Booking Created Successfully');
    } else {
      update();
    }

    update();
  }

  Future<void> getInvoiceSubs(
    String Id,
  ) async {
    update();
    Response response = await appointmentRepo.getInvoiceSubs(Id);
    //debugPrint('Response: ${response.body['pdfLink']}');
    setInvoiceId(response.body['pdfLink']);

    if (response.statusCode == 200) {
      // //debugPrint('Response: ${response.body}');
      // showCustomSnackBar('Booking Created Successfully');
    } else {
      update();
    }

    update();
  }


  Future<void> getPrescription(
      String Id,
      ) async {
    update();
    Response response = await appointmentRepo.getPrescription(Id);
    //debugPrint('Response: ${response.body['pdfLink']}');
    setPrescription(response.body['pdfLink']);

    if (response.statusCode == 200) {
      // //debugPrint('Response: ${response.body}');
      // showCustomSnackBar('Booking Created Successfully');
    } else {
      update();
    }

    update();
  }


  bool _isPurchasePlanLoading = false;

  bool get isPurchasePlanLoading => _isPurchasePlanLoading;

  Future<void> purchasePlanApi(
      String? patientId, String? planId, String? paymentMethod,bool? renew)
  async {
    _isPurchasePlanLoading = true;
    update();

    Response response =
        await appointmentRepo.purchasePlanApi(patientId, planId, paymentMethod,renew);
    if (response.statusCode == 200) {
      var responseData = response.body;
      //debugPrint('Response: ${response.body}');
      if (responseData["status"]) {
        //debugPrint("Plan purchased successfully: ${response.body}");
        Get.find<AppointmentController>().setHistoryId(responseData["history_id"].toString());
        razorpayImplement(responseData["plan_name"], responseData["amount"].toString(), responseData["history_id"].toString(),responseData["key"], responseData["currency"], );
        // await Get.find<AuthController>().userDataApi();
        // Get.toNamed(RouteHelper.getPlanPaymentSuccessfulRoute());
      } else {
        showCustomSnackBar(responseData["message"], isError: true);
      }
    } else {
      // showCustomSnackBar('Error occurred: ${response.reasonPhrase}', isError: true);
    }

    _isPurchasePlanLoading = false;
    update();
  }


  bool _isLoadingRefer = false;

  bool get isLoadingRefer => _isLoadingRefer;

  String _referImage = "";

  String get referImage => _referImage;

  void setReferImage(String val) {
    _referImage = val;
    update();
  }

  Future<void> getReferBanner()
  async {
    _isLoadingRefer = true;
    update();

    Response response =
    await appointmentRepo.referApi();
    if (response.statusCode == 200) {
      var responseData = response.body;
      //debugPrint('refer====>: $responseData');
      setReferImage(responseData["banners"][0]["image"]);
      _isLoadingRefer = false;
      update();
      // if (responseData["message"] == "Subscription created successfully") {
      //
      // } else {
      //   showCustomSnackBar(responseData["message"], isError: true);
      // }
    } else {
      // showCustomSnackBar('Error occurred: ${response.reasonPhrase}', isError: true);
    }

    _isLoadingRefer = false;
    update();
  }

  bool _isDiscount = false;

  bool get isDiscount => _isDiscount;

  String _discount = "";

  String get discount => _discount;

  void setDiscount(String val) {
    _discount = val;
    update();
  }


  Future<void> getisDiscount()
  async {
    _isDiscount = true;
    update();

    Response response =
    await appointmentRepo.discountApi();
    if (response.statusCode == 200) {
      var responseData = response.body;
      //debugPrint('discount====>: $responseData');
      setDiscount(responseData["banners"][0]["image"]);
      // if (responseData["message"] == "Subscription created successfully") {
      //
      // } else {
      //   showCustomSnackBar(responseData["message"], isError: true);
      // }
    } else {
      // showCustomSnackBar('Error occurred: ${response.reasonPhrase}', isError: true);
    }

    _isDiscount = false;
    update();
  }
  bool _isDiabeticBanner = false;

  bool get isDiabeticBanner => _isDiabeticBanner;


  String _diabeticBanner = "";

  String get diabeticBanner => _diabeticBanner;

  void setdiabeticBanner(String val) {
    _diabeticBanner = val;
    update();
  }

  Future<void> getisDiabeticBanner()
  async {
    _isDiabeticBanner = true;
    update();

    Response response =
    await appointmentRepo.diabeticBannerApi();
    if (response.statusCode == 200) {
      var responseData = response.body;
      //debugPrint('diabetic====>: $responseData');
      setdiabeticBanner(responseData["banners"][0]["image"]);
      // if (responseData["message"] == "Subscription created successfully") {
      //
      // } else {
      //   showCustomSnackBar(responseData["message"], isError: true);
      // }
    } else {
      // showCustomSnackBar('Error occurred: ${response.reasonPhrase}', isError: true);
    }

    _isDiabeticBanner = false;
    update();
  }

  bool _isCancellingLoading = false;

  bool get isCancellingLoading => _isCancellingLoading;

  Future<void> getCancelling(String id) async {
    _isCancellingLoading = true;
    LoadingDialog.showLoading(message: "Please wait...");
    update();

    try {
      Response response = await appointmentRepo.cancellationApi(id);

      if (response.statusCode == 200) {
       //debugPrint('Response===>: ${response.body}');
         Get.find<AppointmentController>().getAppointmentHistory();
       _isCancellingLoading = false;
      } else {
        _isCancellingLoading = false;
        print(
            "Error while fetching appointment history. Status code: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching appointment history: $error");
    } finally {
      _isAppointmentHistoryLoading = false;
      LoadingDialog.hideLoading();
      update();
    }
  }


}



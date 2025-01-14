import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/models/response/add_patient_model.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../helper/date_converter.dart';
import '../models/body/appointment_model.dart';

class AppointmentRepo {
  final ApiClient apiClient;
  AppointmentRepo({required this.apiClient,});

  Future<Response> getPlansList() {
    return apiClient.getData(AppConstants.planListUrl,method: 'GET');
  }

  Future<Response> getPatientList() {
    return apiClient.getData(AppConstants.patientListUrl,method: 'GET');
  }
 Future<Response> getSlotList(String branchId, String date, bool bookingType) {

   final requestBody = {
      "branchID": branchId,
      "appt_date": date,
      "doctor_id": bookingType?72:3,
   };
    return apiClient.postData(AppConstants.slotListUrl,requestBody);
  }

  Future<Response> bookAppointmentRepo(bool bookingType,AppointmentModel appointment,String schedule_type, String schedule_Id) async {
    // Prepare the data to be sent in the request body
    //debugPrint('appointment.appointmentDate: ${bookingType}');
    final requestBody = {
      "branchid": appointment.branchId,
      if (!appointment.includePatientType && appointment.patientId != null) 'patientId': appointment.patientId,
      if (appointment.includePatientType && appointment.firstName != null) 'firstname': appointment.firstName,
      if (appointment.includePatientType && appointment.lastName != null) 'lastname': appointment.lastName,
      if (appointment.includePatientType && appointment.mobileNo != null) 'mobileno': appointment.mobileNo,
      if (appointment.includePatientType && appointment.gender != null) 'gender': appointment.gender,
      if (appointment.includePatientType && appointment.dob != null) 'dob': appointment.dob,
      if (appointment.includePatientType && appointment.address != null) 'address': appointment.address,
      "appointment_date": appointment.appointmentDate!,
      "appointment_time": SimpleTimeConverter.format12HourTo24Hour(appointment.appointmentTime!),
      'complaints': appointment.complaint,
      // "other_problem": appointment.otherProblem,
      if (appointment.includePatientType && appointment.patientType != null) 'patient_type': appointment.patientType,
      "type" :appointment.type,
      "pay_method": "razorpay",
      "schedule_type": schedule_type,
      "schedule_type_id": schedule_Id,
      "doctor_id": bookingType?72:3,
    };

    // Print the request body for debugging
    print('Request Body: $requestBody');

    // Send the request and receive the response
    final response = await apiClient.postData(AppConstants.bookAppointmentUrl, requestBody);

    // Print the response body for debugging
    print('Response Body: ${response.body}');

    return response;
  }


  Future<Response> getAppointmentList() {
    return apiClient.getData(AppConstants.appointmentListUrl,method: 'GET');
  }
  Future<Response> getInvoice(String id) {
    return apiClient.getData(AppConstants.invoiceDownload+"${id}",method: 'GET');
  }
  Future<Response> getInvoiceSubs(String id) {
    return apiClient.getData(AppConstants.invoiceDownloadSubs+"${id}",method: 'GET');
  }
  Future<Response> getPrescription(String id) {
    return apiClient.getData(AppConstants.prescription+"${id}",method: 'GET');
  }

  Future<Response> addPatientDetails(AddPatientModel addPatient) {
    return apiClient.postData(AppConstants.addPatientDetails,{
      'initial' : addPatient.initial,
      'firstname' : addPatient.firstName,
      'lastname' : addPatient.lastName,
      'gender' : addPatient.gender,
      'dob' : addPatient.dob,
      'diabetes_problem': addPatient.diabetesProblem,
      'bp_problem' : addPatient.bpProblem,
      'eye_problem' : addPatient.eyeProblem
    });
  }
  Future<Response> postDataBack( Map<String, dynamic> requestBody) {
    return apiClient.postData(AppConstants.postDataBack,requestBody);
  }
  Future<Response> postDataBackPlans( Map<String, dynamic> requestBody, bool? renew) {
    return apiClient.postData((renew ?? false)?AppConstants.postDataBackPlansRenew:AppConstants.postDataBackPlans,requestBody);
  }
  Future<Response> cancellationApi(String id) {
    var body = {
      'appt_id' : id
    };
    return apiClient.postData(AppConstants.cancellation,body);
  }

  Future<Response> purchasePlanApi(String? patientId,
      String? planId,
      String? paymentMethod,
      bool? isRenewal
      ) {
    return apiClient.postData((isRenewal ?? false)?AppConstants.subscriptionCheckoutRenew:AppConstants.subscriptionCheckout,{
      'patient_id' : patientId,
      'plan_id' :planId,
      'payment_method' : paymentMethod,
    });
  }
  Future<Response> referApi() {
    return apiClient.getData(AppConstants.referEarn,method: 'GET');
  }

  Future<Response> discountApi() {
    return apiClient.getData(AppConstants.discountApi,method: 'GET');
  }
Future<Response> diabeticBannerApi() {
    return apiClient.getData(AppConstants.diabeticBanner,method: 'GET');
  }


  Future<Response> dailySugarCheckUpRepo(String? beforeMeal,
      String? afterBreakFast,String? afterLunch,
      String? afterDinner, String? randomEntry,String? checkingDate,) {
    return apiClient.postData(AppConstants.dailySugarCheckup,{
      'before_meal' : beforeMeal,
      'after_breakfast' :afterBreakFast,
      'after_lunch' : afterLunch,
      'after_dinner' : afterDinner,
      'random_entry' :randomEntry,
      'checking_date' : checkingDate,
      // 'patient_id' :patientId,
    });
  }

  Future<Response> fetchDailySugarCheckUpRepo() {
    return apiClient.getData(AppConstants.dailySugarCheckup,);
  }

  String whichGender(String? gender) {
    return "";
  }

}





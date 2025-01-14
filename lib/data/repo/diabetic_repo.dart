import 'dart:async';
import 'dart:developer';

import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/models/response/add_patient_model.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/body/appointment_model.dart';

class DiabeticRepo {
  final ApiClient apiClient;
  DiabeticRepo({required this.apiClient,});


  Future<Response> dailySugarCheckUpRepo(String? testType,
      String? checkingTime,
      String? fastingSugar,
      String? measuredValue,
      String? checkingDate,
      String? hbA1c,
      String? systolic,
      String? diastolic

      ) {

log("$checkingTime",name:"Checking Time");
    return apiClient.postData(AppConstants.dailySugarCheckup, {
      'test_type' : testType,
      'checking_time' : checkingTime,
      'fasting_suger' : fastingSugar,
      'measured_value' : measuredValue,
      "diastolic":diastolic,
      "systolic": systolic,
      'test_date' : checkingDate,
      'hbA1c' : hbA1c,
    });
  }

  Future<Response> fetchDailySugarCheckUpRepo() {
    return apiClient.getData(AppConstants.dailySugarCheckup,method: 'GET');
  }
  Future<Response> fetchDashboardDataRepo() {
    return apiClient.getData(AppConstants.diabeticDashboard,method: 'GET');
  }

  Future<Response> healthCheckUpRepo(String? height,
      String? weight,String? waistCircumference,
      String? hipCircumference, String? year,String? month) {
    return apiClient.postData(AppConstants.healthCheckup,{
      'height' : height,
      'weight' :weight,
      'waist_circumference' : waistCircumference,
      'hip_circumference' : hipCircumference,
      'dura_diabetes' : {
        "year":year,
        "month":month,
      }
    });
  }

  Future<Response> fetchResourceContentRepo(String id) {
    return apiClient.getData('${AppConstants.resourceContent}/$id',method: 'GET');
  }

  Future<Response> fetchSubscribedPatientDataRepo() {
    return apiClient.getData(AppConstants.subscribedPatientDetails,method: 'GET');
  }

  Future<Response> addHealthGoal(String? title,String? description) {
    return apiClient.postData(AppConstants.storeHealthGoal,{
      'title' : title,
      'description' : description,
    });
  }

  Future<Response> fetchHealthGoatDataRepo() {
    return apiClient.getData(AppConstants.fetchHealthGoal,method: 'GET');
  }

}





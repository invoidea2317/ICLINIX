
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/models/response/clinic_model.dart';
import 'package:iclinix/data/models/response/plans_model.dart';
import 'package:iclinix/data/models/response/search_model.dart';
import 'package:iclinix/data/models/response/services_model.dart';
import 'package:iclinix/data/repo/appointment_repo.dart';
import 'package:iclinix/data/repo/clinic_repo.dart';
import 'package:iclinix/helper/date_converter.dart';

import '../app/widget/loading_widget.dart';

class ClinicController extends GetxController implements GetxService {
  final ClinicRepo clinicRepo;
  final ApiClient apiClient;
  ClinicController({required this.clinicRepo, required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;



  List<ClinicModel>? _clinicList;
  List<ClinicModel>? get clinicList => _clinicList;

  bool _isClinicLoading = false;
  bool get isClinicLoading => _isClinicLoading;

  Future<void> getClinicList() async {
    LoadingDialog.showLoading(message: "Please wait...");
    _isClinicLoading = true;
    update();
    try {
      Response response = await clinicRepo.getClinicList();
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.body['branches'];
        _clinicList = responseData.map((json) => ClinicModel.fromJson(json)).toList();
        print("Plans fetched successfully: $_clinicList");
      } else {
        print("Error while fetching Data Error clinic list: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching Plans list: $error");
    }
    _isClinicLoading = false;
    LoadingDialog.hideLoading();
    update();
  }


  List<ServicesModel>? _servicesList;
  List<ServicesModel>? get servicesList => _servicesList;

  bool _isServicesLoading = false;
  bool get isServicesLoading => _isServicesLoading;

  Future<void> getServicesList() async {
    _isServicesLoading = true;
    update();
    try {
      Response response = await clinicRepo.getServicesList();
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.body['services'];
        _servicesList = responseData.map((json) => ServicesModel.fromJson(json)).toList();
        print("Plans fetched successfully: $_servicesList");
      } else {
        print("Error while fetching Data Error services list: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching Plans list: $error");
    }
    _isServicesLoading = false;
    update();
  }



  List<SearchModel>? _searchList = [];
  List<SearchModel>? get searchList => _searchList;


  List<Map<String,dynamic>>? _keywordList = [];
  List<Map<String,dynamic>>? get keywordList => _keywordList;

  void setKeywordList(List<Map<String,dynamic>> value){
    _keywordList = [];
    _keywordList = value;
    update();
  }

  bool _isSearchLoading = false;
  bool get isSearchLoading => _isSearchLoading;

  void clearSearchList() {
    _searchList = []; // Clear the search list
    update(); // Notify listeners
  }

  Future<void> getSearchList(String? query) async {
    _isSearchLoading = true;
    update();
    try {
      Response response = await clinicRepo.getSearchList(query);
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.body['searchResponse']['branch'];
        List<dynamic> responseDataServices = response.body['searchResponse']['service'];
        log("==gj=====> ${response.body['searchResponse']}");
        _searchList = responseData.map((json) => SearchModel.fromJson(json)).toList();
        _serviceDetailsSearchData = responseDataServices.map((json) => ServicesModel.fromJson(json)).toList();
        print("Plans fetched successfully: $_searchList");
      } else {
        print("Error while fetching Data Error services list: ${response.statusCode} - ${response.statusText}");
      }
    } catch (error) {
      print("Error while fetching Plans list: $error");
    }
    _isSearchLoading = false;
    update();
  }





  bool _isServiceDetailsLoading = false;
  bool get isServiceDetailsLoading => _isServiceDetailsLoading;

  ServicesModel? _serviceDetails;
  ServicesModel? get serviceDetails => _serviceDetails;

  List<ServicesModel>? _serviceDetailsSearchData;
  List <ServicesModel>? get serviceDetailsSearchData => _serviceDetailsSearchData;

  Future<ServicesModel?> getServiceDetailsApi(String? id) async {
    _isServiceDetailsLoading = true;
    _serviceDetails = null;
    update();

    try {
      Response response = await clinicRepo.getServiceDetails(id);
     debugPrint("========> ${response.body}");
      if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.body['serviceDetail'];
          _serviceDetails = ServicesModel.fromJson(responseData);
          debugPrint("========> ${_serviceDetails?.bannerUrl}");

      } else {
        print("Failed to serviceDetail data: ${response.statusCode}");
        // ApiChecker.checkApi(response);
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }

    _isServiceDetailsLoading = false;
    update();
    return _serviceDetails;
  }






}
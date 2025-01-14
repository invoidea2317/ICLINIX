import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';

import '../app/screens/chat/messaging.dart';
import '../data/api/api_client.dart';
import '../data/models/response/diabetic_dashboard_detail_model.dart';
import '../data/models/response/subsHIstoryModel.dart';
import '../data/models/response/ticket_model.dart';
import '../data/repo/clinic_repo.dart';

class SubsHistoryController extends GetxController implements GetxService {
  final ClinicRepo clinicRepo;
  final ApiClient apiClient;

  SubsHistoryController({required this.clinicRepo, required this.apiClient});

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int _type = 0;

  int get type => _type;
  SubscriptionModelHistory _allSubsHistory = SubscriptionModelHistory(
      subscriptionId: 0,
      subscriptionUniqueId: '',
      patientId: 0,
      userId: 0,
      planId: 0,
      subsHistoryId: 0,
      status: 0,
      expired: 0,
      expiredAt: '',
      updatedAt: '',
      createdAt: '',
      subscriptionHistory: []);

  SubscriptionModelHistory get allSubsHistory => _allSubsHistory;

  void setSubs(SubscriptionModelHistory value) {
    _allSubsHistory = value;
    update();
  }

  Future<void> getallSubsHistory() async {
    try {
      LoadingDialog.showLoading(message: "Sending..");
      final response = await clinicRepo.getSubs(); // Replace with your API call

      // Use response.body directly if already parsed into a map
      final Map<String, dynamic> parsedResponse = response.body;

      if (parsedResponse['status']) {
        final dynamic data = parsedResponse['data'];
        // Map each item in the data list to a Ticket object
        final SubscriptionModelHistory subsData =
            SubscriptionModelHistory.fromJson(data);

        // Pass the subs to your setter or state
        setSubs(subsData);
        //debugPrint("valueee==> $subsData");
        LoadingDialog.hideLoading();
      } else {
        throw Exception(
            "Expected 'data' to be a List, got ${parsedResponse['data'].runtimeType}");
      }
    } catch (e) {
      print("Error parsing tickets: $e");
      LoadingDialog.hideLoading();
    }
  }
}

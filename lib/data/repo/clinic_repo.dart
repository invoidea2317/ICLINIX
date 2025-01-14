import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClinicRepo {
  final ApiClient apiClient;
  ClinicRepo({required this.apiClient,});

  Future<Response> getClinicList() {
    return apiClient.getData(AppConstants.clinicListUrl,method: 'GET');
  }

  Future<Response> getServicesList() {
    return apiClient.getData(AppConstants.serviceListUrl,method: 'GET');
  }

  Future<Response> getSearchList(String? iclinix) {
    return apiClient.getData('${AppConstants.searchListUrl}?query=$iclinix',method: 'GET',);
  }
  Future<Response> getServiceDetails(String? id) async {
    return await apiClient.getData('${AppConstants.serviceDetails}$id',method: 'GET');
  }

  Future<http.Response> sendMessageRepo(
      String? subject,
      String? description,
      String? type,
      List<File> files, // Add files parameter to handle attachments
      ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = await sharedPreferences.getString(AppConstants.token);
    final url = Uri.parse(
        'https://lab5.invoidea.in/iclinix/public/api/add-ticket'); // Replace with your API URL

    var request = http.MultipartRequest('POST', url);
    request.fields['subject'] = subject ?? '';
    request.fields['message'] = description ?? '';
    request.fields['type'] = type ?? '';

   if(files.isNotEmpty) {
     //debugPrint('====> isEmpty: ${files.isEmpty}');
      for (var attachment in files) {
        request.files
            .add(await http.MultipartFile.fromPath('file[]', attachment.path));
      }
    }
    //debugPrint('====> API Call: $url\nHeader: $token');
     // debugPrint('====> API body: ${request.files.single.filename}');
    request.headers.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    try {
      // Send the request and get the StreamedResponse
      final streamedResponse = await request.send();

      // Convert the StreamedResponse to a Response
      final response = await http.Response.fromStream(streamedResponse);
          //debugPrint('====> API Response: ${response.body}');
      return response;
    } catch (e) {
      print("Exception: $e");
      rethrow; // Re-throw the error if needed
    }
  }


  Future<Response> getTickets(
      ) async {
    return await apiClient.getData('get-tickets',method: "GET");
  }
  Future<Response> getSubs(
      ) async {
    return await apiClient.getData('subscription-history',method: "GET");
  }
  Future<Response>
  getSingleTicketReplies(
      String id
      ) async {
    return await apiClient.postData('ticket-replies',{
      "ticket_id": id
    });
  }

}





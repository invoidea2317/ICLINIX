import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;

import '../../utils/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage = 'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;
  String? token;
  String? email;
  String? image;String? id;String? lastName;

  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    debugPrint('Token: $token');
    updateHeader(token);
  }

  void updateHeader(String? token,) {

    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token'
    };
    print("Api main header ================>${_mainHeaders} ");
  }

  // Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
  //   try {
  //     debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
  //     http.Response response = await http.get(
  //       Uri.parse(appBaseUrl+uri),
  //       headers: headers ?? _mainHeaders,
  //     ).timeout(Duration(seconds: timeoutInSeconds));
  //     print('====> API Response: ${response.body}');
  //     return handleResponse(response, uri);
  //   } catch (e) {
  //     return const Response(statusCode: 1, statusText: noInternetMessage);
  //   }
  // }

  Future<Response> getData(
      String uri, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        String method = 'POST', // Default method
        dynamic body,
      }) async {
    try {
      final uriWithQuery = query != null ? Uri.parse('$appBaseUrl$uri').replace(queryParameters: query) : Uri.parse('$appBaseUrl$uri');
      log('====> API Call: $uriWithQuery\nHeader: ${headers ?? _mainHeaders}');

      http.Response response;

      // switch (method.toUpperCase()) {
      //   case 'GET':
      //     response = await http.get(uriWithQuery, headers: headers ?? _mainHeaders)
      //         .timeout(Duration(seconds: timeoutInSeconds));
      //     break;
      //   case 'POST':
      //     response = await http.post(uriWithQuery, headers: headers ?? _mainHeaders, body: body)
      //         .timeout(Duration(seconds: timeoutInSeconds));
      //     break;
      //   case 'PUT':
      //     response = await http.put(uriWithQuery, headers: headers ?? _mainHeaders, body: body)
      //         .timeout(Duration(seconds: timeoutInSeconds));
      //     break;
      //   case 'DELETE':
      //     response = await http.delete(uriWithQuery, headers: headers ?? _mainHeaders)
      //         .timeout(Duration(seconds: timeoutInSeconds));
      //     break;
      //   case 'PATCH':
      //     response = await http.patch(uriWithQuery, headers: headers ?? _mainHeaders, body: body)
      //         .timeout(Duration(seconds: timeoutInSeconds));
      //     break;
      //   default:
      //     throw UnsupportedError('HTTP method not supported');
      // }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uriWithQuery, headers: headers ?? _mainHeaders)
              .timeout(Duration(seconds: timeoutInSeconds));
          break;
        case 'POST':
          response = await http.post(uriWithQuery, headers: headers ?? _mainHeaders, body: body)
              .timeout(Duration(seconds: timeoutInSeconds));
          break;
        case 'PUT':
          response = await http.put(uriWithQuery, headers: headers ?? _mainHeaders, body: body)
              .timeout(Duration(seconds: timeoutInSeconds));
          break;
        case 'DELETE':
          response = await http.delete(uriWithQuery, headers: headers ?? _mainHeaders)
              .timeout(Duration(seconds: timeoutInSeconds));
          break;
        default:
          throw UnsupportedError('HTTP method not supported');
      }

      log('====> API Response: ${response.body}');
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }




  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      //debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      //debugPrint('====> API Body: ${jsonEncode(body)}');
      var bodyEncoded = json.encode(body);
      debugPrint("Encoded Body==> ${jsonEncode(body)}");
      debugPrint("_mainHeaders: $_mainHeaders");
      http.Response response = await http.post(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      //debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, List<MultipartDocument> otherFile, {Map<String, String>? headers}) async {
    try {

      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          if(foundation.kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            http.MultipartFile part = http.MultipartFile(
              multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
              filename: basename(multipart.file!.path), contentType: MediaType('image', 'jpg'),
            );
            request.files.add(part);
          }else {
            File file = File(multipart.file!.path);
            request.files.add(http.MultipartFile(
              multipart.key, file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last,
            ));
          }
        }
      }

      if(otherFile.isNotEmpty){
        for(MultipartDocument file in otherFile){
          File other = File(file.file!.files.single.path!);
          Uint8List list0 = await other.readAsBytes();
          var part = http.MultipartFile(file.key, other.readAsBytes().asStream(), list0.length, filename: basename(other.path));
          request.files.add(part);
        }
      }

      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      //debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      //debugPrint('====> API Body: $body');
      http.Response response = await http.put(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    try {
      //debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);    }catch(_) {}
    Response response0 = Response(
      body: body ?? response.body, bodyString: response.body.toString(),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(response0.statusCode != 200 && response0.body != null && response0.body is !String) {
      response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['errors']['message']);
    }else if(response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    //debugPrint('====> API Response: [${response0.statusCode}] $uri\n${response.body}');
    return response0;
  }

}


class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class MultipartDocument {
  String key;
  FilePickerResult? file;
  MultipartDocument(this.key, this.file);
}
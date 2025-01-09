
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
import '../data/models/response/ticket_model.dart';
import '../data/repo/clinic_repo.dart';


class ChatController extends GetxController implements GetxService {
  final ClinicRepo clinicRepo;
  final ApiClient apiClient;
  ChatController({required this.clinicRepo, required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _type = 2;
  int get type => _type;
  List<Ticket> _allTickets = [];
  List<Ticket> get allTickets => _allTickets;
  List<TicketReply> _tickets = [];
  List<TicketReply> get ticketsReplies => _tickets;

  void setAllTickets(List<Ticket> value) {
    _allTickets = value;
    update();
  }
  void setTicketReplies(List<TicketReply> value) {
    _tickets = value;
    update();
  }

  void setType(int value) {
    _type = value;
    update();
  }

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;
  void pickImage(bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
    }else {
        _pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery);

      update();
    }
  }

  void sendMessage(int type, String subject, String description, List<File> selectedFiles) {
    LoadingDialog.showLoading(message: "Sending..");

    clinicRepo.sendMessageRepo(subject, description, type.toString(), selectedFiles).then((response) {
      // Check if the response was successful
      if (response.statusCode == 200) {
        var responseBody = response.body.isNotEmpty ? response.body : '{}';
        var parsedResponse = jsonDecode(responseBody);

        if (parsedResponse['status'] == 200) {
          if (parsedResponse['message'].toString().trim() == "Ticket created successfully") {
            LoadingDialog.hideLoading();
            Get.back();
            Get.snackbar("Success", parsedResponse['message']);
          }
        } else {
          // Handle any other response status or failure
          LoadingDialog.hideLoading();
          Get.snackbar("Error", "Failed to create ticket");
        }
      } else {
        // Handle failure in the case of a non-200 response
        LoadingDialog.hideLoading();
        Get.snackbar("Error", "Server error: ${response.statusCode}");
      }
    }).catchError((error) {
      // Handle any exceptions
      LoadingDialog.hideLoading();
      print("Error: $error");
      Get.snackbar("Error", "An error occurred while sending the message");
    });
  }

   Future<void> getTickets() async {
     try {
       LoadingDialog.showLoading(message: "Sending..");
       final response = await clinicRepo.getTickets(); // Replace with your API call

       // Use response.body directly if already parsed into a map
       final Map<String, dynamic> parsedResponse = response.body;

       if (parsedResponse['data'] is List) {
         final List<dynamic> data = parsedResponse['data'];
         // Map each item in the data list to a Ticket object
         final List<Ticket> tickets = [];
          data.forEach((item) {
            tickets.add(Ticket.fromJson(item));
          });

         // Pass the tickets to your setter or state
         setAllTickets(tickets);
         // debugPrint("valueee==> ${allTickets}");
         LoadingDialog.hideLoading();
       } else {
         setAllTickets([]);
         throw Exception("Expected 'data' to be a List, got ${parsedResponse['data'].runtimeType}");
       }
     } catch (e) {
       print("Error parsing tickets: $e");
       LoadingDialog.hideLoading();
     }

   }


   Future<void> getSingleTicketReplies(String id) async {
     try {
       LoadingDialog.showLoading(message: "Sending..");
       final response = await clinicRepo.getSingleTicketReplies(id); // Replace with your API call
       // log("valueee==> ${response.body}");

       // Use response.body directly if already parsed into a map
       final Map<String, dynamic> parsedResponse = response.body;

       if (parsedResponse['data']["ticket"]["ticket_to_replies"] is List) {
         final List<dynamic> data = parsedResponse['data']["ticket"]["ticket_to_replies"];
         // Map each item in the data list to a Ticket object
         final List<TicketReply> tickets = [];
         data.forEach((item) {
           tickets.add(TicketReply.fromJson(item));
         });
         setTicketReplies([]);
       setTicketReplies(tickets);
         // Pass the tickets to your setter or state
         // setAllTickets(tickets);
         // debugPrint("valueee==> ${allTickets}");
         // log("valueee==> ${tickets[0].ticketToReply![3]}",name: "replies==>");
         LoadingDialog.hideLoading();
         Get.to(() => Messaging(replies: tickets,id: id, subject: parsedResponse['data']["ticket"]['subject'],));
       } else {
         throw Exception("Expected 'data' to be a List, got ${parsedResponse['data'].runtimeType}");
       }
     } catch (e) {
       print("Error parsing tickets: $e");
       LoadingDialog.hideLoading();
     }
}


}
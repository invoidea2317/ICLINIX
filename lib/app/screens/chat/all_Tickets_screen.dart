import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:iclinix/app/drawer/help_screen.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';

import '../../../controller/chat_controller.dart';
import '../../../helper/route_helper.dart';
import 'messaging.dart';

class AllTicketsScreen extends StatefulWidget {
  const AllTicketsScreen({super.key});

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code here runs after the first frame is rendered
      print('First frame rendered!');
      Get.find<ChatController>().getTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatControl) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Your Messages",
          isBackButtonExist: true,
          menuWidget: Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.toNamed(RouteHelper.getChatRoute());
                },
                icon: const Icon(Icons.add),
                color: Colors.blue,
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Unread Messages',
                    style: TextStyle(
                      color: Color(0xFFDD2025),
                      fontSize: 18,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            chatControl.allTickets.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: chatControl.allTickets.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      debugPrint(
                          "valueee==> ${chatControl.allTickets[index].readStatus}");
                      return Visibility(
                        visible:
                            chatControl.allTickets[index].readStatus == "0",
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 324,
                            height: 67,
                            decoration: BoxDecoration(
                                color: chatControl
                                            .allTickets[index].ticketType?.type
                                            .toString() ==
                                        "Urgent"
                                    ? Color(0x4CB84A0F)
                                    : chatControl.allTickets[index].ticketType
                                                ?.type
                                                .toString() ==
                                            "Problem"
                                        ? Color(0x4CB8770F)
                                        : chatControl.allTickets[index]
                                                    .ticketType?.type
                                                    .toString() ==
                                                "Question"
                                            ? Color(0x4C0F93B8)
                                            : Color(0x4C61981E)),
                            child: ListTile(
                              onTap: () {
                                chatControl.getSingleTicketReplies(chatControl
                                        .allTickets[index].id
                                        .toString() ??
                                    "");
                              },
                              style: ListTileStyle.list,
                              splashColor: Colors.grey,
                              title: Text(
                                chatControl.allTickets[index].ticketType?.type
                                        .toString() ??
                                    "",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                chatControl.allTickets[index].subject ?? "",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : const Center(
                    child: Text("No Ticket Found"),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Read Messages',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: chatControl.allTickets.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: chatControl.allTickets.length,
                      itemBuilder: (context, index) {
                        debugPrint(
                            "valueee==> ${chatControl.allTickets[index].readStatus}");
                        return Visibility(
                          visible:
                              chatControl.allTickets[index].readStatus == "1",
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 324,
                              height: 67,
                              decoration: BoxDecoration(
                                  color: chatControl.allTickets[index]
                                              .ticketType?.type
                                              .toString() ==
                                          "Urgent"
                                      ? Color(0x19B84A0F)
                                      : chatControl.allTickets[index].ticketType
                                                  ?.type
                                                  .toString() ==
                                              "Problem"
                                          ? Color(0x19B8770F)
                                          : chatControl.allTickets[index]
                                                      .ticketType?.type
                                                      .toString() ==
                                                  "Question"
                                              ? Color(0x190F93B8)
                                              : Color(0x1961981E)),
                              child: ListTile(
                                onTap: () {
                                  chatControl.getSingleTicketReplies(chatControl
                                          .allTickets[index].id
                                          .toString() ??
                                      "");
                                },
                                style: ListTileStyle.list,
                                splashColor: Colors.grey,
                                title: Text(
                                  chatControl.allTickets[index].ticketType?.type
                                          .toString() ??
                                      "",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  chatControl.allTickets[index].subject ?? "",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                  : const Center(
                      child: Text("No Ticket Found"),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:iclinix/app/drawer/help_screen.dart';
import 'package:iclinix/app/screens/chat/chat_screen.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:intl/intl.dart';

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

  Color whichColor(String value, String isReadable) {
    debugPrint("valueee==> $value");

    // Define the colors for isReadable "1"
    const Map<String, Color> readableColors = {
      "Urgent": Color(0x19B84A0F),
      "Problem": Color(0x19B8770F),
      "Question": Color(0x190F93B8),
      "Lifestyle Support": Color(0x1961981E),
    };

    // Define the colors for isReadable "0"
    const Map<String, Color> unreadableColors = {

      "Urgent": Color(0x4CB84A0F),
      "Problem": Color(0x4CB8770F),
      "Question": Color(0x4C0F93B8),
      "Lifestyle Support": Color(0x4C61981E)

    };

    // Determine the correct map based on isReadable
    final colorMap = isReadable == "1" ? readableColors : unreadableColors;

    // Return the color if the value exists in the map, otherwise default to white
    return colorMap[value] ?? Colors.white;
  }


  String _formatTime(DateTime? dateTime) {
    debugPrint("DateTime: $dateTime");
    if (dateTime == null) return '';
    return DateFormat('MMMM dd, yyyy h:mm a').format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatControl) {
      // Sort the tickets by 'createdAt' in descending order
      chatControl.allTickets.sort((a, b) {
        // First prioritize unread messages
        if (a.readStatus == "0" && b.readStatus == "1") return -1;
        if (a.readStatus == "1" && b.readStatus == "0") return 1;

        // Then, sort by timestamp (assuming `createdAt` is a DateTime object)
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return Scaffold(
        appBar: CustomAppBar(
          title: "Your Messages",
          isBackButtonExist: true,
          menuWidget: Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.to(() => ChatScreen());
                },
                icon: const Icon(Icons.add),
                color: Colors.blue,
              )
            ],
          ),
        ),
        body: Column(
          children: [
            chatControl.allTickets.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: chatControl.allTickets.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      chatControl.getSingleTicketReplies(
                          chatControl.allTickets[index].id.toString() ?? "");
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 8,
                            ),
                            Container(
                              width: Get.size.width,
                              height: 67,
                              decoration: BoxDecoration(
                                color: whichColor(
                                  chatControl.allTickets[index].ticketType!.type.toString(),
                                  chatControl.allTickets[index].readStatus ?? "0",
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_formatTime(chatControl.allTickets[index].createdAt)}',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 12,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            maxLines: 1,
                                            chatControl.allTickets[index].latestReply ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: chatControl.allTickets[index].readStatus == "0",
                                          child: Text(
                                            maxLines: 1,
                                            "New",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 10,
                          top: 0,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: chatControl.allTickets[index].ticketType?.type.toString() ==
                                  "Urgent"
                                  ? Color(0xFFB84A0F)
                                  : chatControl.allTickets[index].ticketType?.type.toString() ==
                                  "Problem"
                                  ? Color(0xFFB8770F)
                                  : chatControl.allTickets[index].ticketType?.type.toString() ==
                                  "Question"
                                  ? Color(0xFF0F93B8)
                                  : Color(0xFF60971D),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Center(
                                child: Text(
                                  chatControl.allTickets[index].ticketType?.type.toString() ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Text("No Ticket Found"),
            ),
          ],
        ),
      );
    });
  }

}

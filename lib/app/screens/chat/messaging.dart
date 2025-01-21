import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/chat_controller.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/auth_controller.dart';
import '../../../data/models/response/ticket_model.dart';
import '../../../data/models/response/user_data.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../utils/app_constants.dart';
import '../../widget/loading_widget.dart';
import '../appointment/booking_successful_screen.dart';

class Messaging extends StatefulWidget {
  final List<TicketReply>? replies;
  final String id;
  final String subject;

  const Messaging({required this.replies, required this.id, required this.subject});

  @override
  State<Messaging> createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  final TextEditingController _messageController = TextEditingController();
  final List<XFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().userDataApi();
      Get.find<ChatController>().setTicketReplies(sortRepliesByDate(Get.find<ChatController>().ticketsReplies));
       Get.find<ChatController>().setIsRead(widget.id);
    });

  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachments.addAll(result.files
              .where((file) => file.path != null) // Ensure path is not null
              .map((file) => XFile(file.path!))
              .toList());
        });
      }
    } catch (e) {
    //  debugPrint('Error picking files: $e');
    }
  }



  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty || _attachments.isNotEmpty) {
      final List<File> files =
          _attachments.map((xfile) => File(xfile.path)).toList();

      await sendMessageWithAttachment(
        ticketId: int.parse(widget.id), // Replace with the actual ticket ID
        message: _messageController.text.trim(),
        attachments: files,
      );

      setState(() {
        _messageController.clear();
        _attachments.clear();
      });
    }
  }

  Future<void> sendMessageWithAttachment({
    required int ticketId,
    required String message,
    required List<File> attachments,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://lab5.invoidea.in/iclinix/public/api/send-reply');
    String? token = await sharedPreferences.getString(AppConstants.token);
    var request = http.MultipartRequest('POST', url);
    request.fields['ticket_id'] = ticketId.toString();
    request.fields['message'] = message;

    for (var attachment in attachments) {
      request.files.add(
        await http.MultipartFile.fromPath('file[]', attachment.path),
      );
    }
    request.headers.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        //debugPrint("Response: ${responseBody}");
        final responseData = jsonDecode(responseBody);
        print("Success: ${responseData['message']}");
        if (responseData['message'] == "Reply added successfully") {
          await Get.find<ChatController>().getSingleTicketReplies(widget.id);
           Get.find<ChatController>().setTicketReplies(sortRepliesByDate(Get.find<ChatController>().ticketsReplies));
        }
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
  List<TicketReply> sortRepliesByDate(List<TicketReply> replies, {bool ascending = true}) {
    replies.sort((a, b) {
      if (ascending) {
        return a.createdAt!.compareTo(b.createdAt!);
      } else {
        return b.createdAt!.compareTo(a.createdAt!);
      }
    });
    return replies;
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        Get.find<ChatController>().setIsRead(widget.id);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.back();
                Get.find<ChatController>().getTickets();
              },
            ),
            title: Text(widget.subject),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                 await Get.find<ChatController>().getSingleTicketReplies(widget.id);
                  Get.find<ChatController>().setTicketReplies(sortRepliesByDate(Get.find<ChatController>().ticketsReplies));
                },
              ),
            ],
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              GetBuilder<ChatController>(
                builder: (ChatController controller) {
                  return Expanded(
                    child: (Get.find<AuthController>().userData ??
                                    UserData(id: 0))
                                .id !=
                            0
                        ? ListView.builder(
                            itemCount: Get.find<ChatController>()
                                .ticketsReplies
                                .length,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            itemBuilder: (context, index) {
                              final reply = Get.find<ChatController>()
                                  .ticketsReplies[index];
                              debugPrint("User Data: ${reply.createdAt}");
                              final bool isBlueBackground =
                                  reply.replyByUserId ==
                                      (Get.find<AuthController>().userData ??
                                              UserData(id: 0))
                                          .id;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: isBlueBackground
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isBlueBackground
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            visible: reply.fileUrl != null &&
                                                reply.fileUrl!.isNotEmpty,
                                            child:
                                                (reply.fileUrl != null &&
                                                        reply.fileUrl!
                                                            .isNotEmpty)
                                                    ? reply.fileUrl!.length <= 1
                                                        ? GestureDetector(
                                                            onTap: () {

                                                              reply
                                                                  .fileUrl![0]
                                                                  .toLowerCase()
                                                                  .endsWith(
                                                                  '.pdf')? null:_showFullImage(
                                                                  context,
                                                                  reply
                                                                      .fileUrl![
                                                                  0]);
                                                            },
                                                            child: reply
                                                                    .fileUrl![0]
                                                                    .toLowerCase()
                                                                    .endsWith(
                                                                        '.pdf') || reply
                                                                .fileUrl![0]
                                                                .toLowerCase()
                                                                .endsWith(
                                                                '.xlsx')
                                                                ? Stack(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/images/PDF_file_icon.svg.png",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              _downloadImage(
                                                                                  reply.fileUrl![0],
                                                                                  context);
                                                                            },
                                                                            child: Container(
                                                                              width: 50,
                                                                              height: 65,
                                                                              decoration: ShapeDecoration(
                                                                                  shape:
                                                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                                  color: Colors.black.withOpacity(0.6)),
                                                                              child: Center(
                                                                                  child: Icon(Icons
                                                                                      .download,
                                                                                      color: Colors.red))),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Image.network(
                                                                    reply.fileUrl![
                                                                        0],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                          )
                                                        : ImageGridView(
                                                            fileUrls:
                                                                reply.fileUrl!)
                                                    : SizedBox.shrink(),
                                          ),
                                          Visibility(
                                            visible: reply.message != null &&
                                                reply.message!.isNotEmpty,
                                            child: Text(
                                              reply.message ?? '',
                                              style: TextStyle(
                                                color: isBlueBackground
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatTime(reply.createdAt),
                                            style: TextStyle(
                                              color: isBlueBackground
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              if (_attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: _attachments
                        .map((file) => Stack(
                              alignment: Alignment.topRight,
                              children: [
                                file.name.toLowerCase().endsWith('.pdf')
                                    ? Image.asset(
                                        "assets/images/PDF_file_icon.svg.png",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    :
                                Image.file(
                                  File(file.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _attachments.remove(file);
                                    });
                                  },
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attachment, color: Colors.blue),
                        onPressed: _pickAttachments,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? dateTime) {
    debugPrint("DateTime: $dateTime");
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyy h:mm a').format(dateTime);
  }
}

class ImageGridView extends StatelessWidget {
  final List<String> fileUrls;

  const ImageGridView({required this.fileUrls, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: fileUrls.length > 4 ? 4 : fileUrls.length,
      itemBuilder: (context, index) {
        final fileUrl = fileUrls[index];
        final isPdf = fileUrl.toLowerCase().endsWith('.pdf');

        if (index == 3 && fileUrls.length > 4) {
          return InkWell(
            onTap: !isPdf ? () => _showFullImage(
                context,
              fileUrls[index],) : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!isPdf)
                  Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (index == 3 && fileUrls.length > 4 && !isPdf)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        '+${fileUrls.length - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: !isPdf ? () => _showFullImage(context, fileUrl) : null,
          child: isPdf
              ? Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                )
              : Image.network(
                  fileUrl,
                  fit: BoxFit.cover,
                ),
        );
      },
    );
  }

}

void _showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () => _downloadImage(imageUrl, context),
                child: const Text('Download Image'),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _downloadImage(String imageUrl, BuildContext context) async {
  dynamic filePaths = "";
  if (await Permission.storage.isDenied) {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
  }

  LoadingDialog.showLoading(message: "Completed");

  Directory? downloadsDir;
  if (Platform.isAndroid) {
    downloadsDir =
        Directory('/storage/emulated/0/Download'); // Android Downloads folder
  } else if (Platform.isIOS) {
    downloadsDir =
        await getApplicationDocumentsDirectory(); // iOS app-specific folder
  }

  final filePath = "${downloadsDir?.path}/${imageUrl
      .toLowerCase()
      .endsWith(
      '.pdf')?"iclinix.pdf":"iclinixImage.jpg"}";

  Dio dio = Dio();

  try {
    await dio.download(
      imageUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // setState(() {
          //   progress = received / total;
          // });
        }
      },
    );

    // setState(() {
    //   isDownloading = false;
    // });

    filePaths = filePath;
    // Open the downloaded file
    // OpenFile.open(filePath);

    LoadingDialog.hideLoading();
    showNotification(imageUrl
        .toLowerCase()
        .endsWith(
        '.pdf')?"iclinix.pdf":"iclinixImage.jpg", filePath);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Download Complete"),
          content: Text("The file has been downloaded successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(filePath);
              },
              child: Text("Open File"),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print("Download failed: $e");
  }
}

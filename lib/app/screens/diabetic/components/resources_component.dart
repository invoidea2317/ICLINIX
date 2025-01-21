import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../data/models/response/diabetic_dashboard_detail_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../helper/local_notification.dart';
import '../../../widget/custom_snackbar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../widget/loading_widget.dart';
import '../../appointment/booking_successful_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';


class ResourcesComponent extends StatefulWidget {
  const ResourcesComponent({super.key});

  @override
  State<ResourcesComponent> createState() => _ResourcesComponentState();
}

class _ResourcesComponentState extends State<ResourcesComponent> {
  String extractYouTubeVideoId(String url) {
    final RegExp regExp = RegExp(
      r"(https?://)?(www\.)?(youtube|youtu|youtube-nocookie)\.(com|be)/(?:[^/]+/)*(?:v|e(?:mbed)?)\/?([^/?&]+)",
    );

    final match = regExp.firstMatch(url);

    if (match != null) {
      return match.group(4)!;
    } else {
      throw "Invalid YouTube URL";
    }
  }
  void showYouTubeVideoDialog(BuildContext context, String videoId) {

    // YouTubeWebView(videoId: videoId);
    // // Show dialog
    showDialog(
      // insetPadding: EdgeInsets.zero,
      context: context,
      barrierDismissible: true, // Allows closing the dialog by tapping outside
      builder: (context) {
        return Dialog(

          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child:
          // Container()
          Container(
              width: double.infinity,
              height:320,
              child: YouTubeWebView(videoId: videoId)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<DiabeticController>(builder: (controller) {
      final data = controller.videoResources;
      final isListEmpty = data.isEmpty;
      final isSugarLoading = controller.isDailySugarCheckupLoading;
      final dataReading = controller.textResources;
      final isReadingListEmpty = dataReading.isEmpty;
      final dataImage = controller.imageResources;
      final isImageListEmpty = dataImage.isEmpty;
      final dataPdf = controller.pdfResources;
      final isPdfListEmpty = dataPdf.isEmpty;
      final dataDietPlan = controller.dietPlan;
      final isDataDietPlanListEmpty = data.isEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resources',
            style: openSansSemiBold,
          ),
          sizedBoxDefault(),
          if (isSugarLoading)
            const Center(child: CircularProgressIndicator())
          else if (isListEmpty && isReadingListEmpty && isImageListEmpty && isPdfListEmpty)
            const Center(child: Text('No resources available.')) // Show no resources text
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDataDietPlanListEmpty) _buildDietPlanContent(context, controller, dataDietPlan),
                if (!isListEmpty) _buildVideoContent(context, controller, data),
                sizedBoxDefault(),
                if (!isReadingListEmpty) _buildReadingContent(context, controller, dataReading),
                sizedBoxDefault(),
                if (!isImageListEmpty) _buildImageContent(context, controller, dataImage),
                sizedBoxDefault(),
                if (!isPdfListEmpty) _buildPdfContent(context, controller, dataPdf),
                sizedBox100(),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildVideoContent(BuildContext context, DiabeticController controller, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Content',
          style: openSansRegular.copyWith(
            fontSize: Dimensions.fontSize14,
            color: Theme.of(context).disabledColor.withOpacity(0.60),
          ),
        ),
        sizedBox10(),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: data.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final videoId = controller.extractVideoId(data[i].ytUrl!);
              final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 250,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).disabledColor.withOpacity(0.20),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('ytUrl');
                              // _launchURL(data[i].ytUrl.toString());
                              showYouTubeVideoDialog(context, videoId);
                              // Get.to(() => YoutubePlayerDialog(videoId: videoId));

                            },
                            child: CustomNetworkImageWidget(
                              height: 150,
                              image: thumbnailUrl,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                print('ytUrl');
                                // _launchURL(data[i].ytUrl.toString());
                                showYouTubeVideoDialog(context, videoId);
                                // Get.to(() => YoutubePlayerDialog(videoId: videoId));

                              },
                              child: Icon(
                                Icons.play_circle_fill_outlined,
                                size: 60,
                                color: Colors.redAccent.withOpacity(0.80),
                              ),
                            ),
                          ),
                        ],
                      ),
                      sizedBox4(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          data[i].name.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: openSansMedium.copyWith(
                            fontSize: Dimensions.fontSize13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => sizedBoxW10(),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingContent(BuildContext context, DiabeticController controller, List<dynamic> dataReading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles',
          style: openSansRegular.copyWith(
            fontSize: Dimensions.fontSize14,
            color: Theme.of(context).disabledColor.withOpacity(0.60),
          ),
        ),
        sizedBox10(),
        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: dataReading.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteHelper.getResourcesDetailsRoute(dataReading[i].id.toString(), dataReading[i].name.toString()));
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(Dimensions.paddingSize8),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).disabledColor.withOpacity(0.20),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        width: 0.5,
                        color: Colors.transparent
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/images/eyeTestImage.jpeg"),
                        Text(
                          dataReading[i].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: openSansMedium.copyWith(
                            fontSize: Dimensions.fontSize13,
                          ),
                        ),
                       SizedBox(height: 10,),
                        CustomButtonWidget(buttonText: 'Read More',
                        height: 38,fontSize: Dimensions.fontSize14,
                        onPressed: () {
                          Get.toNamed(RouteHelper.getResourcesDetailsRoute(dataReading[i].id.toString(), dataReading[i].name.toString()));

                        },isBold: false,
                        transparent: true,),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => sizedBoxW10(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context, DiabeticController controller, List<dynamic> dataImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery',
          style: openSansRegular.copyWith(
            fontSize: Dimensions.fontSize14,
            color: Theme.of(context).disabledColor.withOpacity(0.60),
          ),
        ),
        sizedBox10(),
        SizedBox(
          height: 200,
          child: ListView.separated(
            itemCount: dataImage.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              print('${AppConstants.resourcesImageUrl}${dataImage[i].file}');
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showImageViewer(
                      context, Image.network('${AppConstants.resourcesImageUrl}${dataImage[i].file}').image,
                      swipeDismissible: true,
                      doubleTapZoomable: true,
                    );
                  },
                  child: Container(
                    height: 200,
                    width: 250,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).disabledColor.withOpacity(0.20),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomNetworkImageWidget(
                          height: 150,
                          image: '${AppConstants.resourcesImageUrl}${dataImage[i].file}',
                        ),
                        sizedBox10(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            dataImage[i].name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: openSansMedium.copyWith(
                              fontSize: Dimensions.fontSize13,
                            ),
                          ),
                        ),
                        // TextButton(
                        //   onPressed: () => controller.downloadImage(dataImage[i].fileUrl, dataImage[i].name),
                        //   child: Text(
                        //     'Download',
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: openSansBold.copyWith(
                        //       fontSize: Dimensions.fontSize14,
                        //       decoration: TextDecoration.underline,
                        //       color: Colors.redAccent,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => sizedBoxW10(),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfContent(BuildContext context, DiabeticController controller, List<dynamic> dataPdf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PDF Content',
          style: openSansRegular.copyWith(
            fontSize: Dimensions.fontSize14,
            color: Theme.of(context).disabledColor.withOpacity(0.60),
          ),
        ),
        sizedBox10(),
        SizedBox(
          height: 300,
          child: ListView.separated(
            itemCount: dataPdf.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  // controller.openPDF(dataPdf[i].fileUrl);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(Dimensions.paddingSize8),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).disabledColor.withOpacity(0.20),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        width: 0.5,
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Image.asset("assets/images/pdfIcon.png",scale: 1.25,),
                        Flexible(
                          child: Text(
                            dataPdf[i].name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: openSansMedium.copyWith(
                              fontSize: Dimensions.fontSize13,
                            ),
                          ),
                        ),
                        Text(
                          dataPdf[i].sortDescription,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: openSansMedium.copyWith(
                            fontSize: Dimensions.fontSize13,
                            color: Theme.of(context).disabledColor.withOpacity(0.40),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            print('check');
                            final url = '${AppConstants.resourcesImageUrl}${dataPdf[i].file}';
                            downloadFile(url);

                          },
                          child: Text(
                            'Download',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: openSansBold.copyWith(
                              fontSize: Dimensions.fontSize14,
                              decoration: TextDecoration.underline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => sizedBoxW10(),
          ),
        ),
      ],
    );
  }

  Widget _buildDietPlanContent(BuildContext context, DiabeticController controller, DietPlanModel? dietPlan) {
    if (dietPlan == null) {
      return const SizedBox(); // Or any placeholder if no diet plan is available
    }
    double progress = 0.0; // Track download progress
    bool isDownloading = false;
    dynamic filePaths = "";
    Future<void> downloadFile(String url, String fileName) async {

      if (await Permission.storage.isDenied) {
        await Permission.manageExternalStorage.request();
        await Permission.storage.request();
      }

      setState(() {
        progress = 0.0;
        isDownloading = true;
      });


      setState(() {
        progress = 0.0;
        isDownloading = true;
      });
      LoadingDialog.showLoading(message: "Completed: $progress");

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir =
            Directory('/storage/emulated/0/Download'); // Android Downloads folder
      } else if (Platform.isIOS) {
        downloadsDir =
        await getApplicationDocumentsDirectory(); // iOS app-specific folder
      }

      final filePath = "${downloadsDir?.path}/${fileName}";

      Dio dio = Dio();

      try {
        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                progress = received / total;
              });
            }
          },
        );

        setState(() {
          isDownloading = false;
        });

        filePaths = filePath;
        // Open the downloaded file
        // OpenFile.open(filePath);

        LoadingDialog.hideLoading();
        showNotification(fileName, filePath);
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
        setState(() {
          isDownloading = false;
        });
        print("Download failed: $e");
      }
    }
    return CustomDecoratedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Diet Plan',
                  style: openSansBold.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final url = "${dietPlan.excerciseChart}";
                  final url2 = "${dietPlan.dietchart}";
                      // '${AppConstants.resourcesImageUrl}${dataPdf[i].file}';
                  downloadFile(url,"${dietPlan.excerciseChart}".split('/').last);

                  downloadFile(url2,"${dietPlan.dietchart}".split('/').last);
                },
                child: Text(
                  'Download',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: openSansBold.copyWith(
                    fontSize: Dimensions.fontSize14,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          // const Divider(),
          // CustomNetworkImageWidget(image: dietPlan.excerciseChart),
          // CustomNetworkImageWidget(image: dietPlan.dietchart),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  Future<void> downloadFile(String fileUrl) async {
    // Ask for permission
    await Permission.manageExternalStorage.request();
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      // Permission denied
      return;
    }

    if (await Permission.storage.isRestricted) {
      // Storage is restricted
      return;
    }

    if (status.isGranted) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }

      final response = await http.get(Uri.parse(fileUrl));
      final bytes = response.bodyBytes;
      final fileName = fileUrl.split('/').last;

      try {
        final directory = Directory('/storage/emulated/0/Download'); // Android default download folder
        final filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(bytes);
        showCustomSnackBar("File Saved to download folder", isError: false);
        print('File downloaded to: $filePath');
        showNotification(fileName, filePath);
      } catch (e) {
        print('Error downloading file: $e');
      }
    }
  }

  Future<void> _showNotification(String fileName, String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0,
        'Download Complete',
        'File downloaded to: $filePath',
        platformChannelSpecifics,
        payload: filePath);
  }
}



class YouTubeWebView extends StatefulWidget {
  final String videoId; // YouTube Video ID

  const YouTubeWebView({Key? key, required this.videoId}) : super(key: key);

  @override
  _YouTubeWebViewState createState() => _YouTubeWebViewState();
}

class _YouTubeWebViewState extends State<YouTubeWebView> {
  late WebViewController _controller;
  late String embedUrl;

  @override
  void initState() {
    super.initState();

    // Construct the YouTube embed URL
    embedUrl = "https://www.youtube.com/embed/${widget.videoId}";

    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Handle progress updates
          },
          onPageStarted: (String url) {
            debugPrint("Page started loading: $url");
          },
          onPageFinished: (String url) {
            debugPrint("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebResourceError: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Change orientation to portrait on back press
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true; // Allow the back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('YouTube Video'),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}



import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/helper/date_converter.dart';
import 'package:iclinix/helper/invoice.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:iclinix/utils/themes/light_theme.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data' as typedData;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import '../../../controller/appointment_controller.dart';
import '../../../helper/local_notification.dart';


class BookingSuccessfulScreen extends StatefulWidget {
  final String? date;
  final String? time;
  final String? apptId;
  const BookingSuccessfulScreen({super.key, this.date, this.time, this.apptId});

  @override
  State<BookingSuccessfulScreen> createState() => _BookingSuccessfulScreenState();
}




class _BookingSuccessfulScreenState extends State<BookingSuccessfulScreen> {
  dynamic filePaths = "";

  double progress = 0.0; // Track download progress
  bool isDownloading = false;


  Future<void> downloadFile(String url, String fileName) async {
    // debugPrint("Downloading file from ${Get.find<AppointmentController>().apptId}");
    // await Permission.storage.request();
    if (await Permission.storage.isDenied) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
    }

    setState(() {
      progress = 0.0;
      isDownloading = true;
    });

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download'); // Android Downloads folder
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory(); // iOS app-specific folder
    }

    final filePath = "${downloadsDir?.path}/${fileName}";

    Dio dio = Dio();

    try {
      await dio.download(
        Get.find<AppointmentController>().apptId,
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().setisPaymentSuccessFull(false);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: isDownloading?0.1:1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Image.asset(Images.icBookingSuccessful,height: 160,),
                    sizedBox10(),
                    Text('Booking Successful!',style: openSansBold.copyWith(color: blueColor,
                    fontSize: Dimensions.fontSize20),),
                    sizedBox5(),
                    Text('You have successfully booked your appointment at',
                      textAlign: TextAlign.center,
                      style: openSansRegular.copyWith(
                        fontSize: Dimensions.fontSize12,
                    color: Theme.of(context).disabledColor.withOpacity(0.70)),),
                    sizedBoxDefault(),
                    Text('IClinix Advanced Eye And Retina Centre Lajpat Nagar',
                      textAlign: TextAlign.center,
                      style: openSansRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).disabledColor),),
                    sizedBoxDefault(),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDecoratedContainer(
                              child: Column(children: [
                                Text('On',style: openSansRegular.copyWith(
                                  fontSize: Dimensions.fontSize14,
                                  color: Theme.of(context).disabledColor.withOpacity(0.70)),),
                                Text(AppointmentDateTimeConverter.formatDate(widget.date!),
                                  textAlign: TextAlign.center,
                                  style: openSansSemiBold.copyWith(
                                      fontSize: Dimensions.fontSize14,
                                      color: Theme.of(context).primaryColor),),



                          ],)),
                        ),
                        sizedBoxW10(),
                        Expanded(
                          child: CustomDecoratedContainer(
                              child: Column(children: [
                                Text('At',style: openSansRegular.copyWith(
                                    fontSize: Dimensions.fontSize14,
                                    color: Theme.of(context).disabledColor.withOpacity(0.70)),),
                                Text('${widget.time}',
                                  textAlign: TextAlign.center,
                                  style: openSansSemiBold.copyWith(
                                      fontSize: Dimensions.fontSize14,
                                      color: Theme.of(context).primaryColor),),



                              ],)),
                        ),
                      ],
                    ),
                    sizedBox40(),

                   const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButtonWidget(buttonText: 'Download Invoice',
                              transparent: true,
                              isBold: false,
                              fontSize: Dimensions.fontSize14,
                              onPressed: () {
                                downloadFile(widget.apptId!, 'invoice.pdf');
                              },),

                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: CustomButtonWidget(buttonText: 'Go Home',
                              transparent: true,
                              isBold: false,
                              fontSize: Dimensions.fontSize14,
                              onPressed: () {
                                Get.toNamed(RouteHelper.getDashboardRoute());
                              },),
                          ),
                        ],
                      ),
                    ),
                    sizedBox40(),

                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isDownloading,
            child: Positioned(
                top: 400,
                left: 200,
                child: CircularProgressIndicator(value: progress)),
          )
        ],
      ),
    );
  }
}

Future<void> showNotification(String fileName, String filePath) async {

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'iClinix',
    'iClinix',
    color: Colors.black,
    enableLights: true,
    enableVibration: true,
    playSound: true,
    icon: 'ic_launcher',
    colorized: true,
    largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
    channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
      importance: Importance.max, priority: Priority.high, ticker: 'ticker'
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0,
      'Download Complete',
      'File downloaded to: $filePath',
      platformChannelSpecifics,
      payload: filePath);
}
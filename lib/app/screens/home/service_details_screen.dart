
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/widget/custom_image_widget.dart';
import 'package:iclinix/app/widget/empty_data_widget.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart' as htmlParser;
import '../../../../utils/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../utils/sizeboxes.dart';
import '../dashboard/dashboard_screen.dart';
import '../diabetic/components/resources_component.dart';
class ServiceDetailsScreen extends StatelessWidget {
  final String? id;
  final String? title;
  final String? videoUrl;
  const ServiceDetailsScreen({super.key, this.id, this.title, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ClinicController>().getServiceDetailsApi(id);
    });
    return Scaffold(
        appBar: CustomAppBar(title: title,isBackButtonExist: true,
        menuWidget:  Row(
          children: [
           ElevatedButton(onPressed: (){
             Get.to(const DashboardScreen(pageIndex: 2));
           }, child: Text("Book Now",)),
          ],
        ),
        ),
        body: GetBuilder<ClinicController>(builder: (clinicControl) {
          debugPrint("video: ${clinicControl.serviceDetails?.videoUrl}");
          final dataList = clinicControl.serviceDetails;
          final isListEmpty = dataList == null ;
          final isLoading = clinicControl.isServiceDetailsLoading;
          return  isLoading
              ? const Center(child: CircularProgressIndicator())
              : isListEmpty
              ? Center(
            child: EmptyDataWidget(
              text: 'Nothing Available',
              image: Images.icEmptyDataHolder,
              fontColor: Theme.of(context).disabledColor,
            ),
          )
              :  SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  clipBehavior: Clip.hardEdge,
                  width: Get.size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: Theme.of(context).disabledColor,
                  ),
                  child: CustomNetworkImageWidget(
                    radius: 0,
                    image: '${dataList.bannerUrl}',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$title: ",
                        style: openSansBold.copyWith(
                          fontSize: Dimensions.fontSize20,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      HtmlWidget(
                        dataList.description.toString(),
                        textStyle: openSansRegular.copyWith(
                          fontSize: Dimensions.fontSize14,
                          fontWeight: FontWeight.w100,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      // Text(
                      //   "${dataList.videoUrl}",
                      //   style: openSansBold.copyWith(
                      //     fontSize: Dimensions.fontSize20,
                      //     color: Theme.of(context).disabledColor,
                      //   ),
                      // ),
                      Visibility(
                        visible: dataList.videoUrl != null,
                          child: _buildVideoContent(dataList.videoUrl ?? "",context,dataList.videoTitle ?? "")),
                    ],
                  ),
                ),

              ],
            ),
          );
        })

    );
  }
}

Widget _buildVideoContent(String videoUrl,BuildContext context,String title) {
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
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: Get.size.width,
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
                      showYouTubeVideoDialog(context, extractYouTubeVideoId(videoUrl) ?? "");
                      // Get.to(() => YoutubePlayerDialog(videoId: videoId));

                    },
                    child: CustomNetworkImageWidget(
                      image: 'https://img.youtube.com/vi/${extractYouTubeVideoId(videoUrl)}/0.jpg',
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
                        showYouTubeVideoDialog(context, extractYouTubeVideoId(videoUrl) ?? "");
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toString(),
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
            ],
          ),
        ),
      ),
    ],
  );
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

String? extractYouTubeVideoId(String url) {
  final regex = RegExp(r'(?<=v=|vi=|be/|embed/|shorts/|youtu.be/)[^&\n?#]+');
  final match = regex.firstMatch(url);
  return match?.group(0);
}
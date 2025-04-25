import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/screens/home/components/book_appointment_component.dart';
import 'package:iclinix/app/screens/home/components/need_for_help_component.dart';
import 'package:iclinix/app/screens/home/components/verticle_banner_components.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/controller/profile_controller.dart';
import 'package:iclinix/helper/route_helper.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/images.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:upgrader/upgrader.dart';

import '../../widget/custom_drawer_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController filter = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SliderDrawerWidgetState> drawerKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _drawerCallback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().userDataApi();
    });
    _drawerCallback();
  }

  void _drawerCallback() {
    if (drawerKey.currentState?.isOpened ?? false) {
      print('Drawer is opened');
      // Perform action when the drawer is opened
    } else {
      print('Drawer is closed');
      // Perform action when the drawer is closed
    }
  }
  @override
  Widget build(BuildContext context) {
    return SliderDrawerWidget(
      key: drawerKey,
      option: SliderDrawerOption(
        backgroundColor: Theme.of(context).primaryColor,
        sliderEffectType: SliderEffectType.Rounded,
        upDownScaleAmount: 30,
        radiusAmount: 30,
        direction: SliderDrawerDirection.LTR,
      ),
      drawer: const CustomDrawer(),
      body: UpgradeAlert(
        shouldPopScope: () => true,
        dialogStyle: UpgradeDialogStyle.cupertino,
        child: Scaffold(
            extendBody: true,
            body : GestureDetector(
              onTap: () {
                if (drawerKey.currentState?.isOpened ?? false) {
                  drawerKey.currentState?.closeDrawer();
                    //debugPrint("Drawer is closed");

                }
              },
              child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      expandedHeight: 140.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration:  BoxDecoration(
                            color: Theme.of(context).cardColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: Column(
                              children: [
                               sizedBox20(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            drawerKey.currentState!.toggleDrawer();

                                          },
                                          child: Image.asset(
                                            Images.icMenu,
                                            height: Dimensions.paddingSize30,
                                            width: Dimensions.paddingSize30,
                                          ),
                                        ),
                                        sizedBoxW7(),
                                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Good Morning",
                                              style: openSansRegular.copyWith(
                                                  color: Theme.of(context).disabledColor.withOpacity(0.40),
                                                  fontSize: Dimensions.fontSize12),
                                            ),
                                            Text(
                                              "Hello ${Get.find<AuthController>().userData?.firstName ?? 'User'}",
                                              style: openSansBold.copyWith(
                                                color: Theme.of(context).disabledColor,
                                                fontSize: Dimensions.fontSizeDefault,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                    const Row(
                                      children: [
                                        // Image.asset(Images.icWhatsapp,height: Dimensions.fontSize24,),
                                        // sizedBoxW15(),
                                        NotificationButton()
                                        // Image.asset(Images.icNotification,height: Dimensions.fontSize24,),

                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(40.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault,
                          right:  Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeDefault),
                          child: Column(children: [
                            InkWell(onTap: () {
                              Get.toNamed(RouteHelper.getSearchRoute());
                            },
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSize5),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5,
                                  color: Theme.of(context).disabledColor.withOpacity(0.10)),
                                  color: Theme.of(context).cardColor,
                                  borderRadius:
                                  BorderRadius.circular(Dimensions.paddingSize5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Search",
                                            style: openSansSemiBold.copyWith(
                                                fontSize: Dimensions.fontSize13,
                                                color: Theme.of(context)
                                                    .hintColor), // Different color for "resend"
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                      Column(
                        children: [
                          const BookAppointmentComponent(),
                          NeedForHelpComponent(),
                          const VerticalBannerComponents(),
                          sizedBox100(),
                        ],
                      ),
                    )
                  ],

                    ),
            ),),
      ),
    );
  }
}



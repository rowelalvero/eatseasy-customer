import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchDefaultAddress.dart';
import 'package:eatseasy/views/cart/restaurant_cart_page.dart';
import 'package:eatseasy/views/home/home_page.dart';
import 'package:eatseasy/views/profile/profile_page.dart';
import 'package:eatseasy/views/search/seach_page.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../common/app_style.dart';
import '../common/reusable_text.dart';
import '../controllers/tab_controller.dart';
import 'cart/cart_page.dart';
// ignore: must_be_immutable
/*class MainScreen extends HookWidget {
  MainScreen({Key? key}) : super(key: key);

  final box = GetStorage();

  List<Widget> pageList = <Widget>[
    const HomePage(),
    const SearchPage(),
    const RestaurantCartPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? token = box.read('token');
    bool? verification = box.read("verification");
    if (token != null && verification == false) {
    } else if (token != null && verification == true) {
      useFetchDefault(context, true);
    }

    final entryController = Get.put(MainScreenController());
    return Obx(() => Scaffold(
      body: Stack(
        children: [
          pageList[entryController.tabIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: kPrimary),
              child: BottomNavigationBar(
                  selectedFontSize: 12,
                  backgroundColor: kPrimary,
                  elevation: 0,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  unselectedIconTheme:
                  const IconThemeData(color: Colors.black38),
                  items: [
                    BottomNavigationBarItem(
                      icon: entryController.tabIndex == 0
                          ? const Icon(
                        CupertinoIcons.house_fill,
                        color: kWhite,
                        size: 24,
                      )
                          : const Icon(CupertinoIcons.house_fill,),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: entryController.tabIndex == 1
                          ? const Icon(
                        CupertinoIcons.search,
                        color: kWhite,
                        size: 28,
                      )
                          : const Icon(CupertinoIcons.search,),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: entryController.tabIndex == 2
                          ? Badge(
                          label: ReusableText(
                              text: box.read('cart') ?? "0",
                              style: appStyle(
                                  8, kLightWhite, FontWeight.normal)),
                          child: const Icon(
                            CupertinoIcons.cart_fill,
                            color: kWhite,
                            size: 24,
                          ))
                          : Badge(
                        label: ReusableText(
                            text: box.read('cart') ?? "0",
                            style: appStyle(
                                8, kLightWhite, FontWeight.normal)),
                        child: const Icon(
                          CupertinoIcons.cart_fill,
                        ),
                      ),
                      label: 'Cart',
                    ),
                    BottomNavigationBarItem(
                      icon: entryController.tabIndex == 3
                          ? const Icon(
                        CupertinoIcons.person_fill,
                        color: kWhite,
                        size: 24,
                      )
                          : const Icon(
                        CupertinoIcons.person_fill,
                      ),
                      label: 'Profile',
                    ),
                  ],
                  currentIndex: entryController.tabIndex,
                  unselectedItemColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
                  selectedItemColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                  onTap: ((value) {
                    entryController.setTabIndex = value;
                  })),
            ),
          ),
        ],
      ),
    ));
  }
}*/

class MainScreen extends HookWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final PersistentTabController controller = useState(PersistentTabController(initialIndex: 0)).value;
    final reloadTrigger = useState(0); // State variable to trigger page reload

    // Fetch the default address only if token and verification conditions are met
    String? token = box.read('token');
    bool? verification = box.read("verification");

    if (token != null && verification == true) {
      useFetchDefault(context, true);  // Hook now called within build method
    }

    List<Widget> buildScreens() {
      return [
        HomePage(key: ValueKey(reloadTrigger.value)), // Use ValueKey to force rebuild
        SearchPage(key: ValueKey(reloadTrigger.value)),
        RestaurantCartPage(key: ValueKey(reloadTrigger.value)),
        ProfilePage(key: ValueKey(reloadTrigger.value)),
      ];
    }

    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.house_fill),
          title: ("Home"),
          activeColorPrimary: kPrimary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.search),
          title: ("Search"),
          activeColorPrimary: kPrimary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.cart_fill),
          title: box.read('cart') ?? "0",
          activeColorPrimary: kPrimary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.person_fill),
          title: ("Profile"),
          activeColorPrimary: kPrimary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return PersistentTabView(
      context,
      controller: controller,
      screens: buildScreens(),
      items: navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Colors.white,
      isVisible: true,
      onItemSelected: (index) {
        // Trigger a page rebuild by updating the reloadTrigger state
        reloadTrigger.value++;
      },
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style9,
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/tab_controller.dart';
import 'package:eatseasy/hooks/fetchDefaultAddress.dart';
import 'package:eatseasy/views/cart/cart_page.dart';
import 'package:eatseasy/views/home/home_page.dart';
import 'package:eatseasy/views/profile/profile_page.dart';
import 'package:eatseasy/views/search/seach_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends HookWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final PersistentTabController _controller = useState(PersistentTabController(initialIndex: 0)).value;

    // Fetch the default address only if token and verification conditions are met
    String? token = box.read('token');
    bool? verification = box.read("verification");

    if (token != null && verification == true) {
      useFetchDefault(context, true);  // Hook now called within build method
    }

    List<Widget> _buildScreens() {
      return [
        const HomePage(),
        const SearchPage(),
        const CartPage(),
        const ProfilePage(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
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
          title: box.read('Cart') ?? "0",
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
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Colors.white,
      isVisible: true,
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

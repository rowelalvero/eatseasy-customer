import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/cart_controller.dart';
import 'package:eatseasy/firebase_options.dart';
import 'package:eatseasy/models/environment.dart';
import 'package:eatseasy/services/notification_service.dart';
import 'package:eatseasy/views/auth/verification_page.dart';
import 'package:eatseasy/views/entrypoint.dart';
import 'package:eatseasy/views/message/chat/index.dart';
import 'package:eatseasy/views/orders/order_details_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/contact_controller.dart';

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print(
      "onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Widget defaultHome = MainScreen();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: Environment.fileName);
  await Firebase.initializeApp(
    name: 'eatseasy-food-apps',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(CartController());
  Get.put(ContactController());

  await NotificationService().initialize(flutterLocalNotificationsPlugin);

  runApp(const BetterFeedback(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? token = box.read('token');
    bool? verification = box.read("verification");
    /*return Scaffold(
      body: Container(
        child: Image.network("https://dbestech-code.oss-ap-southeast-1.aliyuncs.com/foodly_flutter/icons/fried%20rice.png?OSSAccessKeyId=LTAI5t8cUzUwGV1jf4n5JVfD&Expires=36001719651337&Signature=OLAAucrHwJmYVbU9FU1kLCjhCXE%3D"),
      ),
    );*/
    if (token != null && verification == false) {
      defaultHome = const VerificationPage();
    } else if (token != null && verification == true) {
      defaultHome = MainScreen();
    }
    return ScreenUtilInit(
        useInheritedMediaQuery: true,
        designSize: const Size(375, 825),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'EatsEasy Food App',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(kOffWhite.value),
              iconTheme: IconThemeData(color: Color(kDark.value)),
              primarySwatch: Colors.grey,
            ),
            home: defaultHome,
            navigatorKey: navigatorKey,
            routes: {
              '/order_details_page': (context) => const OrderDetailsPage(),
              '/chat':(context)=> const ChatPage()
            },
          );
        });
  }
}

import 'package:eatseasy/common/back_ground_container.dart';
import 'package:eatseasy/views/auth/phone_verification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/login_controller.dart';
import 'package:eatseasy/models/login_request.dart';
import 'package:eatseasy/views/auth/registration.dart';
import 'package:eatseasy/views/auth/widgets/email_textfield.dart';
import 'package:eatseasy/views/auth/widgets/password_field.dart';
import 'package:eatseasy/views/home/widgets/custom_btn.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

import '../../common/reusable_text.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.only(top: 5.w),
          height: 50.h,
          child: Text(
            "EatsEasy",
            style: appStyle(24, kPrimary, FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: BackGroundContainer(child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 30.h,
            ),
            Lottie.asset('assets/anime/delivery.json'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  //email
                  EmailTextField(
                    focusNode: _passwordFocusNode,
                    hintText: "Email",
                    controller: _emailController,
                    prefixIcon: Icon(
                      CupertinoIcons.mail,
                      color: Theme.of(context).dividerColor,
                      size: 20.h,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),

                  SizedBox(
                    height: 25.h,
                  ),

                  PasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                  ),

                  SizedBox(
                    height: 6.h,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const RegistrationPage());
                          },
                          child: Text('Register',
                              style: appStyle(
                                  12, kDark, FontWeight.normal)),
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 12.h,
                  ),
                  /*TextButton(onPressed: () {_showVerificationSheet(context);}, child: Text("Verification")),*/
                  Obx(
                        () => controller.isLoading
                        ? Center(
                        child: LoadingAnimationWidget.waveDots(
                            color: kPrimary,
                            size: 35
                        ))
                        : CustomButton(
                        btnHieght: 37.h,
                        color: kPrimary,
                        text: "L O G I N",
                        onTap: () {
                          LoginRequest model = LoginRequest(
                              email: _emailController.text,
                              password: _passwordController.text);

                          String authData = loginRequestToJson(model);

                          controller.loginFunc(authData, model);
                        }),
                  )
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
  Future<dynamic> _showVerificationSheet(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        showDragHandle: true,
        barrierColor: kPrimary.withOpacity(0.2),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 500.h,
            width: width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/restaurant_bk.png",
                    ),
                    fit: BoxFit.fill),
                color: kOffWhite,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Padding(
              padding: EdgeInsets.all(8.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  ReusableText(
                      text: "Verify Your Phone Number",
                      style: appStyle(20, kPrimary, FontWeight.bold)),
                  SizedBox(
                      height: 250.h,
                      child: ListView.builder(
                          itemCount: verificationReasons.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                verificationReasons[index],
                                textAlign: TextAlign.justify,
                                style:
                                appStyle(11, kGrayLight, FontWeight.normal),
                              ),
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: kPrimary,
                              ),
                            );
                          })),
                  SizedBox(
                    height: 20.h,
                  ),
                  CustomButton(
                      onTap: () {
                        Get.to(() => const PhoneVerificationPage());
                      },
                      btnHieght: 40.h,
                      text: "Verify Phone Number"),
                ],
              ),
            ),
          );
        });
  }
}

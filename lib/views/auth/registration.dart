import 'package:eatseasy/common/back_ground_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/registration_controller.dart';
import 'package:eatseasy/models/registration.dart';
import 'package:eatseasy/views/auth/widgets/email_textfield.dart';
import 'package:eatseasy/views/auth/widgets/password_field.dart';
import 'package:eatseasy/views/home/widgets/custom_btn.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

import '../../common/reusable_text.dart';
import '../../controllers/Image_upload_controller.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _firstNameController = TextEditingController();
  late final TextEditingController _lastNameController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  final imageUploader = Get.put(ImageUploadController());
  final FocusNode _passwordFocusNode = FocusNode();
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    final form = _loginFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.only(top: 5.w),
          height: 50.h,
          child: Center(
            child: Text(
              "EatsEasy",
              style: appStyle(24, kPrimary, FontWeight.bold),
            ),
          ),
        ),
      ),
      body: Center(child: BackGroundContainer(child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 30.h,
          ),
          Lottie.asset('assets/anime/delivery.json'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmailTextField(
                    focusNode: _passwordFocusNode,
                    hintText: "First name",
                    controller: _firstNameController,
                    prefixIcon: Icon(
                      CupertinoIcons.person,
                      color: Theme.of(context).dividerColor,
                      size: 20.h,
                    ),
                    keyboardType: TextInputType.text,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  EmailTextField(
                    focusNode: _passwordFocusNode,
                    hintText: "Last name",
                    controller: _lastNameController,
                    prefixIcon: Icon(
                      CupertinoIcons.person,
                      color: Theme.of(context).dividerColor,
                      size: 20.h,
                    ),
                    keyboardType: TextInputType.text,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),

                  SizedBox(
                    height: 15.h,
                  ),

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
                    height: 15.h,
                  ),

                  PasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                  ),

                  SizedBox(
                    height: 15.h,
                  ),
                  ReusableText(
                      text: "Upload documents",
                      style: appStyle(16, kDark, FontWeight.bold)),
                  ReusableText(
                    text:
                    "You are required fill all the details fully with the correct information",
                    style: appStyle(11, kGray, FontWeight.normal),
                  ),
                  ReusableText(
                    text:
                    "You can upload your picture of your house to be able track you house by our riders easily",
                    style: appStyle(11, kGray, FontWeight.normal),
                  ),
                  ReusableText(
                    text:
                    "Upload proof of residence e.g., Valid IDs, Electric/Water bill",
                    style: appStyle(11, kGray, FontWeight.normal),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          imageUploader.pickImage("validId");
                        },
                        child: Badge(
                          backgroundColor: Colors.transparent,

                          label: Obx(
                                () => imageUploader.validIdUrl.isNotEmpty
                                ? GestureDetector(
                              onTap: () {
                                imageUploader.validIdUrl = '';

                              },
                              child: const Icon(Icons.remove_circle, color: kRed),
                            ) : Container(),
                          ),

                          child: Container(
                              height: 120.h,
                              width: width / 2.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: kGrayLight),
                              ),
                              child: Obx(
                                    () => imageUploader.isLoading && imageUploader.imageBeingUploaded.value == "validId"
                                    ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingAnimationWidget.threeArchedCircle(
                                          color: kSecondary,
                                          size: 35
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${(imageUploader.uploadProgress * 100).toStringAsFixed(0)}%",  // Display the percentage
                                        style: appStyle(16, kDark, FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                )
                                    : imageUploader.validIdUrl.isEmpty
                                    ? Center(
                                  child: Text(
                                    "Upload Valid ID",
                                    style:
                                    appStyle(16, kDark, FontWeight.w600),
                                  ),
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    imageUploader.validIdUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          imageUploader.pickImage("proofOfResidence");
                        },
                        child: Badge(
                          backgroundColor: Colors.transparent,

                          label: Obx(
                                () => imageUploader.proofOfResidenceUrl.isNotEmpty
                                ? GestureDetector(
                              onTap: () {
                                imageUploader.proofOfResidenceUrl = '';

                              },
                              child: const Icon(Icons.remove_circle, color: kRed),
                            ) : Container(),
                          ),

                          child: Container(
                              height: 120.h,
                              width: width / 2.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: kGrayLight),
                              ),
                              child: Obx(
                                    () => imageUploader.isLoading && imageUploader.imageBeingUploaded.value == "proofOfResidence"
                                    ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingAnimationWidget.threeArchedCircle(
                                          color: kSecondary,
                                          size: 35
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${(imageUploader.uploadProgress * 100).toStringAsFixed(0)}%",  // Display the percentage
                                        style: appStyle(16, kDark, FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                )
                                    : imageUploader.proofOfResidenceUrl.isEmpty
                                    ? Center(
                                  child: Text(
                                    "Photo of your house",
                                    style:
                                    appStyle(16, kDark, FontWeight.w600),
                                  ),
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    imageUploader.proofOfResidenceUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 20.h,
                  ),

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
                        text: "R E G I S T E R",
                        onTap: () {
                          if(_firstNameController.text.isNotEmpty &&
                              _lastNameController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              imageUploader.validIdUrl.isNotEmpty &&
                              imageUploader.proofOfResidenceUrl.isNotEmpty
                          ) {
                            Registration model = Registration(
                                username: '${_firstNameController.text} ${_lastNameController.text}',
                                email: _emailController.text,
                                password: _passwordController.text,
                                validIdUrl: imageUploader.validIdUrl,
                                proofOfResidenceUrl: imageUploader.proofOfResidenceUrl
                            );

                            String userdata = registrationToJson(model);

                            controller.registration(userdata);
                          }

                        }),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          )
        ],
      )),),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../common/app_style.dart';
import '../../common/back_ground_container.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../controllers/Image_upload_controller.dart';
import '../../controllers/login_controller.dart';
import '../../controllers/phone_verification_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/login_response.dart';
import '../../models/update_profile.dart';
import '../auth/widgets/email_textfield.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.user});

  final LoginResponse? user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final logOutcontroller = Get.put(LoginController());
  final imageUploader = Get.put(ImageUploadController());
  final controller = Get.put(LoginController());
  final verificationController = Get.put(PhoneVerificationController());
  final box = GetStorage();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginResponse? user;
  String? verificationId;
  final TextEditingController _otpController = TextEditingController();

  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    setState(() {
      _emailController.text = widget.user!.email;
      _nameController.text = widget.user!.username;
      _phoneController.text = widget.user!.phone;
      imageUploader.proofOfResidenceUrl = widget.user!.proofOfResidenceUrl!;
      imageUploader.logoUrl = widget.user!.profile;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool isVerifying = false;
  bool isOtpVerified = false;

  Future<void> _verifyPhone() async {
    setState(() {
      isVerifying = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Get.snackbar('Success', 'Phone number verified');
        setState(() {
          verificationId = '';
          isVerifying = false;
          isOtpVerified = true;
          controller.getUserData();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar('Error', e.message ?? 'Phone number verification failed');
        setState(() {
          isVerifying = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          isVerifying = false;
        });
        Get.snackbar('OTP Sent', 'Please check your phone for the OTP');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
          isVerifying = false;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (verificationId == null || _otpController.text.isEmpty) return;

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: _otpController.text,
    );

    try {
      await _auth.signInWithCredential(credential);
      Get.snackbar('Success', 'Phone number verified');
      setState(() {
        isOtpVerified = true;
      });
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserController());
    return Scaffold(
      appBar: AppBar(
        title: ReusableText(
          text: "Profile",
          style: appStyle(20, kDark, FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: controller.isLoading ? null : () async {
              if (_emailController.text.isNotEmpty &&
                  _nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty &&
                  imageUploader.logoUrl.isNotEmpty) {

                UpdateProfile model = UpdateProfile(
                  username: _nameController.text,
                  email: _emailController.text,
                  proofOfResidenceUrl: imageUploader.proofOfResidenceUrl,
                  phone: _phoneController.text,
                  profile: imageUploader.logoUrl,
                );

                String userdata = updateProfileToJson(model);

                await controller.updateUser(userdata);
              }
            },
            child: Obx(() => controller.isLoading
                ? const CircularProgressIndicator()
                : const Text("Save", style: TextStyle(color: Colors.green))),
          )

        ],
      ),
      body: Center(child: BackGroundContainer(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      imageUploader.pickImage("logo");
                    },
                    child: Badge(
                      backgroundColor: Colors.transparent,
                      label: Obx(
                            () => imageUploader.logoUrl.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            imageUploader.logoUrl = '';
                          },
                          child: const Icon(Icons.remove_circle, color: kRed),
                        ) : Container(),
                      ),

                      child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: Obx(
                            () => imageUploader.isLoading && imageUploader.imageBeingUploaded.value == "logo"
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LoadingAnimationWidget.threeArchedCircle(
                                color: kSecondary,
                                size: 35,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${(imageUploader.uploadProgress * 100).toStringAsFixed(0)}%",  // Display the percentage
                                style: appStyle(16, kDark, FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                            : ClipOval(
                          child: Image.network(
                            imageUploader.logoUrl.isNotEmpty
                                ? imageUploader.logoUrl
                                : widget.user?.profile ?? '',
                            fit: BoxFit.cover,
                            width: 80, // Ensure it matches CircleAvatar's diameter
                            height: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.green),
                    onPressed: () {
                      imageUploader.pickImage("logo");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EmailTextField(
              hintText: "Name",
              controller: _nameController,
              prefixIcon: Icon(
                CupertinoIcons.person,
                color: Theme.of(context).dividerColor,
                size: 20 ,
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            EmailTextField(
              hintText: "Email",
              controller: _emailController,
              prefixIcon: Icon(
                CupertinoIcons.mail,
                color: Theme.of(context).dividerColor,
                size: 20 ,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EmailTextField(
                    hintText: "Phone",
                    controller: _phoneController,
                    prefixIcon: Icon(
                      CupertinoIcons.phone,
                      color: Theme.of(context).dividerColor,
                      size: 20,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 8),
                widget.user!.phoneVerification == false
                    ? ElevatedButton(
                  onPressed: isVerifying ? null : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.0,
                  ),
                  child: isVerifying
                      ? LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.white,
                    size: 24,
                  )
                      : const Text('Verify'),
                )
                    : const Row(
                  children: [
                    Text("Verified", style: TextStyle(color: Colors.lightGreen)),
                    Icon(Icons.check_circle, color: Colors.lightGreen),
                  ],
                ),
              ],
            ),
            if (verificationId != null && !isOtpVerified) ...[
              SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  prefixIcon: Icon(CupertinoIcons.lock, color: Theme.of(context).dividerColor, size: 20),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Text('Verify OTP'),
                ),
              ),
            ],

            SizedBox(
              height: 15,
            ),
            ReusableText(
                text: "Upload documents",
                style: appStyle(16, kDark, FontWeight.bold)),
            ReusableText(
              text:
              "You can upload the picture of your house to be able to locate",
              style: appStyle(11, kGray, FontWeight.normal),
            ),
            ReusableText(
              text:
              "by our riders easily.",
              style: appStyle(11, kGray, FontWeight.normal),
            ),

            SizedBox(
              height: 10,
            ),

            Center(
              child: GestureDetector(
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
                      height: 120,
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
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 32),

            Center(
              child: TextButton(
                onPressed: () {
                  logOutcontroller.logout();
                },
                child: const Text(
                  "Log out",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      )),),
    floatingActionButton: FloatingActionButton(
    onPressed: _verifyPhone,
    child: Icon(Icons.phone),)
    );
  }
}

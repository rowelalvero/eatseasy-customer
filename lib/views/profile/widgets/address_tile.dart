import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/models/all_addresses.dart';
import 'package:eatseasy/views/profile/edit_address_page.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../controllers/address_controller.dart';

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.refetch, // Add refetch parameter
  });

  final AddressesList address;
  final VoidCallback refetch; // Define refetch as a callback
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    // Store a local reference to the context
    final localContext = context;

    return GestureDetector(
        onTap: () {
          Get.to(() => UpdateAddressPage(address: address));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: height * .08,
          width: width,
          decoration: const BoxDecoration(
              color: kLightWhite,
              borderRadius: BorderRadius.all(Radius.circular(9))),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.0.r),
                  child: Icon(
                    SimpleLineIcons.location_pin,
                    color: kPrimary,
                    size: 28.h,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: width * 0.53,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      ReusableText(
                        text: address.addressName,
                        style: appStyle(13, kGray, FontWeight.w600),
                      ),
                      ReusableText(
                        text: address.addressLine1,
                        style: appStyle(11, kGray, FontWeight.w500),
                      ),
                      ReusableText(
                        text: address.postalCode,
                        style: appStyle(11, kGray, FontWeight.normal),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: address.addressesListDefault,
                  onChanged: (bool value) {
                    // Show confirmation dialog before setting the default address
                    showDialog(
                      context: localContext, // Use localContext here
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Set Default Address'),
                          content: const Text('Are you sure you want to set this as your default address?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(localContext).pop(); // Close the dialog if the user cancels
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(localContext).pop(); // Close the confirmation dialog

                                // Show a loading indicator while setting the default address
                                showDialog(
                                  context: localContext, // Use localContext here
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: LoadingAnimationWidget.threeArchedCircle(
                                        color: kPrimary,
                                        size: 35
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // Set the default address
                                  await controller.setDefaultAddress(address.id);

                                  // Wait for refetch to complete
                                  refetch();
                                } catch (error) {
                                  // Handle any error during the process
                                  print("Error: $error");
                                } finally {
                                  // Close the loading dialog after refetch completes
                                  Navigator.of(localContext).pop();
                                }
                              },
                              child: const Text('Set Default', style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return kPrimary.withOpacity(.48);
                    }
                    return kPrimary;
                  }),
                  activeColor: kCupertinoModalBarrierColor,
                ),
                IconButton(
                  onPressed: () async {
                    // Show confirmation dialog before deleting
                    final confirmed = await showDialog<bool>(
                      context: localContext, // Use localContext here
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Address'),
                          content: const Text('Are you sure you want to delete this address?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(localContext).pop(false); // Close the dialog with false
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(localContext).pop(true); // Close the dialog with true
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      // Show loading indicator while deleting
                      showDialog(
                        context: localContext, // Use localContext here
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: kPrimary,
                              size: 35
                            ),
                          );
                        },
                      );

                      try {
                        // Proceed with deleting the address
                        await controller.deleteAddress(address.id);

                        // Wait for refetch to complete
                        refetch();
                      } catch (error) {
                        // Handle error if something goes wrong
                        print("Error: $error");
                      } finally {
                        // Close the loading dialog after refetch completes
                        Navigator.of(localContext).pop();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        )
    );
  }
}


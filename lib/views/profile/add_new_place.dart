import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/back_ground_container.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/address_controller.dart';
import 'package:eatseasy/controllers/location_controller.dart';
import 'package:eatseasy/models/address_request.dart';
import 'package:eatseasy/models/environment.dart';
import 'package:eatseasy/views/home/widgets/custom_btn.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import 'saved_places.dart';

class AddNewPlace extends StatefulWidget {
  const AddNewPlace({super.key, this.update});
  final bool? update;
  @override
  State<AddNewPlace> createState() => _AddNewPlaceState();
}

class _AddNewPlaceState extends State<AddNewPlace> {
  final TextEditingController _searchController = TextEditingController();
  late PageController _pageController = PageController(initialPage: 0);
  GoogleMapController? _mapController;
  final box = GetStorage();
  final location = Get.put(UserLocationController());
  final controller = Get.put(UserLocationController());
  final addressController = Get.put(AddressController());

  @override
  void initState() {
    super.initState();
    _determinePosition();
    controller.currentIndex = 0;
    _pageController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _name.dispose();
    _postalCodeRes.dispose();
    _pageController.dispose();
    super.dispose();
  }


  List<dynamic> _placeList = [];
  final List<dynamic> _selectedPlace = [];

  LatLng? _selectedLocation;

  Future<void> _determinePosition() async {
    if (!await _checkLocationServices()) return;

    await _showLocationPermission();
  }

  Future<bool> _checkLocationServices() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false; // Location services are disabled.
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return permission != LocationPermission.deniedForever; // Location permissions are permanently denied.
  }

  Future<void> _showLocationPermission() async {
    // Request location permission
    var status = await Permission.location.request();

    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied) {
      // Permission denied, show a message
      print("Location permission denied. Unable to access location.");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _selectedLocation = LatLng(currentLocation.latitude, currentLocation.longitude);
      location.getAddressFromLatLng(_selectedLocation!);

      _searchController.text = location.address;
      _postalCodeRes.text = location.postalCode;

      if (_selectedLocation != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 16.0,
            ),
          ),
        );
      }
    });
  }

  void _onSearchChanged(String searchQuery) async {
    if (searchQuery.isNotEmpty) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchQuery&key=${Environment.googleApiKey2}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      }
    } else {
      setState(() {
        _placeList = [];
      });
    }
  }

  void _getPlaceDetail(String placeId) async {
    final detailUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Environment.googleApiKey2}');
    final detailResponse = await http.get(detailUrl);

    if (detailResponse.statusCode == 200) {
      final responseBody = json.decode(detailResponse.body);

      // Extracting latitude and longitude
      final lat = responseBody['result']['geometry']['location']['lat'];
      final lng = responseBody['result']['geometry']['location']['lng'];

      // Extracting the formatted address
      final address = responseBody['result']['formatted_address'];

      // Extracting the postal code
      String postalCode = "";
      final addressComponents = responseBody['result']['address_components'];
      for (var component in addressComponents) {
        if (component['types'].contains('postal_code')) {
          postalCode = component['long_name'];
          break;
        }
      }

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _searchController.text = address;
        _postalCodeRes.text = postalCode;
        moveToSelectedLocation();
        _placeList = [];
      });
    }
  }

  void moveToSelectedLocation() {
    if (_selectedLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 16.0, // You can adjust the zoom level
          ),
        ),
      );
    }
  }

  void _onMarkerDragEnd(LatLng newPosition) async {
    setState(() {
      _selectedLocation = newPosition;
    });

    final reverseGeocodeUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${newPosition.latitude},${newPosition.longitude}&key=${Environment.googleApiKey2}');

    final response = await http.get(reverseGeocodeUrl);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Extracting the formatted address
      final address = responseBody['results'][0]['formatted_address'];

      // Extracting the postal code
      String postalCode = "";
      final addressComponents =
          responseBody['results'][0]['address_components'];
      for (var component in addressComponents) {
        if (component['types'].contains('postal_code')) {
          postalCode = component['long_name'];
          break;
        }
      }

      // Update the state with the new address and postal code
      setState(() {
        _searchController.text = address;
        _postalCodeRes.text = postalCode;
      });
    } else {
      // Handle the error or no result case
      print('Failed to fetch address');
    }
  }

  String restaurantAddress = "";
  final TextEditingController _postalCodeRes = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _instructions = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: controller.currentIndex == 0 ?
        Container(
          height: 50, // Adjust the height as necessary
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light grey background for text field
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Enter a location",
              border: InputBorder.none, // Remove default borders
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          )
        ) :
        ReusableText(
          text: "Add new place",
          style: appStyle(20, kDark, FontWeight.w400),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Obx(
          () => Padding(
            padding: EdgeInsets.only(right: 0.w),
            child: controller.currentIndex == 0
                ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: kDark),
              onPressed: () {
                Get.back();
              },
            )

                : IconButton(
                    onPressed: () {
                      controller.currentIndex = 0;
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
              icon: const Icon(Icons.arrow_back_rounded, color: kDark),
                  ),
          ),
        ),
      ),
      body: Center(
        child: BackGroundContainer(
          child: SizedBox(
            height: height,
            width: width,
            child: PageView(
              controller: _pageController,
              pageSnapping: false,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                _pageController.jumpToPage(index);
              },
              children: [
                Container(
                  color: kGrayLight,
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? const LatLng(37.77483, -122.41942), // Default location
                          zoom: 15.0,
                        ),
                        markers: _selectedLocation == null
                            ? Set.of([])
                            : {
                          /*Marker(
                            markerId: const MarkerId('Your Location'),
                            position: _selectedLocation!,
                            draggable: false,
                          )*/
                        },
                        onCameraMove: (position) {
                          setState(() {
                            _selectedLocation = position.target;
                          });
                        },
                        onCameraIdle: () {
                          if (_selectedLocation != null) {
                            _onMarkerDragEnd(_selectedLocation!);
                          }
                        },
                      ),
                      const Center(
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      Column(
                        children: [
                          _placeList.isEmpty
                              ? const SizedBox.shrink()
                              : Expanded(
                                  child: ListView(
                                    children: List.generate(
                                      _placeList.length,
                                      (index) {
                                        return Container(
                                          color: Colors.white,
                                          child: ListTile(
                                            visualDensity: VisualDensity.compact,
                                            title: Text(
                                                _placeList[index]['description']),
                                            onTap: () {
                                              _getPlaceDetail(
                                                  _placeList[index]['place_id']);
                                              _selectedPlace.add(_placeList[index]);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: BackGroundContainer(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        _buildtextfield(
                          hintText: "Name",
                          controller: _name,
                          onSubmitted: (value) {},
                        ),
                        _buildtextfield(
                          hintText: "Postal Code",
                          controller: _postalCodeRes,
                          onSubmitted: (value) {},
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        _buildtextfield(
                          hintText: "Address",
                          controller: _searchController,
                          onSubmitted: (value) {},
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        _buildtextfield(
                          hintText: "Delivery Instructions",
                          controller: _instructions,
                          onSubmitted: (value) {},
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Set this address as default",
                                    style:
                                        appStyle(12, kDark, FontWeight.w500)),
                                Obx(() => Switch.adaptive(
                                  value: controller.defaultAddress,
                                  onChanged: (value) {
                                    controller.defaultAddress = value;
                                  },
                                  thumbColor: MaterialStateProperty. resolveWith<Color>((Set<MaterialState> states) {
                                    if (states. contains(MaterialState. disabled)) {
                                      return kPrimary. withOpacity(.48);
                                    }
                                    return kPrimary;
                                  }),
                                  activeColor: kCupertinoModalBarrierColor,
                                ),),

                              ]),
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

      bottomSheet: buildBottomSheet(context),
    );
  }
  Widget buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures the container takes only the space it needs
        children: [
          controller.currentIndex == 1
              ? const SizedBox.shrink()
              : Container(
                width: width,
                decoration: const BoxDecoration(
                    color: kOffWhite,
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                child: // Priority Option
                // Standard Option
                ListTile(
                  leading: const Icon(Icons.location_on, color: kPrimary),
                  title: Text(location.city),
                  subtitle: Text(_searchController.text),
                  trailing: IconButton(onPressed: () {_determinePosition();}, icon: const Icon(Icons.gps_fixed_rounded)),
                ),
              ),
          const SizedBox(height: 14),
          addressController.isLoading ?
          Center(
            child: LoadingAnimationWidget.waveDots(
              color: kPrimary,
              size: 35
            ),
          )
          : widget.update == true
          ? CustomButton(
            onTap: () {
              if (_selectedLocation != null) {
                // Collect the necessary data, like the address and location
                final updatedAddress = {
                  "address": _searchController.text,
                  "latitude": _selectedLocation!.latitude,
                  "longitude": _selectedLocation!.longitude,
                  "postalCode": _postalCodeRes.text,
                };

                // Return the updated address to the previous screen
                Navigator.pop(context, updatedAddress);
              }

            },
            radius: 24,
            color: kPrimary,
            btnWidth: width * 0.90,
            btnHieght: 50.h,
            text: "Save Address",
          )
          : CustomButton(
            onTap: () {
              if (controller.currentIndex == 1) {
                if (_searchController.text.isNotEmpty &&
                    _postalCodeRes.text.isNotEmpty &&
                    _instructions.text.isNotEmpty &&
                    _name.text.isNotEmpty) {
                  AddressRequest address = AddressRequest(
                      addressName: _name.text,
                      addressLine1: _searchController.text,
                      postalCode: _postalCodeRes.text,
                      latitude: _selectedLocation!.latitude,
                      longitude: _selectedLocation!.longitude,
                      addressRequestDefault: controller.defaultAddress,
                      deliveryInstructions: _instructions.text);

                  String addressData = addressRequestToJson(address);

                  addressController.addAddress(addressData);
                  Navigator.pop(context, true);
                } else {
                  Get.snackbar(
                      "Error", "Please fill all the fields to continue",
                      colorText: kLightWhite,
                      backgroundColor: kRed,
                      icon: const Icon(Icons.error));
                }
              } else {
                controller.currentIndex = 1;
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              }
            },
            radius: 24,
            color: kPrimary,
            btnWidth: width * 0.90,
            btnHieght: 50.h,
            text: controller.currentIndex == 1
                ? 'Submit'
                : 'Choose This Location',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _buildtextfield extends StatelessWidget {
  const _buildtextfield({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.onSubmitted,
    this.keyboard,
    this.readOnly,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboard;
  final void Function(String)? onSubmitted;
  final bool? readOnly;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: TextField(
          keyboardType: keyboard,
          readOnly: readOnly ?? false,
          decoration: InputDecoration(
              hintText: hintText,
              // contentPadding: EdgeInsets.only(left: 24),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kRed, width: 0.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimary, width: 0.5),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kRed, width: 0.5),
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kGray, width: 0.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kGray, width: 0.5),
              ),
              border: const OutlineInputBorder(),),
          controller: controller,
          cursorHeight: 25,
          style: appStyle(12, kDark, FontWeight.normal),
          onSubmitted: onSubmitted),
    );
  }
}

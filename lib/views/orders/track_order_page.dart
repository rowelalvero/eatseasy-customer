
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:food_icons/food_icons.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../common/app_style.dart';
import '../../common/divida.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../controllers/driverId_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/distance_time.dart';
import '../../models/environment.dart';
import '../../services/distance.dart';
import '../home/widgets/custom_btn.dart';
import '../restaurant/restaurants_page.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key, required this.orderId });
  final String orderId;
  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final controller = Get.put(OrderController());
  //final driverController = Get.put(DriverController());

  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinatesToRestaurant = [];
  List<LatLng> polylineCoordinatesToClient = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  DistanceTime? distanceTime1;
  DistanceTime? distanceTime2;
  LatLng? _previousPosition;
  late StreamSubscription<LatLng?> _trackPositionStream;
  late LatLng _restaurant;
  late LatLng _client;
  late LatLng _rider;

  @override
  void initState() {
    super.initState();
    //_fetchDriverId();
    _initializeOrderTracking();
    //_fetchDriverLocationAndOrderStatus();
  }

  @override
  void dispose() {
    mapController?.dispose();
    _trackPositionStream.cancel();
    super.dispose();
  }

  Future<void> _initializeOrderTracking() async {
    await _getOrderData();
    await _initializeCoordinates();
    await _trackRiderLocation();
  }

  /*Future<void> _fetchDriverLocationAndOrderStatus() async {
    //await driverController.fetchDriverData(widget.orderId);
    await driverController.fetchOrderStatus(widget.orderId);
  }*/

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getOrderData() async {
    await controller.getOrderDetails(widget.orderId);
  }

  Future<void> _initializeCoordinates() async {
    if (!_isOrderInInitialStatus()) {
      _rider = LatLng(controller.getOrder!.driverId!.currentLocation!.latitude!, controller.getOrder!.driverId!.currentLocation!.latitude!);
    }
    if (controller.getOrder != null) {
      setState(() {
        _restaurant = LatLng(controller.getOrder!.restaurantCoords![0], controller.getOrder!.restaurantCoords![1]);
        _client = LatLng(controller.getOrder!.recipientCoords![0], controller.getOrder!.recipientCoords![1]);
      });
      _addMarkers();
      _getPolylines();
    }
  }

  bool _isOrderInInitialStatus() {
    return ["Placed", "Preparing", "Ready"].contains(controller.getOrder!.orderStatus);
  }

  Future<void> _trackRiderLocation() async {
    _trackPositionStream = Stream.periodic(const Duration(seconds: 15)).asyncMap((_) async {
      await _getOrderData();
      controller.updateOrderStatus(controller.getOrder!.orderStatus!);

      if (controller.getOrder?.driverId != null && controller.getOrder?.driverId?.currentLocation != null) {
        _initializeCoordinates();
        fetchDistances();
        LatLng newPosition = LatLng(
            controller.getOrder!.driverId!.currentLocation!.latitude!,
            controller.getOrder!.driverId!.currentLocation!.longitude!
        );
        controller.updateLocation(newPosition);
        return newPosition;
      } else {
        // Return a fallback or skip updating until driverId is set
        return null;
      }
    }).listen((newPosition) {
      if (newPosition != null && !_isOrderInInitialStatus()) {
        if (_previousPosition != newPosition) {
          setState(() {
            _rider = newPosition;
            _updateMarker("rider_location", _rider);

            // Update polylines based on order status
            if (controller.getOrder!.orderStatus == 'Out_for_Delivery') {
              fetchDistance1();
            } else if (controller.getOrder!.driverId != null) {
              fetchDistance2();
            }
          });
        }
      }
    });
  }

  void _addMarkers() async {
    await _addMarker(_restaurant, "restaurant_location");
    await _addMarker(_client, "client_location");
    if (!_isOrderInInitialStatus()) {
      await _addMarker(_rider, "rider_location");
    }
  }

  Future<void> _addMarker(LatLng position, String id) async {
    final markerId = MarkerId(id);
    BitmapDescriptor markerIcon = await _getMarkerIcon(id);

    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: markerIcon,
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<BitmapDescriptor> _getMarkerIcon(String id) async {
    String assetPath;
    switch (id) {
      case "restaurant_location":
        assetPath = 'assets/images/restaurant_marker.png';
        break;
      case "client_location":
        assetPath = 'assets/images/client_marker.png';
        break;
      default:
        assetPath = 'assets/images/rider_marker.png';
        break;
    }

    try {
      return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)), // Adjust as needed
        assetPath,
      );
    } catch (e) {
      print("Error loading marker icon for $id: $e");
      return BitmapDescriptor.defaultMarker; // Use default if custom icon fails
    }
  }

  void _updateMarker(String id, LatLng position) {
    final markerId = MarkerId(id);
    if (markers.containsKey(markerId)) {
      setState(() {
        markers[markerId] = markers[markerId]!.copyWith(positionParam: position);
      });
    }
  }

  Future<void> _getPolylines() async {
    await _getPolyline(_restaurant, _client, "restaurant_to_client", Colors.lightGreen);
  }

  Future<void> _getPolyline(LatLng origin, LatLng destination, String polylineId, Color color) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Environment.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.status == 'OK') {
      List<LatLng> polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      setState(() {
        polylines[PolylineId(polylineId)] = Polyline(
          polylineId: PolylineId(polylineId),
          color: color,
          points: polylineCoordinates,
          width: 6,
        );
      });
    }
  }

  Future<void> fetchDistances() async {
    await Future.wait([fetchDistance1(), fetchDistance2()]);
  }

  Future<void> fetchDistance1() async {
    Distance distanceCalculator = Distance();
    distanceTime1 = distanceCalculator.calculateDistanceTimePrice(
      _rider.latitude,
      _rider.longitude,
      controller.getOrder!.recipientCoords![0],
      controller.getOrder!.recipientCoords![1],
      35,
      pricePkm,
    );
    if (mounted) setState(() {});
  }

  Future<void> fetchDistance2() async {
    Distance distanceCalculator = Distance();
    distanceTime2 = distanceCalculator.calculateDistanceTimePrice(
      _rider.latitude,
      _rider.longitude,
      controller.getOrder!.restaurantCoords![0],
      controller.getOrder!.restaurantCoords![1],
      35,
      pricePkm,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return controller.isLoading
        ? Center(
      child: SizedBox(
          width: 150,
          height: 150,
          child: LoadingAnimationWidget.threeArchedCircle(
              color: kSecondary,
              size: 35
          )
      ),
    )
        : Obx(() {
      if (["Accepted", "Out_for_Delivery"].contains(controller.orderStatus)) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kLightWhite,
            elevation: 0.3,
            centerTitle: true,
            title: ReusableText(
              text: widget.orderId,
              style: appStyle(20, kDark, FontWeight.w400),
            ),
          ),
          body: Stack(
            children: [
              // Google Maps widget as the background
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _onMapCreated(controller);  // Ensure the controller is saved for dynamic updates
                },
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _rider,
                  zoom: 14.0,
                  bearing: 0,
                  tilt: 0,
                ),
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
                padding: const EdgeInsets.only(bottom: 150),
              ),

              // Button to trigger the modal bottom sheet
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: CustomButton(
                  radius: 24,
                  color: kPrimary,
                  btnWidth: width * 0.90,
                  btnHieght: 50.h,
                  text: "Show Order Details",
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      //backgroundColor: Colors.transparent,
                      showDragHandle: true,
                      barrierColor: kGrayLight.withOpacity(0.2),
                      isScrollControlled: true,  // Allows it to expand fully if needed
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                      ),
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.65,  // Set height for modal
                          child: buildOrderContainer(
                            context,
                            ScrollController(),
                            MediaQuery.of(context).size.width,
                            controller,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kLightWhite,
            centerTitle: true,
            title: ReusableText(
              text: widget.orderId,
              style: appStyle(20, kDark, FontWeight.w400),
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: kLightWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildStatusContainer(width, controller),
                if (!_isOrderInInitialStatus())
                  buildDriverContainer(width, controller),
                buildOrderSummaryContainer(width, controller),
                buildLocationContainer(width, controller),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget buildOrderContainer(BuildContext context, ScrollController scrollController, double width, OrderController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStatusContainer(width, controller),
            if (!_isOrderInInitialStatus())
              buildDriverContainer(width, controller),
            buildOrderSummaryContainer(width, controller),
            buildLocationContainer(width, controller),
          ],
        ),
      ),
    );
  }
  Widget buildStatusContainer(double width, OrderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: kLightWhite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        width: width,
        decoration: const BoxDecoration(
            color: kOffWhite,
            borderRadius: BorderRadius.all(Radius.circular(9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.getOrder!.orderStatus == 'Placed'
                ? ReusableText(
                text: "Waiting for the kitchen to accept your order",
                style: appStyle(20, kDark, FontWeight.w400))
                : controller.getOrder!.orderStatus == 'Preparing' || controller.getOrder!.orderStatus == 'Ready'
                ? ReusableText(
                text: "Kitchen's preparing your order",
                style: appStyle(20, kDark, FontWeight.w400))
                : ReusableText(
                text: "Order is out for delivery!",
                style: appStyle(20, kDark, FontWeight.w400)),
            SizedBox(height: 10.h),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const Expanded(
                  child: Icon(
                    Icons.task_rounded,
                    color: kPrimary,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 5.0, // Adjust height as desired
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0), // Rounded corners
                        gradient: ["Preparing", "Ready", "Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? const LinearGradient(
                          colors: [kPrimary, kSecondary], // Gradient colors
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                            : null
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.0), // Ensure corners stay rounded
                      child: LinearProgressIndicator(
                        backgroundColor: ["Preparing", "Ready", "Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? Colors.transparent : null, // Transparent background to see gradient
                        value: ["Preparing", "Ready", "Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? 1
                            : null, // Stop animation if condition is met
                        valueColor: AlwaysStoppedAnimation<Color>(["Placed"].contains(controller.orderStatus)
                            ? kPrimary : Colors.transparent,),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.fastfood_rounded,
                    color: ["Preparing", "Ready", "Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                        ? kPrimary : kGray,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 5.0, // Adjust height as desired
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0), // Rounded corners
                        gradient: ["Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? const LinearGradient(
                          colors: [kPrimary, kSecondary], // Gradient colors
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                            : null
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.0), // Ensure corners stay rounded
                      child: LinearProgressIndicator(
                        backgroundColor: ["Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? Colors.transparent : null, // Transparent background to see gradient
                        value: ["Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                            ? 1
                            : null, // Stop animation if condition is met
                        valueColor: AlwaysStoppedAnimation<Color>(["Preparing", "Ready"].contains(controller.orderStatus)
                            ? kPrimary : Colors.transparent),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.motorcycle_rounded,
                    color: ["Accepted", "Out_for_Delivery", "Delivered"].contains(controller.orderStatus)
                        ? kPrimary : kGray,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 5.0, // Adjust height as desired
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0), // Rounded corners
                        gradient: ["Delivered"].contains(controller.orderStatus)
                            ? const LinearGradient(
                          colors: [kPrimary, kSecondary], // Gradient colors
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ) : null
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.0), // Ensure corners stay rounded
                      child: LinearProgressIndicator(
                        backgroundColor: ["Delivered"].contains(controller.orderStatus)
                            ? Colors.transparent : null, // Transparent background to see gradient
                        value: ["Delivered"].contains(controller.orderStatus)
                            ? 1
                            : null, // Stop animation if condition is met
                        valueColor: AlwaysStoppedAnimation<Color>(["Accepted", "Out_for_Delivery"].contains(controller.orderStatus)
                            ? kPrimary : Colors.transparent,),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.person_pin,
                    color: ["Delivered"].contains(controller.orderStatus)
                        ? kPrimary : kGray,
                    size: 20,
                  ),
                ),
              ],
            )
            )
          ],
        ),
      ),
    );
  }
  Widget buildDriverContainer(double width, OrderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: kLightWhite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        width: width,
        decoration: const BoxDecoration(
            color: kOffWhite,
            borderRadius: BorderRadius.all(Radius.circular(9))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: kTertiary,
              backgroundImage: NetworkImage(controller.getOrder!.driverId!.driver!.profile!),
            ),
            SizedBox(width: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                    text: controller.getOrder!.driverId!.driver!.username!,
                    style: appStyle(16, kDark, FontWeight.w600)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ReusableText(
                        text: controller.getOrder!.driverId!.vehicleNumber!,
                        style: appStyle(11, kDark, FontWeight.w400)),
                    SizedBox(width: 5.h),
                    ReusableText(
                        text: '•',
                        style: appStyle(11, kDark, FontWeight.w400)),
                    SizedBox(width: 5.h),
                    ReusableText(
                        text: controller.getOrder!.driverId!.driver!.id!,
                        style: appStyle(11, kDark, FontWeight.w400))
                  ],
                )
              ],
            )
          ],
        )
      ),
    );
  }
  Widget buildOrderSummaryContainer(double width, OrderController controller) {
    return Container(
      color: kLightWhite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        width: width,
        decoration: const BoxDecoration(
            color: kOffWhite,
            borderRadius: BorderRadius.all(Radius.circular(9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReusableText(
                text: "${controller.getOrder?.restaurantId?.title}",
                style: appStyle(20, kDark, FontWeight.w400)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RowText(
                  first: "Delivery fee",
                  second: controller.getOrder != null
                      ? "\Php ${controller.getOrder?.deliveryFee?.toStringAsFixed(2)}"
                      : "Loading...",
                ),
                SizedBox(height: 5.h),
                RowText(
                  first: "Subtotal",
                  second: controller.getOrder != null
                      ? "\Php ${controller.getOrder?.orderTotal.toStringAsFixed(2)}"
                      : "Loading...",
                ),
                const Divida(),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total: ",
                      style: TextStyle(
                        color: kDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        controller.getOrder == null
                            ? Container()
                            : Padding(
                          padding: const EdgeInsets.all(0),
                          child: Text(
                            controller.getOrder != null
                                ? "\Php ${controller.getOrder?.grandTotal.toStringAsFixed(2)}"
                                : "",
                            style: const TextStyle(
                              color: kDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget buildLocationContainer(double width, OrderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: kLightWhite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: const BoxDecoration(
          color: kOffWhite,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Entypo.location_pin,
                  color: Colors.lightGreen,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText(
                          text: "${controller.getOrder?.restaurantId?.title}",
                          style: appStyle(15, kDark, FontWeight.w400)),
                      const SizedBox(width: 10),
                      ReusableText(
                          text: "${controller.getOrder?.restaurantId!.coords!.address!}",
                          style: appStyle(10, kDark, FontWeight.w400)),
                    ],
                  ),
                )
              ],
            ),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Entypo.dots_three_vertical,
                    color: kGray,
                    size: 20,
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Entypo.location_pin,
                  color: kPrimary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                        text: "${controller.getOrder?.userId?.phone}",
                        style: appStyle(15, kDark, FontWeight.w400)),
                    const SizedBox(width: 10),
                    ReusableText(
                        text: "${controller.getOrder?.deliveryAddress?.addressLine1}",
                        style: appStyle(10, kDark, FontWeight.w400)),
                  ],
                ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

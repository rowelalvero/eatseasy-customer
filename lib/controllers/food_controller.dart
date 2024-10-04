import 'package:eatseasy/models/foods.dart';
import 'package:eatseasy/models/obs_additives.dart';
import 'package:get/get.dart';

class FoodController extends GetxController {
  var additivesList = <ObsAdditive>[].obs;
  final RxDouble _totalPrice = 0.0.obs;
  bool initialCheckedValue = false;
  List<String> ads = [];

   var currentPage = 0.obs;

  void updatePage(int index) {
    currentPage.value = index;
  }

  void loadAdditives(List<Additive> addittives) {
    additivesList.clear();
    for (var additiveInfo in addittives) {
      var additive = ObsAdditive(
        id: additiveInfo.id,
        title: additiveInfo.title,
        price: additiveInfo.price,
        checked: initialCheckedValue,
      );
      if (addittives.length == additivesList.length) {
      } else {
        additivesList.add(additive);
      }
    }
  }

  double getTotalPrice() {
    double totalPrice = 0.0;
    for (var additive in additivesList) {
      if (additive.isChecked.value) {
        totalPrice += double.tryParse(additive.price) ?? 0.0;
      }
    }
    setAdditveTotal = totalPrice;
    return totalPrice;
  }

  List<String> getList() {
    List<String> ads = [];
    for (var additive in additivesList) {
      if (additive.isChecked.value && !ads.contains(additive.title)) {
        ads.add(additive.title);
      }else if(!additive.isChecked.value && ads.contains(additive.title)){
        ads.remove(additive.title);
      }
    }
    
    return ads;
  }

  double get additiveTotal => _totalPrice.value;

  // Setter to set the value
  set setAdditveTotal(double newValue) {
    _totalPrice.value = newValue;
  }


}

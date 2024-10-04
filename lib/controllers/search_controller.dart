import 'package:eatseasy/models/environment.dart';
import 'package:eatseasy/models/foods.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FoodSearchController extends GetxController {
  final _searchQuery = 'initial value'.obs;

  String get searchQuery => _searchQuery.value;

  set setSearchQuery(String newValue) {
    _searchQuery.value = newValue;
  }

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  List<Food>? searchResults;

  void searchFoods(String key) async {
    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/foods/search/$key');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setLoading = false;
        searchResults = foodFromJson(response.body);
        
        return;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setLoading = false;
      rethrow;
    } finally {
      setLoading = false;
    }
  }
}

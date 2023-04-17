import 'package:pantry_manager_ui/src/models/grocery_list_item.dart';

class PagedData<T> {
  final int count;
  List<T> data;

  PagedData({
    required this.count,
    required this.data,
  });

  @override
  String toString() {
    return "count: $count, data: $data";
  }

  factory PagedData.fromJson(Map<String, dynamic> jsonData) {
    var count = jsonData["count"];

    if (T == GroceryListItem) {
      dynamic list = (jsonData['data'] as List)
          .map((data) => GroceryListItem.fromJson(data))
          .toList();

      return PagedData(
        count: count,
        data: list,
      );
    } else {
      return PagedData(
        count: 0,
        data: List<T>.empty(),
      );
    }
  }
}

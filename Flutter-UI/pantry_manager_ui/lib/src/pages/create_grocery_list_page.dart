import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/create_grocery_item.dart';
import '../models/grocery_list_item.dart';
import '../servics/groceries_service.dart';
import '../views/grocery/grocery_list_view.dart';

class CreateGroceryListPage extends StatefulWidget {
  const CreateGroceryListPage({super.key});

  @override
  State<CreateGroceryListPage> createState() => _CreateGroceryListPageState();
}

class _CreateGroceryListPageState extends State<CreateGroceryListPage> {
  Future<List<GroceryListItem>> _getData = getAllInventory();

  final List<CreateGroceryItem> _groceryItems = List.empty();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const Center(
            child: Text("Create Grocery List"),
          ),
          FutureBuilder<List<GroceryListItem>>(
              future: _getData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  for (var item in snapshot.data!) {
                    _groceryItems.add(CreateGroceryItem(
                        upc: item.upc,
                        quantity: item.quantity,
                        shopped: item.shopped,
                        standardQuantity: item.standardQuantity,
                        count: item.count));
                  }

                  return Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Column(
                      children: [
                        _groceryItems.isNotEmpty
                            ? Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Item"),
                                      Text("On Hand"),
                                      Text("# to Purchase"),
                                    ],
                                  ),
                                  ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: _groceryItems.length,
                                    padding: const EdgeInsets.all(8),
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(_groceryItems[index].label ??
                                              "N/A"),
                                          Text(_groceryItems[index]
                                              .count
                                              .toString()),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _groceryItems[index]
                                                          .quantity++;
                                                    });
                                                  },
                                                  child: const Text("+")),
                                              Text(_groceryItems[index]
                                                  .quantity
                                                  .toString()),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _groceryItems[index]
                                                          .quantity--;

                                                      if (_groceryItems[index]
                                                              .quantity <
                                                          0) {
                                                        _groceryItems[index]
                                                            .quantity = 0;
                                                      }
                                                    });
                                                  },
                                                  child: const Text("-")),
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const Text("No items to update for grocery list"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GroceryListView()));
                                },
                                child: const Text("Done")),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _getData = getAllInventory();
                                  });
                                },
                                child: const Text("Reset")),
                            ElevatedButton(
                                onPressed: () async {
                                  for (var item in _groceryItems) {
                                    await http.post(Uri.parse(
                                        "http://docker-database.localdomain:8000/pantry-manager/groceries/set-quantity/${item.upc}/${item.quantity}"));
                                  }

                                  setState(() {
                                    _getData = getAllInventory();
                                  });
                                },
                                child: const Text("Save")),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Text("loading...");
                }
              }),
        ],
      ),
    );
  }
}

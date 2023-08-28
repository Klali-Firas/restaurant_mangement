import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;
import 'package:restaurant_mangement/utility/toast.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  bool _orderPlaced = false;
  Map<String, String> imagesURLs = {};
  Map<String, dynamic> orders = {};
  List<int> itemCounts = [];
  double totalPrice = 0.0;
  double paycheck = -1;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String id = args["id"];
    if (paycheck == -1) {
      paycheck = args["paycheck"];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Order"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildOrderSummary(),
          _buildOrderListView(),
          const SizedBox(height: 5),
          _buildMenuListView(),
          const SizedBox(height: 3),
          _buildConfirmButton(id),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Orders:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Expanded(child: Text("")),
          Text(
            totalPrice.toStringAsFixed(3),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const Text(
            " DT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderListView() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(index);
        },
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    final menuItemKey = orders.keys.elementAt(index);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        elevation: 4,
        child: SizedBox(
          width: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(9), topLeft: Radius.circular(9)),
                child: CachedNetworkImage(
                  imageUrl: imagesURLs[menuItemKey].toString(),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(9),
                        bottomRight: Radius.circular(9))),
                alignment: Alignment.center,
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "${orders[menuItemKey]} x $menuItemKey",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuListView() {
    return Expanded(
      child: StreamBuilder(
        stream: realtimedatabase.getData("Menu").onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = (snapshot.data!.snapshot).value;
          if (data == null) {
            return const Center(child: Text("No data available."));
          }

          final menuItems =
              Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
          if (itemCounts.isEmpty) {
            itemCounts = List.filled(menuItems.length, 0);
          }

          imagesURLs.clear();
          _initializeURLs(menuItems);

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final menuItemKey = menuItems.keys.elementAt(index);
              final menuItem = menuItems[menuItemKey];
              return _buildMenuItem(menuItem, menuItemKey, index);
            },
          );
        },
      ),
    );
  }

  void _initializeURLs(Map<String, dynamic> menuItems) {
    menuItems.forEach((key, value) {
      if (value != null && value is Map) {
        String imageURL = value["image"];
        if (imageURL != null) {
          imagesURLs[key] = imageURL;
        }
      }
    });
  }

  Widget _buildMenuItem(menuItem, menuItemKey, index) {
    final menuItemIndex = index; // Store the current index
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
        child: Card(
          elevation: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildMenuItemImage(menuItem),
              _buildMenuItemInfo(menuItemKey, menuItem),
              const Expanded(child: SizedBox()),
              _buildItemCountControls(menuItemKey, menuItem,
                  menuItemIndex), // Pass the menuItemIndex
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemImage(menuItem) {
    return SizedBox(
      height: 60,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7), bottomLeft: Radius.circular(7)),
        child: CachedNetworkImage(
          imageUrl: menuItem["image"].toString(),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemInfo(menuItemKey, menuItem) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(menuItemKey,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${menuItem["price"].toStringAsFixed(3)} DT")
          ]),
    );
  }

  Widget _buildItemCountControls(menuItemKey, menuItem, int menuItemIndex) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.teal),
          onPressed: _orderPlaced
              ? null
              : () => _updateItemCount(menuItem, menuItemIndex, menuItemKey,
                  isIncrement: false),
        ),
        Text(itemCounts[menuItemIndex]
            .toString()), // Use menuItemIndex instead of index
        IconButton(
          icon: const Icon(Icons.add, color: Colors.teal),
          onPressed: _orderPlaced
              ? null
              : () => _updateItemCount(menuItem, menuItemIndex, menuItemKey,
                  isIncrement: true),
        ),
      ],
    );
  }

  void _updateItemCount(menuItem, index, menuItemKey,
      {required bool isIncrement}) {
    setState(() {
      if (isIncrement) {
        itemCounts[index]++;
        totalPrice += menuItem["price"];
      } else if (itemCounts[index] > 0) {
        itemCounts[index]--;
        totalPrice -= menuItem["price"];
      }
      _updateOrder(menuItemKey, itemCounts[index]);
    });
  }

  void _updateOrder(menuItemKey, itemCount) {
    if (itemCount > 0) {
      orders[menuItemKey] = itemCount;
    } else {
      orders.remove(menuItemKey);
    }
  }

  Widget _buildConfirmButton(String id) {
    return ElevatedButton(
      onPressed: _orderPlaced
          ? null
          : () async {
              if (orders.isNotEmpty) {
                var time = DateTime.now().millisecondsSinceEpoch.toString();
                setState(() {
                  _orderPlaced = true;
                });
                await _saveOrderToDatabase(id, paycheck, time);
                // Order successful, reset orders and enable icons
                setState(() {
                  orders.clear();
                  itemCounts = List.filled(itemCounts.length, 0);
                  paycheck += totalPrice;
                  totalPrice = 0.0;
                });
                // Enable icons back after a delay (you can customize this delay)
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    _orderPlaced = false;
                  });
                });
              }
            },
      child: const Text(
        "Confirm Order",
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Future<void> _saveOrderToDatabase(
      String id, double paycheck, String time) async {
    await realtimedatabase.addData("Tables/$id/Orders/${"${id}_$time"}", {
      "orders": orders,
      'done': false,
      "ready": false,
      "served": false,
      "price": totalPrice,
      "orderDate": time,
    });

    await realtimedatabase.updateData("Tables/$id", {
      "paycheck": paycheck + totalPrice,
      "paid": false,
      "empty": false,
    });
    showToast("Order placed Successfully");
  }
}

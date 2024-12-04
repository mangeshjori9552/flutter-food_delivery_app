import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/screens/order_detailed_screen.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
   String _selectedCategory = 'All Orders';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    /// Get current users email
    final userEmail = FirebaseAuth.instance.currentUser!.email; 
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore
        .collection('Users')
        .doc(userEmail)
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      orders = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = orders
        .where((order) =>
            _selectedCategory == 'All Orders' ||
            order['status'] == _selectedCategory)
        .toList();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: primaryButtonColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Text(
                    "No orders placed yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Horizontal Scroll for Categories
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryButton(
                    text: "All Orders",
                    isSelected: _selectedCategory == 'All Orders',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'All Orders';
                      });
                    },
                  ),
                  CategoryButton(
                    text: "Active",
                    isSelected: _selectedCategory == 'Active',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Active';
                      });
                    },
                  ),
                  CategoryButton(
                    text: "Completed",
                    isSelected: _selectedCategory == 'Completed',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Completed';
                      });
                    },
                  ),
                  CategoryButton(
                    text: "Cancelled",
                    isSelected: _selectedCategory == 'Cancelled',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Cancelled';
                      });
                    },
                  ),
                ],
              ),
            ),
              Expanded(
                child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      var order = filteredOrders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(order: order),
                            ),
                          );
                        },
                        child: OrderCard(orderDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(order['timestamp'].toDate()),
                         price: order['totalAmount'].toStringAsFixed(2),
                          status: order['status'],
                           orderId: order['id']),
                        //Card(
                        //   margin: const EdgeInsets.all(8.0),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(16.0),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text("Order ID: ${order['id']}"),
                        //         Text("Order Date: ${order['timestamp'].toDate()}"),
                        //         Text("Status: ${order['status']}"),
                        //         Text("Total Price: \$${order['totalAmount'].toStringAsFixed(2)}"),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      );
                    },
                  ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? primaryButtonColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black87 : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderDate;
  final String price;
  final String status;
  final String orderId;

  const OrderCard({
    super.key,
    required this.orderDate,
    required this.price,
    required this.status,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (Sessiondata.profilePhoto != "")
                        ? Image.network(
                            Sessiondata.profilePhoto,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person, size: 100),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Order Date: $orderDate",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.blueGrey)),
                  const SizedBox(height: 5),
                  Text("Order ID: $orderId",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text("Price: \$${price}",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      fontSize: 14,
                      color: status == "Cancelled"
                          ? Colors.red
                          : (status == "Completed" ? Colors.green : Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   String _selectedCategory = 'All Orders';

//   List<Map<String, dynamic>> orders = [
//     {
//       'orderDate': '2024-11-18',
//       'imagePath': 'assets/images/pizza.png',
//       'itemName': 'Pizza Margherita',
//       'quantity': 2,
//       'price': 19.99,
//       'status': 'Active',
//     },
//     {
//       'orderDate': '2024-11-15',
//       'imagePath': 'assets/images/pizza.png',
//       'itemName': 'Grilled Sandwich',
//       'quantity': 1,
//       'price': 9.99,
//       'status': 'Completed',
//     },
//     {
//       'orderDate': '2024-11-10',
//       'imagePath': 'assets/images/pizza.png',
//       'itemName': 'Chicken Wrap',
//       'quantity': 1,
//       'price': 12.99,
//       'status': 'Cancelled',
//     },
//     // Add more orders as needed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     List<Map<String, dynamic>> filteredOrders = orders
//         .where((order) =>
//             _selectedCategory == 'All Orders' ||
//             order['status'] == _selectedCategory)
//         .toList();

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.black38,
//         title: const Text("Orders",style: TextStyle(color: primaryTextColor,fontSize: 24,fontWeight: FontWeight.w500),),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             // Horizontal Scroll for Categories
//             SizedBox(
//               height: 50,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   CategoryButton(
//                     text: "All Orders",
//                     isSelected: _selectedCategory == 'All Orders',
//                     onTap: () {
//                       setState(() {
//                         _selectedCategory = 'All Orders';
//                       });
//                     },
//                   ),
//                   CategoryButton(
//                     text: "Active",
//                     isSelected: _selectedCategory == 'Active',
//                     onTap: () {
//                       setState(() {
//                         _selectedCategory = 'Active';
//                       });
//                     },
//                   ),
//                   CategoryButton(
//                     text: "Completed",
//                     isSelected: _selectedCategory == 'Completed',
//                     onTap: () {
//                       setState(() {
//                         _selectedCategory = 'Completed';
//                       });
//                     },
//                   ),
//                   CategoryButton(
//                     text: "Cancelled",
//                     isSelected: _selectedCategory == 'Cancelled',
//                     onTap: () {
//                       setState(() {
//                         _selectedCategory = 'Cancelled';
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Order List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredOrders.length,
//                 itemBuilder: (context, index) {
//                   var order = filteredOrders[index];
//                   return GestureDetector(
//                     onTap: () {
//                       if (order['status'] == 'Active') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 OrderDetailsPage(order: order),
//                           ),
//                         );
//                       } else {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 OrderSummaryPage(order: order),
//                           ),
//                         );
//                       }
//                     },
//                     child: OrderCard(
//                       orderDate: order['orderDate'],
//                       imagePath: order['imagePath'],
//                       itemName: order['itemName'],
//                       quantity: order['quantity'],
//                       price: order['price'],
//                       status: order['status'],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CategoryButton extends StatelessWidget {
//   final String text;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const CategoryButton({
//     super.key,
//     required this.text,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         margin: const EdgeInsets.symmetric(horizontal: 5),
//         decoration: BoxDecoration(
//           color: isSelected ? primaryButtonColor : Colors.grey[300],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Center(
//           child: Text(
//             text,
//             style: TextStyle(
//               color: isSelected ? Colors.black87 : Colors.black45,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OrderCard extends StatelessWidget {
//   final String orderDate;
//   final String imagePath;
//   final String itemName;
//   final int quantity;
//   final double price;
//   final String status;

//   const OrderCard({
//     super.key,
//     required this.orderDate,
//     required this.imagePath,
//     required this.itemName,
//     required this.quantity,
//     required this.price,
//     required this.status,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(
//                 imagePath,
//                 height: 80,
//                 width: 80,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     itemName,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   Text("Order Date: $orderDate",
//                       style: const TextStyle(
//                           fontSize: 12, color: Colors.blueGrey)),
//                   const SizedBox(height: 5),
//                   Text("Quantity: $quantity",
//                       style: const TextStyle(fontSize: 14)),
//                   const SizedBox(height: 5),
//                   Text("Price: \$${price.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 5),
//                   Text(
//                     "Status: $status",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: status == "Cancelled"
//                           ? Colors.red
//                           : (status == "Completed" ? Colors.green : Colors.blue),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OrderDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> order;

//   const OrderDetailsPage({super.key, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(order['itemName']),
//         backgroundColor: Colors.orange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.asset(
//               order['imagePath'],
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 20),
//             Text("Order Date: ${order['orderDate']}", style: const TextStyle(fontSize: 16)),
//             Text("Quantity: ${order['quantity']}", style: const TextStyle(fontSize: 16)),
//             Text("Price: \$${order['price']}", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 10),
//             Text("Tracking Details:", style: const TextStyle(fontSize: 18)),
//             Text("Tracking Number: XYZ12345", style: const TextStyle(fontSize: 16)),
//             Text("Status: In Transit", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle cancel order action here
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) => AlertDialog(
//                     title: const Text("Cancel Order"),
//                     content: const Text("Are you sure you want to cancel this order?"),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text("No"),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // Handle cancel order action here
//                           Navigator.pop(context);
//                           Navigator.pop(context); // Go back to OrdersScreen
//                         },
//                         child: const Text("Yes"),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               child: const Text("Cancel Order"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OrderSummaryPage extends StatelessWidget {
//   final Map<String, dynamic> order;

//   const OrderSummaryPage({super.key, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(order['itemName']),
//         backgroundColor: Colors.orange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.asset(
//               order['imagePath'],
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 20),
//             Text("Order Date: ${order['orderDate']}", style: const TextStyle(fontSize: 16)),
//             Text("Quantity: ${order['quantity']}", style: const TextStyle(fontSize: 16)),
//             Text("Price: \$${order['price']}", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 10),
//             Text("Status: ${order['status']}", style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }

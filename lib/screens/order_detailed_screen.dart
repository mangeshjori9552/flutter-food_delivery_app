import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie/constants/constants.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late int currentStatusIndex;
  bool isOrderCancelled = false;

  final List<String> statusMessages = [
    "Order has been confirmed by the hotel",
    "Food is being prepared",
    "Delivery partner has been selected",
    "Delivery partner has arrived at the hotel",
    "Food is ready to pick up",
    "Food has been collected by the delivery partner",
    "Delivery partner is en route to your address",
    "Delivery partner has arrived at your location",
    "Order has been successfully delivered"
  ];

  @override
  void initState() {
    super.initState();
    currentStatusIndex = statusMessages.indexOf(widget.order['status']);
    if (currentStatusIndex == -1) currentStatusIndex = 0;
    if (widget.order['status'] == "Active") _simulateOrderProgress();
  }

  Future<void> _simulateOrderProgress() async {
    while (currentStatusIndex < statusMessages.length - 1 && !isOrderCancelled) {
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) {
        setState(() {
          currentStatusIndex++;
          widget.order['status'] = statusMessages[currentStatusIndex];
        });
        await _updateOrderStatus();
      }
    }
    if (currentStatusIndex == statusMessages.length - 1) {
      await _completeOrder();
    }
  }

  Future<void> _addNotification(String message) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
  await userDocRef.collection('notifications').add({
    'message': message,
    'timestamp': Timestamp.now(),
    'orderId': widget.order['id'],
  });
}


  Future<void> _updateOrderStatus() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final orderRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('orders')
        .doc(widget.order['id']);

    await orderRef.update({'status': statusMessages[currentStatusIndex]});
    await _addNotification(statusMessages[currentStatusIndex]);

  }

  Future<void> _completeOrder() async {
    setState(() {
      widget.order['status'] = "Completed";
    });
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final orderRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('orders')
        .doc(widget.order['id']);
    await orderRef.update({'status': "Completed"});
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() {
      isOrderCancelled = true;
      widget.order['status'] = "Cancelled";
    });
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final orderRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('orders')
        .doc(widget.order['id']);
    await orderRef.update({'status': "Cancelled", 'cancellationReason': reason});
    await _addNotification("Order ${widget.order['id']} has been cancelled: $reason");
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    final isActive = widget.order['status'] == "Active";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryButtonColor,
        title: const Text("Order Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${widget.order['id'] ?? ''}", style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Text("Order Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.order['timestamp'].toDate())}", style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            Text("Status: ${widget.order['status']?? ''}", style: const TextStyle(color: Colors.green, fontSize: 16)),
            const Divider(color: Colors.white),
            const Text("Items:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ...items.map((item) => ListTile(
                  leading: Image.asset(item['imagePath']),
                  title: Text(item['name'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text("Quantity: ${item['quantity']}", style: const TextStyle(color: Colors.grey)),
                )),
            const Divider(color: Colors.white),
            Text("Total: \$${widget.order['totalAmount']}", style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            if (isActive)
              Column(
                children: [
                  const Text("Order Progress", style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: currentStatusIndex / (statusMessages.length - 1),
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            if (isActive)
              ElevatedButton(
                onPressed: () => _showCancelBottomSheet(context),
                child: const Text("Cancel Order"),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cancel Order", style: TextStyle(color: Colors.white, fontSize: 18)),
              ListTile(
                title: const Text("Delayed Delivery", style: TextStyle(color: Colors.white)),
                onTap: () => _cancelOrder("Delayed Delivery"),
              ),
              ListTile(
                title: const Text("Wrong Order", style: TextStyle(color: Colors.white)),
                onTap: () => _cancelOrder("Wrong Order"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie/constants/constants.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  Stream<QuerySnapshot> _getUserNotifications() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryButtonColor,
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications available.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final message = notification['message'];
              final timestamp = (notification['timestamp'] as Timestamp).toDate();
              final orderId = notification['orderId'];
              final formattedTime = "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

              return ListTile(
                leading: const Icon(Icons.notifications, color: Colors.teal),
                title: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Order ID: $orderId\nReceived at $formattedTime",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

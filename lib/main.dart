import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Notification>> notifications;
  bool _areNotificationsVisible = false;  // Track if notifications are visible

  @override
  void initState() {
    super.initState();
    notifications = fetchNotifications(2);  // Replace with actual userId
  }

  // Function to fetch notifications
  Future<List<Notification>> fetchNotifications(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:7080/users/$userId/notifications'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List notificationsList = data['notifications'];
      return notificationsList.map((notification) => Notification.fromJson(notification)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Toggle button click handler
  void _toggleNotifications() {
    setState(() {
      _areNotificationsVisible = !_areNotificationsVisible; // Toggle the visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notification display'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleNotifications, // Toggle notifications on button press
                child: Text(_areNotificationsVisible ? 'Hide Notifications' : 'Show Notifications'),
              ),
              SizedBox(height: 20), // Space between button and list
              _areNotificationsVisible
                  ? FutureBuilder<List<Notification>>(
                future: notifications,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No notifications available.'));
                  } else {
                    final notifications = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: notifications.map((notification) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.green.shade300,
                                ),
                                borderRadius: BorderRadius.circular(15.0)
                            ),
                            child: ListTile(
                            title: Text(notification.message),
                            subtitle: Text('From: ${notification.mailId}\nMobile: ${notification.mobileNo}\nTime: ${notification.timestamp}'),
                          ),);
                        }).toList(),
                      ),
                    );
                  }
                },
              )
                  : Container(), // Show nothing if notifications are hidden
            ],
          ),
        ),
      ),
    );
  }
}

class Notification {
  final int id;
  final String mailId;
  final String message;
  final String mobileNo;
  final String timestamp;
  final int userId;

  Notification({
    required this.id,
    required this.mailId,
    required this.message,
    required this.mobileNo,
    required this.timestamp,
    required this.userId,
  });

  // Factory method to create Notification from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      mailId: json['mail_id'],
      message: json['message'],
      mobileNo: json['mobile_no'],
      timestamp: json['timestamp'],
      userId: json['user_id'],
    );
  }
}

void main() {
  runApp(MyApp());
}

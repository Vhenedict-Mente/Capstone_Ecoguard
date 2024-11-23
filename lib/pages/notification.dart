import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Sample notifications data for two feeders (empty initial data)
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Function to fetch notifications and feed levels
  Future<void> fetchNotifications() async {
    // Replace with your actual API URL
    final String apiUrl =
        "https://ecoguard.cc.nf/localconnect/get_feed_level.php";

    try {
      // Fetch feed levels for both location_ids
      for (int locationId = 1; locationId <= 2; locationId++) {
        final response =
            await http.get(Uri.parse('$apiUrl?location_id=$locationId'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final feedLevel =
              data['feed_level'] ?? 0; // Default to 0 if not provided

          // Determine the notification based on feed level
          setState(() {
            notifications.add({
              'location_id': locationId,
              'feed_level': feedLevel,
              'isRead': false,
              'title': feedLevel == 0
                  ? 'Feeder Refill Reminder'
                  : feedLevel < 10
                      ? 'Low Feed Level'
                      : 'Feed Level Full',
              'description': feedLevel == 0
                  ? 'Feeder $locationId is empty. Please refill immediately for optimal operation.'
                  : feedLevel < 10
                      ? 'Feeder $locationId is critically low on feed ($feedLevel%). Please refill soon.'
                      : 'Feeder $locationId is full and ready for operation. No refill needed.',
            });
          });
        } else {
          // Handle error (e.g., no internet, server error)
          print("Error fetching feed level for location_id $locationId");
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Function to dismiss notification
  void dismissNotification(int index) {
    setState(() {
      notifications.removeAt(index); // Completely remove the notification
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feeder Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 228, 228, 175),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off,
                        size: 100, color: Colors.black),
                    SizedBox(height: 20),
                    Text(
                      'No Notifications Yet!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                if (notification['isRead']) {
                  return SizedBox.shrink(); // Don't show read notifications
                }
                return Card(
                  color: Colors.yellow[100],
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading:
                        Icon(Icons.notification_important, color: Colors.black),
                    title: Text(
                      notification['title']!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification['description']!),
                    trailing: IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        dismissNotification(index); // Mark as read
                      },
                    ),
                  ),
                );
              },
            ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }
}

// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:ecoguard/pages/home.dart';
import 'package:ecoguard/pages/sensor.dart';
import 'package:ecoguard/pages/surveillance.dart';
import 'package:ecoguard/pages/production.dart';
import 'package:ecoguard/pages/track_record.dart';
import 'notification.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class FeederPage extends StatefulWidget {
  @override
  _FeederPageState createState() => _FeederPageState();
}

class _FeederPageState extends State<FeederPage> {
  bool fanStatus = false;
  int feeder1Level = 0;
  int feeder2Level = 0;
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Fetch levels for both feeders when the widget is initialized
    fetchFeedLevel(1);
    fetchFeedLevel(2);

    // Set up periodic refresh every 5 seconds
    autoRefreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchFeedLevel(1);
      fetchFeedLevel(2);
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchFeedLevel(int locationId) async {
    try {
      // Send a GET request to your backend API, passing location_id as a query parameter
      final response = await http.get(Uri.parse(
          'http://192.168.100.146/localconnect/get_feed_level.php?location_id=$locationId'));

      if (response.statusCode == 200) {
        // Parse the response body if the request is successful
        var data = jsonDecode(response.body);
        int feedLevel =
            data['feed_level'] ?? 0; // Default to 0 if no data is returned

        setState(() {
          if (locationId == 1) {
            feeder1Level = feedLevel;
          } else if (locationId == 2) {
            feeder2Level = feedLevel;
          }
        });

        print('Feed level for location $locationId: $feedLevel');
      } else {
        print(
            'Failed to fetch feed level for location $locationId. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print(
          'Error fetching feed level for location $locationId: $e, uri=http://192.168.100.146/localconnect/get_feed_level.php?location_id=$locationId');
    }
  }

  // Function to control the fan relay
  Future<void> toggleFan() async {
    // Replace with your ESP-01 IP address
    String espIp = 'http://192.168.1.37'; // Update to your ESP IP address
    String command = fanStatus ? 'OFF' : 'ON';
    String url = '$espIp/$command'; // Appends /ON or /OFF to the ESP URL

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          fanStatus = !fanStatus; // Toggle the fan status
        });
        print('Success: Fan turned ${command}');
      } else {
        print('Failed to send command. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Status',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(248, 252, 249, 111),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(248, 252, 249, 111),
              ),
              child: Text(
                'ECOGUARD',
                style: TextStyle(
                    color: Color.fromARGB(255, 55, 122, 38),
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _createDrawerItem(
              icon: Icons.dashboard,
              text: 'Dashboard',
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
              fontWeight: FontWeight.bold,
            ),
            _createDrawerItem(
              icon: Icons.sensors,
              text: 'Sensor',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SensorPage()));
              },
              fontWeight: FontWeight.bold,
            ),
            _createDrawerItem(
              icon: Icons.videocam,
              text: 'Surveillance',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SurveillancePage()));
              },
              fontWeight: FontWeight.bold,
            ),
            _createDrawerItem(
              icon: Icons.broadcast_on_home,
              text: 'Device Status',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FeederPage()));
              },
              fontWeight: FontWeight.bold,
            ),
            _createDrawerItem(
              icon: Icons.all_inbox_rounded,
              text: 'Production',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductionPage()));
              },
              fontWeight: FontWeight.bold,
            ),
            _createDrawerItem(
              icon: Icons.assessment,
              text: 'Track Record',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TrackRecordPage()));
              },
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _fanControlWidget(),
            SizedBox(height: 20),
            _feederLevelWidget('Feeder 1 Feed Level:', feeder1Level),
            SizedBox(height: 20),
            _feederLevelWidget('Feeder 2 Feed Level:', feeder2Level),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(248, 236, 236, 236),
    );
  }

  Widget _fanControlWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(248, 252, 249, 111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fan Status:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: fanStatus,
            onChanged: (value) {
              toggleFan();
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red[200],
          ),
          Text(
            fanStatus ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fanStatus ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feederLevelWidget(String feederName, int feedLevel) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(248, 252, 249, 111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feederName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 20, // Height of the rectangle
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5), // Rounded corners
              child: LinearProgressIndicator(
                value: feedLevel /
                    100, // Convert percentage to a value between 0 and 1
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  feedLevel >= 70
                      ? Colors.green
                      : feedLevel >= 30
                          ? Colors.yellow
                          : Colors.red,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '$feedLevel%', // Display the feed level percentage as an integer
            style: TextStyle(
              fontSize: 24, // Adjusted size for better visibility
              fontWeight: FontWeight.bold,
              color: feedLevel >= 70
                  ? Colors.green
                  : feedLevel >= 30
                      ? Colors.yellow[800]
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _createDrawerItem(
    {required IconData icon,
    required String text,
    GestureTapCallback? onTap,
    FontWeight? fontWeight}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
      ),
    ),
    onTap: onTap,
  );
}

// ignore_for_file: prefer_const_constructors

import 'package:ecoguard/pages/sensor.dart';
import 'package:ecoguard/pages/surveillance.dart';
import 'package:ecoguard/pages/feeder.dart';
import 'package:ecoguard/pages/production.dart';
import 'package:ecoguard/pages/track_record.dart';
import 'notification.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double temperatureGH = 0.00; // Growing House Temperature
  double temperatureCP = 0.00;
  int feeder1Level = 0;
  int feeder2Level = 0; // Chicken Pen Temperature
  List<Map<String, String>> productionData = [];
  List<Map<String, String>> buildingData = [];
  final Map<String, Map<String, dynamic>> _buildings = {
    "Building A": {
      "totalChicken": 0,
      "currentChicken": 0, // Initialized to totalChicken
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
    "Building B": {
      "totalChicken": 0,
      "currentChicken": 0,
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
    "Building C": {
      "totalChicken": 0,
      "currentChicken": 0,
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
    "Building D": {
      "totalChicken": 0,
      "currentChicken": 0,
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
    "Building E": {
      "totalChicken": 0,
      "currentChicken": 0,
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
    "Building F": {
      "totalChicken": 0,
      "currentChicken": 0,
      "deaths": 0,
      "mortalityRate": 0.0,
      "feedGrams": 0,
      "feedSupply": 0,
      "feedConsumptionRate": 0.0
    },
  };

  @override
  void initState() {
    super.initState();
    fetchTemperatures(); // Fetch temperatures when the page initializes
    fetchProductionData(); // Fetch production data when the page initializes
    _fetchBuildingData(); // Fetch building data
    fetchFeedLevel(1);
    fetchFeedLevel(2);
  }

  Future<void> fetchFeedLevel(int locationId) async {
    try {
      // Send a GET request to your backend API, passing location_id as a query parameter
      final response = await http.get(Uri.parse(
          'https://ecoguard.cc.nf/localconnect/get_feed_level.php?location_id=$locationId'));

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
          'Error fetching feed level for location $locationId: $e, uri=https://ecoguard.cc.nf/get_feed_level.php?location_id=$locationId');
    }
  }

  Future<void> fetchTemperatures() async {
    // Fetch temperature data for Growing House
    final responseGH = await http.get(Uri.parse(
        'https://ecoguard.cc.nf/localconnect/fetch_sensor_data.php?location_ID=1'));
    // Fetch temperature data for Chicken Pen
    final responseCP = await http.get(Uri.parse(
        'https://ecoguard.cc.nf/localconnect/fetch_sensor_data.php?location_ID=2'));

    if (responseGH.statusCode == 200 && responseCP.statusCode == 200) {
      final dataGH = json.decode(responseGH.body);
      final dataCP = json.decode(responseCP.body);
      setState(() {
        temperatureGH =
            double.tryParse(dataGH['temperature'].toString()) ?? 0.00;
        temperatureCP =
            double.tryParse(dataCP['temperature'].toString()) ?? 0.00;
      });
    } else {
      print(
          'Failed to load temperatures: ${responseGH.statusCode}, ${responseCP.statusCode}');
    }
  }

  Future<void> fetchProductionData() async {
    final response = await http.get(Uri.parse(
        'https://ecoguard.cc.nf/localconnect/fetch_production_data.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        productionData = data
            .map((item) => {
                  'date': item['date'].toString(),
                  'eggs': item['eggs'].toString(),
                  'eggType': item['eggType'].toString(),
                })
            .toList();
      });
    } else {
      print('Failed to load production data: ${response.statusCode}');
    }
  }

  Future<void> _fetchBuildingData() async {
    try {
      var response = await http.get(
        Uri.parse('https://ecoguard.cc.nf/localconnect/fetch_buildings.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> buildings = json.decode(response.body);

        setState(() {
          for (var building in buildings) {
            String buildingName = building['building_name'];
            if (_buildings.containsKey(buildingName)) {
              int totalChicken = int.parse(building['total_chicken']);
              int deaths = int.parse(building['deaths']);
              int currentChicken = totalChicken - deaths;

              // Update building data only if fetched data is different
              _buildings[buildingName] = {
                'totalChicken': totalChicken,
                'currentChicken': currentChicken,
                'deaths': deaths,
                'mortalityRate': double.parse(building['mortality_rate']),
                'feedGrams': int.parse(building['feed_grams']),
                'feedSupply': int.parse(building['feed_supply']),
                'feedConsumptionRate':
                    double.parse(building['feed_consumption_rate']),
              };
            }
          }
        });
      } else {
        print('Failed to load building data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load building data from server.'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
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
                    MaterialPageRoute(builder: (context) => HomePage()));
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
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusCard('Temperature in GH:', '$temperatureGH °C',
                      Icons.thermostat),
                  _buildStatusCard('Temperature in CP:', '$temperatureCP °C',
                      Icons.thermostat),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusCard(
                      'Feeder 1 Status:', '$feeder1Level %', Icons.all_inbox_rounded),
                  _buildStatusCard(
                      'Feeder 2 Status:', '$feeder2Level %', Icons.all_inbox_rounded),
                ],
              ),
              Card(
                color: Color.fromARGB(255, 228, 228, 175),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Egg Production:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200, // Adjust the height to fit your design
                        child: SingleChildScrollView(
                          child: Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(children: [
                                Center(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Date'))),
                                Center(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Number of Eggs'))),
                                Center(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Egg Type'))),
                              ]),
                              ...productionData
                                  .map((item) => TableRow(children: [
                                        Center(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(item['date']!))),
                                        Center(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(item['eggs']!))),
                                        Center(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(item['eggType']!))),
                                      ]))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300, // Set the desired height for the container

                child: ListView(
                  children: [
                    for (var buildingName in _buildings.keys)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: Color.fromARGB(255, 228, 228, 175),
                        child: ListTile(
                          title: Text(
                            buildingName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Chickens: ${_buildings[buildingName]!['totalChicken']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Current Chickens: ${_buildings[buildingName]!['currentChicken']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Feed Grams per Chicken: ${_buildings[buildingName]!['feedGrams']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Feed Supply: ${_buildings[buildingName]!['feedSupply']} grams',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Feed Consumption Rate: ${_buildings[buildingName]!['feedConsumptionRate'].toStringAsFixed(2)} grams/day',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Deaths: ${_buildings[buildingName]!['deaths']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Mortality Rate: ${_buildings[buildingName]!['mortalityRate'].toStringAsFixed(2)}%',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ), // Define what happens when a building card is tapped, like navigating to a detailed page
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon,
      [Color? color]) {
    return Expanded(
      child: Card(
        color: Color.fromARGB(255, 228, 228, 175),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Icon(icon, size: 30, color: color ?? Colors.black),
              const SizedBox(height: 5),
              Text(
                status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      FontWeight fontWeight = FontWeight.normal}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: TextStyle(fontWeight: fontWeight)),
      onTap: onTap,
    );
  }
}

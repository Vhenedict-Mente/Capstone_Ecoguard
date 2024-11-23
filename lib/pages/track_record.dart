// ignore_for_file: prefer_const_constructors

import 'package:ecoguard/pages/home.dart';
import 'package:ecoguard/pages/sensor.dart';
import 'package:ecoguard/pages/feeder.dart';
import 'package:ecoguard/pages/production.dart';
import 'package:ecoguard/pages/surveillance.dart';
import 'notification.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackRecordPage extends StatefulWidget {
  const TrackRecordPage({super.key});

  @override
  State<TrackRecordPage> createState() => _TrackRecordPageState();
}

class _TrackRecordPageState extends State<TrackRecordPage> {
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

  // State for selected building
  String? _selectedBuilding;
  final TextEditingController _totalChickenController = TextEditingController();
  final TextEditingController _feedGramsController = TextEditingController();
  final TextEditingController _feedSupplyController = TextEditingController();

  // Function to edit deaths and recalculate mortality rate
  void _editDeaths(String building) {
    TextEditingController deathsController = TextEditingController(
      text: _buildings[building]!['deaths'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Deaths for $building'),
          content: TextField(
            controller: deathsController,
            decoration: InputDecoration(
              labelText: 'Number of Deaths',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int deaths = int.tryParse(deathsController.text) ?? 0;

                  // Ensure deaths do not exceed totalChicken
                  if (deaths > _buildings[building]!['totalChicken']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Deaths cannot exceed total number of chickens.'),
                      ),
                    );
                    return;
                  }

                  _buildings[building]!['deaths'] = deaths;
                  _buildings[building]!['currentChicken'] =
                      _buildings[building]!['totalChicken'] - deaths;

                  _calculateMortalityRate(building);
                  _calculateFeedConsumptionRate(building);
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate mortality rate
  void _calculateMortalityRate(String building) {
    int totalChicken = _buildings[building]!['totalChicken'];
    int deaths = _buildings[building]!['deaths'];
    double mortalityRate =
        totalChicken > 0 ? (deaths / totalChicken) * 100 : 0.0;
    _buildings[building]!['mortalityRate'] =
        mortalityRate.isNaN ? 0.0 : mortalityRate;
  }

  // Function to calculate feed consumption rate
  void _calculateFeedConsumptionRate(String building) {
    int totalChicken = _buildings[building]!['totalChicken'];
    int feedGrams = _buildings[building]!['feedGrams'];
    int feedSupply = _buildings[building]!['feedSupply'];

    double consumptionRate =
        feedSupply > 0 ? (totalChicken * feedGrams) / feedSupply : 0.0;
    _buildings[building]!['feedConsumptionRate'] =
        consumptionRate.isNaN ? 0.0 : consumptionRate;
  }

  // Function to handle input form submission
  Future<void> _submitData() async {
    if (_selectedBuilding != null) {
      setState(() {
        int totalChicken = int.tryParse(_totalChickenController.text) ?? 0;
        int feedGrams = int.tryParse(_feedGramsController.text) ?? 0;
        int feedSupply = int.tryParse(_feedSupplyController.text) ?? 0;

        _buildings[_selectedBuilding!]!['totalChicken'] = totalChicken;
        _buildings[_selectedBuilding!]!['currentChicken'] =
            totalChicken - _buildings[_selectedBuilding!]!['deaths'];
        _buildings[_selectedBuilding!]!['feedGrams'] = feedGrams;
        _buildings[_selectedBuilding!]!['feedSupply'] = feedSupply;

        _calculateMortalityRate(_selectedBuilding!);
        _calculateFeedConsumptionRate(_selectedBuilding!);
      });

      // Prepare data to send
      var data = {
        'building_name': _selectedBuilding!,
        'total_chicken':
            _buildings[_selectedBuilding!]!['totalChicken'].toString(),
        'deaths': _buildings[_selectedBuilding!]!['deaths'].toString(),
        'mortality_rate':
            _buildings[_selectedBuilding!]!['mortalityRate'].toString(),
        'feed_grams': _buildings[_selectedBuilding!]!['feedGrams'].toString(),
        'feed_supply': _buildings[_selectedBuilding!]!['feedSupply'].toString(),
        'feed_consumption_rate':
            _buildings[_selectedBuilding!]!['feedConsumptionRate'].toString(),
      };

      try {
        // Send POST request to PHP API
        var response = await http.post(
          Uri.parse('https://ecoguard.cc.nf/localconnect/insert_building.php'),
          body: data,
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  jsonResponse['message'] ?? 'Data submitted successfully.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Request failed with status: ${response.statusCode}.'),
            ),
          );
        }
      } catch (e) {
        // Handle network errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a building first.'),
        ),
      );
    }
  }

  // Function to fetch building data from the server
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
              if (_buildings[buildingName]!['totalChicken'] != totalChicken ||
                  _buildings[buildingName]!['deaths'] != deaths) {
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
  void initState() {
    super.initState();
    _fetchBuildingData();
  }

  // Widget to display building data
  Widget _buildDisplayContainer(String building, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Building color: Colors.yellow[200]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$building',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _editDeaths(building),
                icon: Icon(Icons.edit),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          // Building Details
          Wrap(
            spacing: screenWidth * 0.05,
            runSpacing: screenWidth * 0.02,
            children: [
              _buildDetailText('Total Chickens:',
                  '${_buildings[building]!['totalChicken']}', screenWidth),
              _buildDetailText('Current Chickens:',
                  '${_buildings[building]!['currentChicken']}', screenWidth),
              _buildDetailText('Feed Grams per Chicken:',
                  '${_buildings[building]!['feedGrams']}', screenWidth),
              _buildDetailText('Feed Supply:',
                  '${_buildings[building]!['feedSupply']} grams', screenWidth),
              _buildDetailText(
                  'Feed Consumption Rate:',
                  '${_buildings[building]!['feedConsumptionRate'].toStringAsFixed(2)}',
                  screenWidth),
              _buildDetailText(
                  'Deaths:', '${_buildings[building]!['deaths']}', screenWidth),
              _buildDetailText(
                  'Mortality Rate:',
                  '${_buildings[building]!['mortalityRate'].toStringAsFixed(2)}%',
                  screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailText(String label, String value, double screenWidth) {
    return Container(
      width: (screenWidth < 600) ? double.infinity : (screenWidth * 0.4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.04),
          children: [
            TextSpan(
                text: '$label ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _totalChickenController.dispose();
    _feedGramsController.dispose();
    _feedSupplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Define responsive padding
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chicken Track Record',
          style: TextStyle(
            color: Colors.black,
            fontSize: isPortrait ? 16 : 14,
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
        backgroundColor: Color.fromARGB(248, 252, 249, 111),
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
                  fontWeight: FontWeight.bold,
                ),
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
                // Prevent navigating to the same page again
                // Optionally, you can highlight the current page instead
              },
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use SingleChildScrollView to prevent overflow
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                children: [
                  // Input Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Building Selection Dropdown
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Building',
                              prefixIcon: Icon(Icons.house_siding_outlined),
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedBuilding,
                            items: _buildings.keys.map((building) {
                              return DropdownMenuItem<String>(
                                value: building,
                                child: Text(building),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBuilding = value;

                                // Initialize controllers with existing data
                                if (value != null &&
                                    _buildings.containsKey(value)) {
                                  _totalChickenController.text =
                                      _buildings[value]!['totalChicken']
                                          .toString();
                                  _feedGramsController.text =
                                      _buildings[value]!['feedGrams']
                                          .toString();
                                  _feedSupplyController.text =
                                      _buildings[value]!['feedSupply']
                                          .toString();
                                } else {
                                  _totalChickenController.clear();
                                  _feedGramsController.clear();
                                  _feedSupplyController.clear();
                                }
                              });
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Total Chickens Input
                          TextField(
                            controller: _totalChickenController,
                            decoration: InputDecoration(
                              labelText: 'Total Chickens',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.fact_check_outlined),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Feed Grams per Chicken Input
                          TextField(
                            controller: _feedGramsController,
                            decoration: InputDecoration(
                              labelText: 'Feed Grams per Chicken',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.scale),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Feed Supply Input
                          TextField(
                            controller: _feedSupplyController,
                            decoration: InputDecoration(
                              labelText: 'Feed Supply (grams)',
                              prefixIcon: Icon(Icons.kitchen),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          // Submit Button
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitData,
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.1,
                                    vertical: screenHeight * 0.015),
                                backgroundColor:
                                    Color.fromARGB(255, 240, 244, 247),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Data Display
                  // Display only if there are buildings
                  if (_buildings.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Building Data',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _buildings.keys.length,
                          itemBuilder: (context, index) {
                            String building = _buildings.keys.elementAt(index);
                            return _buildDisplayContainer(
                                building, screenWidth);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    FontWeight? fontWeight,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: TextStyle(fontWeight: fontWeight),
      ),
      onTap: onTap,
    );
  }
}

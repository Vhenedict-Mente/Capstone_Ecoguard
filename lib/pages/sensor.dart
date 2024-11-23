// ignore_for_file: prefer_const_constructors

import 'package:ecoguard/pages/home.dart';
import 'package:ecoguard/pages/surveillance.dart';
import 'package:ecoguard/pages/feeder.dart';
import 'package:ecoguard/pages/production.dart';
import 'package:ecoguard/pages/track_record.dart';
import 'notification.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:ecoguard/pages/sensor_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  double temperatureGH = 0.00; // Growing House Temperature
  double humidityGH = 0.00; // Growing House Humidity
  double co2GH = 0.00; // Growing House CO2
  double ammoniaGH = 0.00; // Growing House Ammonia

  double temperatureCP = 0.00; // Chicken Pen Temperature
  double humidityCP = 0.00; // Chicken Pen Humidity
  double co2CP = 0.00; // Chicken Pen CO2
  double ammoniaCP = 0.00; // Chicken Pen Ammonia

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchSensorData(1); // Fetch sensor data for Growing House
    fetchSensorData(2); // Fetch sensor data for Chicken Pen
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      fetchSensorData(1);
      fetchSensorData(2);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the page is disposed
    super.dispose();
  }

  Future<void> fetchSensorData(int locationID) async {
    final response = await http.get(Uri.parse(
        'https://ecoguard.cc.nf/localconnect/fetch_sensor_data.php?location_ID=$locationID'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // Print the API response for debugging

      setState(() {
        if (locationID == 1) {
          // Growing House
          temperatureGH =
              double.tryParse(data['temperature'].toString()) ?? 0.00;
          humidityGH = double.tryParse(data['humidity'].toString()) ?? 0.00;
          co2GH = double.tryParse(data['CO2ppm'].toString()) ?? 0.00;
          ammoniaGH = double.tryParse(data['NH3ppm'].toString()) ?? 0.00;
        } else if (locationID == 2) {
          // Chicken Pen
          temperatureCP =
              double.tryParse(data['temperature'].toString()) ?? 0.00;
          humidityCP = double.tryParse(data['humidity'].toString()) ?? 0.00;
          co2CP = double.tryParse(data['CO2ppm'].toString()) ?? 0.00;
          ammoniaCP = double.tryParse(data['NH3ppm'].toString()) ?? 0.00;
        }
      });
    } else {
      print('Failed to load sensor data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sensors',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      body: ListView(
        children: [
          SensorCard(
            environment: 'Growing House Environment',
            temperature: temperatureGH,
            humidity: humidityGH,
            co2: co2GH,
            ammonia: ammoniaGH,
          ),
          SensorCard(
            environment: 'Chicken Pen Environment',
            temperature: temperatureCP,
            humidity: humidityCP,
            co2: co2CP,
            ammonia: ammoniaCP,
          ),
          SensorHistoryGraph(),
        ],
      ),
      backgroundColor: Color.fromARGB(248, 236, 236, 236),
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

class SensorHistoryGraph extends StatefulWidget {
  @override
  _SensorHistoryGraphState createState() => _SensorHistoryGraphState();
}

class _SensorHistoryGraphState extends State<SensorHistoryGraph> {
  List<SensorData> growingHouseData = [];
  List<SensorData> chickenPenData = [];

  @override
  void initState() {
    super.initState();
    fetchSensorHistoryData();
  }

  Future<void> fetchSensorHistoryData() async {
    final response = await http.get(Uri.parse(
        'https://ecoguard.cc.nf/localconnect/fetch_sensor_history.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        growingHouseData = data
            .where((item) => item['locationID'] == 1)
            .map((item) => SensorData.fromJson(item))
            .toList();
        chickenPenData = data
            .where((item) => item['locationID'] == 2)
            .map((item) => SensorData.fromJson(item))
            .toList();
      });
    } else {
      print('Failed to load sensor history data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChart('Temperature', growingHouseData, chickenPenData,
            (data) => data.temperature),
        _buildChart('Humidity', growingHouseData, chickenPenData,
            (data) => data.humidity),
        _buildChart(
            'CO2 (ppm)', growingHouseData, chickenPenData, (data) => data.co2),
        _buildChart('Ammonia (ppm)', growingHouseData, chickenPenData,
            (data) => data.ammonia),
      ],
    );
  }

  Widget _buildChart(String title, List<SensorData> growingHouseData,
      List<SensorData> chickenPenData, double Function(SensorData) getValue) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      title: ChartTitle(text: title),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom, // Move the legend to the bottom
        alignment: ChartAlignment.center, // Center the legend at the bottom
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        LineSeries<SensorData, DateTime>(
          name: 'Growing House',
          dataSource: growingHouseData,
          xValueMapper: (SensorData data, _) => data.timestamp,
          yValueMapper: (SensorData data, _) => getValue(data) as num,
        ),
        LineSeries<SensorData, DateTime>(
          name: 'Chicken Pen',
          dataSource: chickenPenData,
          xValueMapper: (SensorData data, _) => data.timestamp,
          yValueMapper: (SensorData data, _) => getValue(data) as num,
        ),
      ],
    );
  }
}

class SensorData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double co2;
  final double ammonia;

  SensorData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.ammonia,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: double.parse(json['temperature'].toString()),
      humidity: double.parse(json['humidity'].toString()),
      co2: double.parse(json['co2'].toString()),
      ammonia: double.parse(json['ammonia'].toString()),
    );
  }
}

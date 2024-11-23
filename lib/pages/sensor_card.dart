// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String environment;
  final double temperature;
  final double humidity;
  final double co2;
  final double ammonia;

  SensorCard({
    super.key,
    required this.environment,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.ammonia,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color.fromARGB(248, 252, 249, 111),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              environment,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SensorDataGauge(
                  icon: Icons.thermostat,
                  value: temperature,
                  unit: '°C',
                  minValue: -20,
                  maxValue: 50,
                ),
                SensorDataGauge(
                  icon: Icons.water_drop,
                  value: humidity,
                  unit: '%',
                  minValue: 0,
                  maxValue: 100,
                ),
                SensorDataGauge(
                  icon: Icons.science,
                  value: ammonia,
                  unit: 'ppm',
                  minValue: 0,
                  maxValue: 50,
                ),
                SensorDataGauge(
                  icon: Icons.co2,
                  value: co2,
                  unit: 'ppm',
                  minValue: 0,
                  maxValue: 2000,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SensorDataGauge extends StatelessWidget {
  final IconData icon;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;

  SensorDataGauge({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (value - minValue) / (maxValue - minValue); // Normalize the value to range 0-1

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 79, 179, 54)),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${value.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(unit, style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        SizedBox(height: 5),
        Icon(icon, size: 30),
      ],
    );
  }
}

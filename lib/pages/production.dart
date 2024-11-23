// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'dart:convert';
import 'package:ecoguard/pages/home.dart';
import 'package:ecoguard/pages/sensor.dart';
import 'package:ecoguard/pages/surveillance.dart';
import 'package:ecoguard/pages/feeder.dart';
import 'package:ecoguard/pages/track_record.dart';
import 'notification.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _eggsController = TextEditingController();
  final TextEditingController _eggTypeController = TextEditingController();
  List<dynamic> productionDataList = [];
  bool isLoading = false;

  // Replace with your actual server IP or domain
  final String apiUrl =
      'https://ecoguard.cc.nf/localconnect/production.php'; // Use 10.0.2.2 for Android Emulator

  @override
  void initState() {
    super.initState();
    _fetchProductionData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _eggsController.dispose();
    _eggTypeController.dispose();
    super.dispose();
  }

  // Add this function to open the date picker and handle the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            picked.toIso8601String().split('T')[0]; // Format the date
      });
    }
  }

  // Function to fetch production data from the backend
  Future<void> _fetchProductionData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          productionDataList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load production data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching production data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  // Function to add new production data
  Future<void> _addProductionData(String date, int eggs, String eggType) async {
    if (date.isEmpty || eggs <= 0 || eggType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid data')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'add',
          'date': date,
          'eggs': eggs.toString(),
          'eggType': eggType, // Add eggType to the request body
        },
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _fetchProductionData();
          _clearInputFields();
        } else if (result['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
        }
      } else {
        throw Exception('Failed to add production data');
      }
    } catch (e) {
      print('Error adding production data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $e')),
      );
    }
  }

  // Function to edit existing production data
  Future<void> _editProductionData(id, date, eggs, eggType) async {
    if (date.isEmpty || eggs <= 0 || eggType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid data')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'edit',
          'id': id.toString(),
          'date': date,
          'eggs': eggs.toString(),
          'eggType': eggType, // Add eggType to the request body
        },
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _fetchProductionData();
        } else if (result['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
        }
      } else {
        throw Exception('Failed to edit production data');
      }
    } catch (e) {
      print('Error editing production data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing data: $e')),
      );
    }
  }

  // Function to delete production data
  Future<void> _deleteProductionData(int id) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'delete',
          'id': id.toString(),
        },
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _fetchProductionData(); // Refresh data
        } else if (result['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
        }
      } else {
        throw Exception('Failed to delete production data');
      }
    } catch (e) {
      print('Error deleting production data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
    }
  }

  // Function to show the edit dialog
  // Function to show the edit dialog
  void _showEditDialog(
      int id, String currentDate, int currentEggs, String currentEggType) {
    _dateController.text = currentDate;
    _eggsController.text = currentEggs.toString();
    _eggTypeController.text = currentEggType; // Add eggType to the text field

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Production Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date:'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _eggsController,
                decoration: InputDecoration(labelText: 'No. of Eggs:'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _eggTypeController, // Add TextField for eggType
                decoration: InputDecoration(labelText: 'Egg Type:'),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String date = _dateController.text;
                int eggs = int.tryParse(_eggsController.text) ?? 0;
                String eggType = _eggTypeController.text; // Get eggType value
                _editProductionData(id, date, eggs, eggType); // Pass eggType
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to confirm deletion
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Production Data'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteProductionData(id);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Function to clear input fields
  void _clearInputFields() {
    _dateController.clear();
    _eggsController.clear();
  }

  // Widget to build the production data table
  Widget _buildProductionTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('No. of Eggs')),
          DataColumn(label: Text('Egg Type')),
          DataColumn(label: Text('Action')),
        ],
        rows: productionDataList.map<DataRow>((production) {
          return DataRow(
            cells: [
              DataCell(Text(production['date'] ?? '')),
              DataCell(Text(production['eggs'].toString())),
              DataCell(Text(production['eggType'] ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(
                        int.parse(production['id'].toString()),
                        production['date'],
                        int.parse(production['eggs'].toString()),
                        production['eggType'].toString(),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDelete(int.parse(production['id'].toString()));
                    },
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  String? _selectedEggType; // Add this line to declare the variable

  Widget _inputSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 253, 253, 253),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color.fromARGB(248, 20, 20, 20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date:',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _eggsController,
                    decoration: InputDecoration(
                      labelText: 'No. of Eggs:',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.egg),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          DropdownButtonFormField<String>(
            value: _selectedEggType, // Set the value to the selected type
            items: [
              DropdownMenuItem(child: Text('Whole'), value: 'Whole'),
              DropdownMenuItem(child: Text('Cracked'), value: 'Cracked'),
              DropdownMenuItem(
                  child: Text('Soft-shelled'), value: 'Soft-shelled'),
            ],
            decoration: InputDecoration(
              labelText: 'Egg Type:',
              border: OutlineInputBorder(),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedEggType = newValue; // Update the selected type
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: () {
                String date = _dateController.text;
                int eggs = int.tryParse(_eggsController.text) ?? 0;
                String eggType =
                    _selectedEggType ?? ''; // Use the selected egg type
                _addProductionData(date, eggs, eggType);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Item Widget
  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    GestureTapCallback? onTap,
    FontWeight? fontWeight,
  }) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Production',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
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
        backgroundColor: const Color(0xFFF8F96F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF8F96F),
              ),
              child: Text(
                'ECOGUARD',
                style: TextStyle(
                    color: Color(0xFF377A26),
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
                Navigator.of(context).pushReplacement(
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
      body: RefreshIndicator(
        onRefresh: _fetchProductionData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _inputSection(),
              SizedBox(height: 16.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF141414),
                    ),
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : productionDataList.isEmpty
                          ? Center(child: Text('No production data available'))
                          : SingleChildScrollView(
                              child: _buildProductionTable(),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }
}

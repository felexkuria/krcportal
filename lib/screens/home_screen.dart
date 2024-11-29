import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krcportal/screens/dashboard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers for meter readings
  final TextEditingController _ampereN1Controller = TextEditingController();
  final TextEditingController _kwhN1Controller = TextEditingController();
  final TextEditingController _kwhN2Controller = TextEditingController();
  final TextEditingController _kvarhN2Controller = TextEditingController();
  final TextEditingController _ampereN3Controller = TextEditingController();
  final TextEditingController _voltageN3Controller = TextEditingController();
  final TextEditingController _kwhN3Controller = TextEditingController();
  final TextEditingController _kvarhN3Controller = TextEditingController();
  final TextEditingController _kwhN6Controller = TextEditingController();
  final TextEditingController _ampereN7Controller = TextEditingController();
  final TextEditingController _kvarhN7Controller = TextEditingController();
  final TextEditingController _ampereN9Controller = TextEditingController();
  final TextEditingController _kwhN9MinusController = TextEditingController();
  final TextEditingController _ampereN9PlusController = TextEditingController();
  final TextEditingController _kwhN9PlusController = TextEditingController();

  String _userName = "User"; // Get the logged-in user's name
  String _selectedTime = '0800hrs'; // Default time

  // Build the meter panel
  Widget _buildMeterPanel({
    required String title,
    required List<TextEditingController> controllers,
    required List<String> labels,
  }) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            for (int i = 0; i < controllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: labels[i],
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Submit the readings to Firestore
  Future<void> _submitReadings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
    if (currentUser == null) {
      return; // User is not logged in
    }

    DateTime currentTime = DateTime.now();

    // Get all readings
    Map<String, dynamic> readingsData = {
      'ampereN1': double.tryParse(_ampereN1Controller.text) ?? 0.0,
      'kwhN1': double.tryParse(_kwhN1Controller.text) ?? 0.0,
      'kwhN2': double.tryParse(_kwhN2Controller.text) ?? 0.0,
      'kvarhN2': double.tryParse(_kvarhN2Controller.text) ?? 0.0,
      'ampereN3': double.tryParse(_ampereN3Controller.text) ?? 0.0,
      'voltageN3': double.tryParse(_voltageN3Controller.text) ?? 0.0,
      'kwhN3': double.tryParse(_kwhN3Controller.text) ?? 0.0,
      'kvarhN3': double.tryParse(_kvarhN3Controller.text) ?? 0.0,
      'kwhN6': double.tryParse(_kwhN6Controller.text) ?? 0.0,
      'ampereN7': double.tryParse(_ampereN7Controller.text) ?? 0.0,
      'kvarhN7': double.tryParse(_kvarhN7Controller.text) ?? 0.0,
      'ampereN9': double.tryParse(_ampereN9Controller.text) ?? 0.0,
      'kwhN9Minus': double.tryParse(_kwhN9MinusController.text) ?? 0.0,
      'ampereN9Plus': double.tryParse(_ampereN9PlusController.text) ?? 0.0,
      'kwhN9Plus': double.tryParse(_kwhN9PlusController.text) ?? 0.0,
      'submissionTime': currentTime,
      'submissionHour': _selectedTime, // Save the selected time
    };

    try {
      // Save the readings data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('meterReadings')
          .add(readingsData);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Readings submitted successfully')));
    } catch (e) {
      print('Error submitting readings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit readings')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display logged-in user's name
              Text('Welcome, $_userName!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Time selection (Dropdown menu)
              Row(
                children: [
                  const Text('Select Time: ',
                      style: const TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTime = newValue!;
                      });
                    },
                    items: ['0800hrs', '1400hrs', '2000hrs']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Panels for meter readings (N1, N2, N3, etc.)
              _buildMeterPanel(
                title: 'Panel N1 (Ampere, KWH Reading)',
                controllers: [
                  _ampereN1Controller,
                  _kwhN1Controller,
                ],
                labels: ['Ampere', 'KWH Reading'],
              ),
              _buildMeterPanel(
                title: 'Panel N2 (KWH, KVARH Reading)',
                controllers: [
                  _kwhN2Controller,
                  _kvarhN2Controller,
                ],
                labels: ['KWH Reading', 'KVARH Reading'],
              ),
              _buildMeterPanel(
                title: 'Panel N3 (Ampere, Voltage, KWH, KVARH)',
                controllers: [
                  _ampereN3Controller,
                  _voltageN3Controller,
                  _kwhN3Controller,
                  _kvarhN3Controller,
                ],
                labels: ['Ampere', 'Voltage', 'KWH Reading', 'KVARH Reading'],
              ),
              // Add more panels here...

              // Submit Button
              ElevatedButton(
                onPressed: _submitReadings,
                child: const Text('Submit Readings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

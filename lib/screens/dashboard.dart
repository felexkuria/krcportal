import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Selected day in the calendar
  DateTime _selectedDay = DateTime.now();
  late Map<DateTime, List<Map<String, dynamic>>> _dailyReadings;

  @override
  void initState() {
    super.initState();
    _dailyReadings = {};
    _fetchData();
  }

  // Fetch meter readings for the selected day from Firestore
  Future<void> _fetchData() async {
    final userData = await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in userData.docs) {
      final meterReadingsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .collection('meterReadings')
          .where('submissionTime', isGreaterThanOrEqualTo: _selectedDay)
          .where('submissionTime',
              isLessThanOrEqualTo: _selectedDay.add(const Duration(days: 1)))
          .get();

      for (var reading in meterReadingsQuery.docs) {
        final submissionData = reading.data();
        DateTime submissionTime =
            (submissionData['submissionTime'] as Timestamp).toDate();

        // Store data based on the date it was submitted
        if (_dailyReadings[_selectedDay] == null) {
          _dailyReadings[_selectedDay] = [];
        }
        _dailyReadings[_selectedDay]?.add({
          'workerName': userDoc['name'],
          'substation': submissionData['substation'],
          'panelN1': submissionData['panelN1'],
          'panelN2': submissionData['panelN2'],
          'panelN3': submissionData['panelN3'],
          'submissionTime': submissionTime,
          'submissionHour': submissionData['submissionHour'],
        });
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meter Readings Dashboard")),
      body: Column(
        children: [
          // Calendar widget
          TableCalendar(
            firstDay: DateTime.utc(2020, 01, 01),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _fetchData(); // Fetch data for the selected day
              });
            },
          ),
          const SizedBox(height: 10),

          // Display data for the selected day
          Expanded(
            child: _dailyReadings.isNotEmpty
                ? ListView.builder(
                    itemCount: _dailyReadings[_selectedDay]?.length ?? 0,
                    itemBuilder: (context, index) {
                      var reading = _dailyReadings[_selectedDay]![index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                              '${reading['workerName']} - ${reading['substation']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Panel N1: Ampere: ${reading['panelN1']['ampere']}, kWh: ${reading['panelN1']['kwh']}'),
                              Text(
                                  'Panel N2: kWh: ${reading['panelN2']['kwh']}, kvarh: ${reading['panelN2']['kvarh']}'),
                              Text(
                                  'Panel N3: kWh: ${reading['panelN3']['kwh']}, kvarh: ${reading['panelN3']['kvarh']}'),
                              Text(
                                  'Submission Time: ${reading['submissionTime']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text("No data available for this day")),
          ),
        ],
      ),
    );
  }
}

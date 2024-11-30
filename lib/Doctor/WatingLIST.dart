import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Calling_Function/Calling.dart';
import '../Prescription/prescription.dart';

class AppointmentWaitingListPage extends StatefulWidget {
  const AppointmentWaitingListPage({super.key});

  @override
  _AppointmentWaitingListPageState createState() =>
      _AppointmentWaitingListPageState();
}

class _AppointmentWaitingListPageState
    extends State<AppointmentWaitingListPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _waitingList = [];
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsForToday();
  }

  // Fetch appointments for today's date from subcollections
  Future<void> _fetchAppointmentsForToday() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current date as a string
      String selectedDateStr = DateTime.now().toString().split(' ')[0];
      List<Map<String, dynamic>> waitingList = [];

      print('Fetching appointments for date: $selectedDateStr');

      // Fetch all appointments where the date field matches today's date
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isEqualTo: selectedDateStr)
          .get();

      print('Total appointments found: ${appointmentsSnapshot.docs.length}');

      for (var appointmentDoc in appointmentsSnapshot.docs) {
        String uid =
            appointmentDoc.id; // Get the appointment document ID (user ID)

        // Fetch the appointments for the user (doctor) from the subcollection 'appo'
        final appoSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(uid)
            .collection('appo')
            .where('date', isEqualTo: selectedDateStr)
            .get();

        print(
            'Total sub-appointments for user $uid: ${appoSnapshot.docs.length}');

        for (var appoDoc in appoSnapshot.docs) {
          String patientUid = appoDoc.get('uid'); // Get the patient UID

          // Fetch patient data from the Patient collection
          final patientSnapshot = await FirebaseFirestore.instance
              .collection('Patient')
              .doc(patientUid)
              .get();

          if (patientSnapshot.exists) {
            String patientName = patientSnapshot.get('name');

            // Add the appointment data to the waiting list
            waitingList.add({
              'puid': patientUid,
              'name': patientName,
              'date': selectedDateStr,
              'doctor': appoDoc.get('doctor'),
              'timeSlot': appoDoc.get('timeSlot'),
            });
          } else {
            print('Patient data not found for UID: $patientUid');
          }
        }
      }

      setState(() {
        _waitingList = waitingList;
      });

      print('Waiting list updated with ${waitingList.length} entries');
    } catch (e) {
      print('Error fetching waiting list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching appointments')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show options dialog when a list item is tapped
  void _showOptionsDialog(BuildContext context, Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an Option'),
          content: const Text(
              'Would you like to start a video call or write a prescription?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(callID: patient['puid']),
                  ),
                );
              },
              child: const Text('Video Call'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrescriptionForm(
                      uid: patient['puid'],
                      date: patient['date'],
                      doctor: patient['doctor'],
                      timeSlot: patient['timeSlot'],
                      name: patient['name'],
                    ),
                  ),
                );
              },
              child: const Text('Prescription'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Waiting List'),
        backgroundColor: Colors.teal.shade300, // Olive-green app bar color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _waitingList.isEmpty
              ? const Center(child: Text('No appointments for today'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _waitingList.length,
                  itemBuilder: (context, index) {
                    var patient = _waitingList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        elevation: 4.0,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              patient['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Time Slot: ${patient['timeSlot']}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            onTap: () {
                              _showOptionsDialog(context, patient);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

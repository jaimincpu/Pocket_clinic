import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final String uid;
  final String time;
  final String date;

  const AppointmentDetailsPage({
    Key? key,
    required this.uid,
    required this.time,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD5EAE3),
                Color(0xFFE8EEEE),
                Color(0xFFD4CBDE),
                Color(0xFFAE95CC),
                Color(0xFF86B7BC)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('appointments')
            .doc(uid) // Get the document for the specified UID
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching appointment.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No appointment found.'));
          }

          // Access the document snapshot for the appointment data
          var appointmentDoc = snapshot.data!;

          // Start streaming the 'prec' subcollection where the time and date match
          return StreamBuilder<QuerySnapshot>(
            stream: appointmentDoc.reference
                .collection('prec')
                .where('timeSlot', isEqualTo: time)
                .where('date', isEqualTo: date)
                .snapshots(),
            builder: (context, precSnapshot) {
              if (precSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (precSnapshot.hasError) {
                return const Center(
                    child: Text('Error fetching subcollection data.'));
              }
              if (!precSnapshot.hasData || precSnapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No details found in subcollection.'));
              }

              // Map the data from the 'prec' subcollection documents
              var data =
                  precSnapshot.data!.docs[0].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD5EAE3), Color(0xFFE8EEEE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${data['date']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Doctor Name: ${data['doctorName']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dosage: ${data['dosage']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Medication: ${data['medication']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${data['notes']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patient Name: ${data['patientName']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Time Slot: ${data['timeSlot']}',
                          style: TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

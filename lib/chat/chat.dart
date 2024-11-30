import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _getUsersBasedOnRole() async {
    final currentUserEmail = _auth.currentUser?.email;

    // First, check if the user is in the Doctor or Patient collection
    final doctorSnapshot = await FirebaseFirestore.instance
        .collection('Doctor')
        .where('email', isEqualTo: currentUserEmail)
        .get();

    // Determine the collection to fetch based on the current user's role
    if (doctorSnapshot.docs.isNotEmpty) {
      // Current user is a Doctor, so fetch all Patients
      final patientSnapshot = await FirebaseFirestore.instance
          .collection('Patient')
          .where('email', isNotEqualTo: currentUserEmail)
          .get();
      return patientSnapshot.docs;
    } else {
      // Current user is a Patient, so fetch all Doctors
      final doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctor')
          .where('email', isNotEqualTo: currentUserEmail)
          .get();
      return doctorSnapshot.docs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF9983CF),
                Colors.teal.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _getUsersBasedOnRole(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data();
              final email = data['email'] as String?;
              final username = data['name'] as String? ?? 'Unknown User';

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
      color: const Color(0xFFefc8ec),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ListTile(
                  title: Text(username),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: email ?? '',
                        receiverID: doc.id, // Pass the document ID as the UID
                        username: username,
                      ),
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

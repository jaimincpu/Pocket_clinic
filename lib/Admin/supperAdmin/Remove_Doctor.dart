import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the Flutter Toast package

class RemoveDoctorPage extends StatelessWidget {
  const RemoveDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Doctor'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Doctor').snapshots(), // Fixed the stream call
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching doctors. Please try again.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Use a Toast instead of returning an empty container
            Fluttertoast.showToast(
              msg: "No doctors found",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            return const Center(child: Text("No doctors available.")); // Better user feedback
          }

          final doctorDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: doctorDocs.length,
            itemBuilder: (context, index) {
              final doctor = doctorDocs[index];
              final doctorData = doctor.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
              final doctorName = doctorData['name'] ?? 'Unnamed Doctor'; // Handle missing names

              return ListTile(
                title: Text(doctorName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, doctor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, QueryDocumentSnapshot doctor) {
    final doctorData = doctor.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
    final doctorName = doctorData['name'] ?? 'Unnamed Doctor'; // Handle missing names

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to remove $doctorName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () {
                _deleteDoctor(doctor.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDoctor(String doctorId) async {
    try {
      await FirebaseFirestore.instance.collection('Doctor').doc(doctorId).delete(); // Fixed the reference to the collection
      Fluttertoast.showToast(
        msg: "Doctor removed successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to remove doctor: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("Error deleting doctor: $e"); // Log the error for debugging
    }
  }
}

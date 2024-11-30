import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplDoctorList extends StatefulWidget {
  const SplDoctorList({super.key});

  @override
  _SplDoctorListState createState() => _SplDoctorListState();
}

class _SplDoctorListState extends State<SplDoctorList> {
  String selectedSpecialization = 'General';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor List'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSpecialization = 'General';
                  });
                },
                child: const Text('General'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSpecialization = 'Dermatologist';
                  });
                },
                child: const Text('Dermatologist'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Doctor')
                  .where('specialist', isEqualTo: selectedSpecialization)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final doctorDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: doctorDocs.length,
                  itemBuilder: (context, index) {
                    final doctor = doctorDocs[index];
                    return ListTile(
                      title: Text(doctor['name']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

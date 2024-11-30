import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrescriptionForm extends StatefulWidget {
  final String uid;
  final String date;
  final String doctor;
  final String timeSlot;
  final String name;

  const PrescriptionForm({
    Key? key,
    required this.uid,
    required this.date,
    required this.doctor,
    required this.timeSlot,
    required this.name,
  }) : super(key: key);

  @override
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  void _submitPrescription() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.uid)
            .collection('prec') // Changed to 'prec'
            .add({
          'patientName': widget.name,
          'doctorName': widget.doctor,
          'medication': _medicationController.text,
          'dosage': _dosageController.text,
          'notes': _notesController.text,
          'date': widget.date,
          'timeSlot': widget.timeSlot,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription submitted successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit prescription: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Medication'),
                  controller: _medicationController,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter medication' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dosage'),
                  controller: _dosageController,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter dosage' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Notes'),
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPrescription,
                  child: const Text('Submit Prescription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

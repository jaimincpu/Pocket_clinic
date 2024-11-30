import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String _selectedSpecialist = 'General';
  String? _selectedDoctor;
  List<String> _doctorList = [];
  DateTime? _selectedDate;
  final TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isLoading = false;
  List<String> _bookedSlots = [];

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsBySpecialist(_selectedSpecialist);
  }

  Future<void> _fetchDoctorsBySpecialist(String specialist) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Doctor')
          .where('specialist', isEqualTo: specialist)
          .get();

      List<String> doctors = querySnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      setState(() {
        _doctorList = doctors;
        _selectedDoctor = doctors.isNotEmpty ? doctors[0] : null;
        _fetchBookedSlots();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchBookedSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(user!.uid)
          .collection('appo')
          .where('doctor', isEqualTo: _selectedDoctor)
          .where('date', isEqualTo: _selectedDate!.toString().split(' ')[0])
          .get();

      List<String> bookedSlots = snapshot.docs.map((doc) {
        return doc['timeSlot'] as String;
      }).toList();

      setState(() {
        _bookedSlots = bookedSlots;
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    DateTime startTime = DateTime(
        _selectedDate?.year ?? DateTime.now().year,
        _selectedDate?.month ?? DateTime.now().month,
        _selectedDate?.day ?? DateTime.now().day,
        9,
        30);
    for (int i = 0; i < 30; i++) {
      String start =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      startTime = startTime.add(const Duration(minutes: 15));
      String end =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      slots.add("$start to $end");
    }
    return slots;
  }

 Future<void> _bookSlot(String slot) async {
  if (user == null || _selectedDoctor == null || _selectedDate == null) return;

  try {
    // Reference to the document in the 'appointments' collection
    var appointmentDoc = FirebaseFirestore.instance
        .collection('appointments')
        .doc(user!.uid);

    // Update the document with the date
    await appointmentDoc.set({
      'date': _selectedDate!.toString().split(' ')[0],
    });

    // Add to the sub-collection 'appo'
    await appointmentDoc.collection('appo').add({
      'doctor': _selectedDoctor,
      'date': _selectedDate!.toString().split(' ')[0],
      'timeSlot': slot,
      'uid': user!.uid,
    });

    print('Slot booked: $slot');
    _fetchBookedSlots();
  } catch (e) {
    print('Error booking slot: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    List<String> timeSlots = _generateTimeSlots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointment'),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/appoiment_pocket_clinic.JPG',
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: _selectedSpecialist,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialist = value!;
                          _fetchDoctorsBySpecialist(_selectedSpecialist);
                        });
                      },
                      items: ['General', 'Dermatologist'].map((specialist) {
                        return DropdownMenuItem<String>(
                          value: specialist,
                          child: Text(specialist),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _doctorList.isNotEmpty
                            ? DropdownButton<String>(
                                value: _selectedDoctor,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDoctor = value;
                                    _fetchBookedSlots();
                                  });
                                },
                                items: _doctorList.map((doctor) {
                                  return DropdownMenuItem<String>(
                                    value: doctor,
                                    child: Text(doctor),
                                  );
                                }).toList(),
                              )
                            : const Text(
                                'No doctors available for selected specialist'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2022),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _fetchBookedSlots();
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                    const SizedBox(height: 10),
                    _selectedDate != null
                        ? _isLoading
                            ? const CircularProgressIndicator()
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: timeSlots.length,
                                itemBuilder: (context, index) {
                                  String slot = timeSlots[index];
                                  bool isBooked = _bookedSlots.contains(slot);

                                  return ListTile(
                                    title: Text(
                                      slot,
                                      style: TextStyle(
                                        color: isBooked
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    trailing: isBooked
                                        ? const Text('Booked',
                                            style: TextStyle(color: Colors.red))
                                        : ElevatedButton(
                                            onPressed: () => _bookSlot(slot),
                                            child: const Text('Book'),
                                          ),
                                  );
                                },
                              )
                        : const Text(
                            'Please select a date to view available time slots'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

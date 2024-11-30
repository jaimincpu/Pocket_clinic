import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Calling_Function/Calling.dart';
import '../Prescription/ShowPrescription.dart';
import '../appomentpage/appomentPage.dart';
import '../chat/chat.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserUID;
  bool showAllLogs = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserUID();
  }

  Future<void> fetchCurrentUserUID() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() => currentUserUID = user.uid);
      listenForIncomingCalls();
    }
  }

  void listenForIncomingCalls() {
    _firestore
        .collection('calls')
        .where('receiverUID', isEqualTo: currentUserUID)
        .where('callActive', isEqualTo: true)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var callData = querySnapshot.docs.first.data();
        _showIncomingCallDialog(callData['callID'], callData['callerUID']);
      }
    });
  }

  void _showIncomingCallDialog(String callID, String callerUID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Incoming Call"),
        content: Text("Caller: $callerUID is calling you"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CallPage(callID: callID)),
              );
            },
            child: const Text("Accept"),
          ),
          TextButton(
            onPressed: () {
              _firestore
                  .collection('calls')
                  .doc(callID)
                  .update({'callActive': false});
              Navigator.of(context).pop();
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Center(child: _buildOverlay()),
          _buildBodyContent(),
          _buildBottomLogSection(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Clinic Dashboard'),
      leading:
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => signOut(context),
        ),
      ],
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
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/appoiment_pocket_clinic.JPG',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(color: Colors.white.withOpacity(0.5));
  }

  Widget _buildBodyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildFeatureCard(
              "To book an appointment, click the button below.", "Appointment",
              () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AppointmentPage()));
          }),
          const SizedBox(height: 20),
          _buildFeatureCard("Chat With Doctor Click Here", "Chat With Doctor",
              () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Chat()));
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String text, String buttonText, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, offset: Offset(0, 2), blurRadius: 6.0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      blurRadius: 4.0,
                      color: Colors.black26,
                      offset: Offset(0, 2)),
                ]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildGradientButton(buttonText, onPressed),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFD5EAE3), Color(0xFFE8EEEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            elevation: 6.0),
        child: Text(text, style: TextStyle(color: Colors.black)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomLogSection() {
    return Positioned(
      left: 16.0,
      right: 16.0,
      bottom: 16.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last Visiting Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildAppointmentLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentLogs() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('appointments').doc(currentUserUID).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching appointments.'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No appointments found.'));
        }

        var appointmentDoc = snapshot.data!;
        return _buildSubCollectionLogs(appointmentDoc);
      },
    );
  }

  Widget _buildSubCollectionLogs(DocumentSnapshot appointmentDoc) {
    return StreamBuilder<QuerySnapshot>(
      stream: appointmentDoc.reference.collection('appo').snapshots(),
      builder: (context, appoSnapshot) {
        if (appoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (appoSnapshot.hasError) {
          return const Center(
              child: Text('Error fetching subcollection data.'));
        }
        if (!appoSnapshot.hasData || appoSnapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No details found in subcollection.'));
        }

        var logsToShow = showAllLogs
            ? appoSnapshot.data!.docs
            : appoSnapshot.data!.docs.take(2).toList();
        return Column(
          children: [
            ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: logsToShow.length,
  itemBuilder: (context, index) {
    var appoData = logsToShow[index].data() as Map<String, dynamic>;
    var time = appoData['timeSlot'];
    var date = appoData['date'];
    
    return ListTile(
      title: Text(appoData['doctor'] ?? 'Unknown Doctor'),
      subtitle: Text(
        'Time: $time\nDate: $date',
      ),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
      onTap: () {
        // Navigate to the Show page with the necessary data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailsPage(
              time: time,
              date: date,
              uid: currentUserUID!, // Pass the actual currentUserUID
          //    userData: appoData,
            ),
          ),
        );
      },
    );
  },
),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => setState(() => showAllLogs = !showAllLogs),
              child: Text(showAllLogs ? 'Show Less' : 'Show More'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Admin/supperAdmin.dart';
import '../Doctor/Doctor_HOME.dart';
import '../Home_page/Home_Page.dart';
import 'login_page.dart';

class LogChecker extends StatelessWidget {
  const LogChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission for notifications
    _firebaseMessaging.requestPermission();

    // Get FCM token and log it, or store it in Firestore for future use if needed
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
      if (_auth.currentUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'fcmToken': token});
      }
    });

    // Handle notifications when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Message Notification: ${message.notification!.title}");
        // Show in-app notification or dialog if needed
      }
      _handleNotificationData(message.data);
    });

    // Handle notifications when the app is opened via a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationData(message.data);
    });
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    // Check if the notification is for a call and navigate to CallPage
    if (data['type'] == 'call') {
      String callID = data['callID'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CallPage(callID: callID)),
      );
    }
  }

  Future<Map<String, dynamic>?> checkMultipleCollections(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final collections = ['Doctor', 'Admin', 'Patient'];

    for (var collection in collections) {
      try {
        final doc = await firestore.collection(collection).doc(uid).get();
        if (doc.exists) {
          return doc.data();
        }
      } catch (e) {
        print('Error fetching data from $collection: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          if (user == null) {
            return const LoginPage();
          } else {
            return FutureBuilder<Map<String, dynamic>?>(
              future: checkMultipleCollections(user.uid),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(
                      child: Text("Error fetching user role"),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text("User role not found, please contact support."),
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  switch (data['User']) {
                    case 'Patient':
                      return const HomePage();
                    case 'Admin':
                      return const Supperadmin();
                    case 'Doctor':
                      return const DoctorHomePage();
                    default:
                      return const Scaffold(
                        body: Center(
                          child: Text("Unknown user role."),
                        ),
                      );
                  }
                }
              },
            );
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

// Dummy CallPage (replace with actual CallPage implementation)
class CallPage extends StatelessWidget {
  final String callID;

  const CallPage({required this.callID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Call Page")),
      body: Center(child: Text("In a call with ID: $callID")),
    );
  }
}

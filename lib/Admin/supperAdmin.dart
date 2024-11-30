import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';
import 'supperAdmin/Add_Doctor.dart';
import 'supperAdmin/Remove_Doctor.dart';
import 'supperAdmin/splDoctorList.dart';

class Supperadmin extends StatefulWidget {
  const Supperadmin({super.key});

  @override
  State<Supperadmin> createState() => _SupperadminState();
}

class _SupperadminState extends State<Supperadmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign out function with error handling and SharedPreferences
  Future<void> signOut(BuildContext context) async {
    try {
      // Sign out from FirebaseAuth
      await _auth.signOut();

      // Update SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Navigate to the login page and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Display an error dialog if something goes wrong
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to sign out: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supper Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Account'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('User: Admin'),
                        const Text('Email: DoctorAdmin@clinic.com'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            signOut(context); // Call the signOut method
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add Doctor Tile
              buildOptionTile(
                context,
                screenSize,
                'Add Doctor',
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddDoctor()),
                  );
                },
              ),
              // Remove Doctor Tile
              buildOptionTile(
                context,
                screenSize,
                'Remove Doctor',
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RemoveDoctorPage()),
                  );
                },
              ),
              // Specialist Doctor List Tile
              buildOptionTile(
                context,
                screenSize,
                'Specialist Doctor List',
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplDoctorList()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create each tile option
  Widget buildOptionTile(
    BuildContext context,
    Size screenSize,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: screenSize.width * 0.8,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

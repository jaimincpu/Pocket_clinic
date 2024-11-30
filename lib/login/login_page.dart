import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../Admin/supperAdmin.dart';
import '../Doctor/Doctor_HOME.dart';
import '../Home_page/Home_Page.dart';
import 'Forget_psw.dart';
import 'SignUP.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Login_page_screen.png', // Path to your image
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.4), // Adjust opacity here
          ),
          Center(
            child: const Login(), // Center the login form on the screen
          ),
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';

  // Function to check the user role across multiple collections (Doctor, Admin, Patient)
  Future<void> checkUserRole(
      UserCredential userCredential, BuildContext context) async {
    final uid = userCredential.user!.uid;
    final firestore = FirebaseFirestore.instance;
    final collections = ['Doctor', 'Admin', 'Patient'];

    for (String collection in collections) {
      DocumentSnapshot docSnapshot =
          await firestore.collection(collection).doc(uid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Navigate to the appropriate page based on the user's role
        if (data['User'] == 'Patient') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
          print("Navigating to Patient Page");
        } else if (data['User'] == 'Admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Supperadmin()));
          print("Navigating to Admin Page");
        } else if (data['User'] == 'Doctor') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DoctorHomePage()));
          print("Navigating to Doctor Page");
        }
        return;
      }
    }
    // If no matching user is found in any collection
    print('User does not exist in any of the collections.');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Email',
                          hintText: 'Enter your Email',
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const forgetpsw()),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 2, 44, 35),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              final userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                email: _email,
                                password: _password,
                              );
                              checkUserRole(userCredential, context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 2, 44, 35),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()),
                          );
                        },
                        child: const Text('SignUp'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

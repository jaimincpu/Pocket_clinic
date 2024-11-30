import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignUp(),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? email, password, name, phoneNo;

  // Function to check if the email is already in use
  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      final list = await _auth.fetchSignInMethodsForEmail(email);
      return list.isNotEmpty;
    } catch (e) {
      return false; // Fallback in case of any issues
    }
  }

  // Function to check if the phone number is already in use
  Future<bool> isPhoneNumberAlreadyInUse(String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Patient')
          .where('phoneNo', isEqualTo: phoneNumber)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false; // Fallback in case of any issues
    }
  }

  // Function to handle user registration
  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        // Storing user information in Firestore
        await FirebaseFirestore.instance
            .collection('Patient')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'phoneNo': phoneNo,
          'User': 'Patient',
          'uid': userCredential.user!.uid,
        });
        Navigator.of(context)
            .pop(); // Navigating back after successful registration
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "SignUp",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 44, 35),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "SignUp",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      // Name Input
                      _buildTextInputField(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        onSaved: (input) => name = input,
                        validator: (input) =>
                            input!.isEmpty ? 'Please enter your name' : null,
                      ),
                      // Email Input
                      _buildTextInputField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => email = input,
                        validator: (input) {
                          if (input == null || !input.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      // Phone Number Input
                      _buildTextInputField(
                        labelText: 'Phone No',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        onSaved: (input) => phoneNo = input,
                        validator: (input) {
                          if (input == null || input.length != 10) {
                            return 'Phone number should be exactly 10 digits.';
                          }
                          return null;
                        },
                      ),
                      // Password Input
                      _buildTextInputField(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: true,
                        onSaved: (input) => password = input,
                        validator: (input) {
                          RegExp regex = RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                          );
                          if (input == null || !regex.hasMatch(input)) {
                            return 'Enter a valid password (e.g., Example@123)';
                          }
                          return null;
                        },
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 44, 35),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Back'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 44, 35),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState?.save();

                                      // Perform email and phone number checks
                                      bool emailInUse =
                                          await isEmailAlreadyInUse(email!);
                                      bool phoneInUse =
                                          await isPhoneNumberAlreadyInUse(
                                              phoneNo!);

                                      if (emailInUse) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'This email is already registered.')),
                                        );
                                        return;
                                      }
                                      if (phoneInUse) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'This phone number is already registered.')),
                                        );
                                        return;
                                      }

                                      // Proceed with registration
                                      _register();
                                    }
                                  },
                                  child: const Text('Register'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text input fields
  Padding _buildTextInputField({
    required String labelText,
    required String hintText,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(),
          ),
          labelText: labelText,
          hintText: hintText,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}

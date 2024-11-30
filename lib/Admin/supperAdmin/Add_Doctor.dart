import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDoctor extends StatefulWidget {
  const AddDoctor({super.key});

  @override
  _AddDoctor createState() => _AddDoctor();
}

class _AddDoctor extends State<AddDoctor> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _specialistController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to save doctor data to Firestore and create a new user account
  Future<void> _saveDoctor() async {
    try {
      // Create a new user account using Firebase Authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the newly created user's UID
      final user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;

      // Store the doctor's data in Firestore
      CollectionReference doctors =
          FirebaseFirestore.instance.collection('Doctor');
      await doctors.doc(uid).set({
        'email': _emailController.text,
        'name': _nameController.text,
        'rank': _rankController.text,
        'specialist': _specialistController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'User': 'Doctor',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor added successfully')),
      );

      // Clear form after submission
      _emailController.clear();
      _nameController.clear();
      _rankController.clear();
      _specialistController.clear();
      _phoneController.clear();
      _addressController.clear();
      _passwordController.clear();

      // Navigate back to the previous screen
      Navigator.pop(context, { });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding doctor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Doctor'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Enhance AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Email field
              _buildFormCard(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Name field
              _buildFormCard(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Rank field
              _buildFormCard(
                child: TextFormField(
                  controller: _rankController,
                  decoration: const InputDecoration(
                    labelText: 'Rank',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your rank';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Specialist Dropdown
              _buildFormCard(
                child: DropdownButtonFormField<String>(
                  value: _specialistController.text.isEmpty
                      ? null
                      : _specialistController.text,
                  decoration: const InputDecoration(
                    labelText: 'Specialist',
                    border: OutlineInputBorder(),
                  ),
                  items: ['General', 'Dermatologist'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _specialistController.text = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a specialist field';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Phone number field
              _buildFormCard(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Address field
              _buildFormCard(
                child: TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Password field
              _buildFormCard(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    RegExp regex = RegExp(
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                    );
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (!regex.hasMatch(value)) {
                      return 'Password must be at least 8 characters and contain a mix of upper and lowercase letters, numbers, and symbols.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDoctor(); // Save data to Firestore and create a new user account
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Customize button color
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Doctor',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for wrapping form fields inside a card for better styling
  Widget _buildFormCard({required Widget child}) {
    return Card(
      elevation: 3, // Adds shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _emailController.dispose();
    _nameController.dispose();
    _rankController.dispose();
    _specialistController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

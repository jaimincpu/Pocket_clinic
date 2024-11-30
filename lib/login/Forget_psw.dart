import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class forgetpsw extends StatefulWidget {
  const forgetpsw({super.key});

  @override
  State<forgetpsw> createState() => _forgetpswState();
}

class _forgetpswState extends State<forgetpsw> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> pswreset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('link has been set check your inbox'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Rest your Password",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 44, 35),
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "Enter your registered email address here to get a password reset link on your email"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(),
                  ),
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              onPressed: pswreset,
              color: Colors.orangeAccent,
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}

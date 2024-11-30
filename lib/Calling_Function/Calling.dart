import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallPage extends StatelessWidget {
  final String callID;

  const CallPage({required this.callID});

  @override
  Widget build(BuildContext context) {
    final String userID = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String userName = FirebaseAuth.instance.currentUser?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: 1687834211, // Replace with your actual appID
          appSign: '1fd38c815740e2108fbe13cd546afc8c8d8ea0a52056fe2d01e65457f00c2a96', // Replace with your actual appSign
          callID: callID,
          userID: userID,
          userName: userName,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
        ),
      ),
    );
  }
}

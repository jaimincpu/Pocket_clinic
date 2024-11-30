// // import 'package:flutter/material.dart';
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class DoctorVideoCallScreen extends StatefulWidget {
// //   final String roomId; // The unique ID for the video call session (passed from the previous screen)

// //   const DoctorVideoCallScreen({Key? key, required this.roomId}) : super(key: key);

// //   @override
// //   _DoctorVideoCallScreenState createState() => _DoctorVideoCallScreenState();
// // }

// // class _DoctorVideoCallScreenState extends State<DoctorVideoCallScreen> {
// //   late RTCVideoRenderer _localRenderer;  // Renderer for local video feed
// //   late RTCVideoRenderer _remoteRenderer; // Renderer for remote video feed
// //   late RTCPeerConnection _peerConnection; // WebRTC peer connection object
// //   late MediaStream _localStream; // Media stream for capturing local video/audio

// //   // Flag to indicate if UI elements are initialized
// //   bool _uiInitialized = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initRenderers(); // Initialize the video renderers
// //     _createPeerConnection(); // Establish WebRTC peer connection
// //   }

// //   // Initialize local and remote video renderers
// //   Future<void> _initRenderers() async {
// //     _localRenderer = RTCVideoRenderer();
// //     _remoteRenderer = RTCVideoRenderer();
// //     await _localRenderer.initialize();
// //     await _remoteRenderer.initialize();
// //   }

// //   // Create a WebRTC peer connection and set up handlers for video/audio
// //   Future<void> _createPeerConnection() async {
// //     // Configuration for STUN/TURN servers (you can add more servers here if needed)
// //     final Map<String, dynamic> config = {
// //       'iceServers': [
// //         {'urls': 'stun:stun.l.twilio.com:3478'}, // Example STUN server
// //       ]
// //     };

// //     // Create the peer connection
// //     _peerConnection = await createPeerConnection(config);

// //     // Handle incoming ICE candidates and send them to Firestore
// //     _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
// //       if (candidate != null) {
// //         FirebaseFirestore.instance
// //             .collection('calls')
// //             .doc(widget.roomId)
// //             .update({
// //           'iceCandidates': FieldValue.arrayUnion([candidate.toMap()]),
// //         });
// //       }
// //     };

// //     // Handle incoming media stream (remote video)
// //     _peerConnection.onTrack = (RTCTrackEvent event) {
// //       _remoteRenderer.srcObject = event.streams.first; // Display remote video
// //       setState(() {}); // Update UI to reflect remote video
// //     };

// //     // Monitor the ICE connection state and update UI accordingly
// //     _peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
// //       debugPrint('ICE Connection state: $state');
// //       if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
// //         print('ICE Connection established successfully!');
// //         setState(() {
// //           _uiInitialized = true; // Flag UI as initialized
// //         });
// //       } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
// //           state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
// //           state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
// //         print('ICE Connection error or disconnected!');
// //       }
// //     };

// //     // Get access to local camera and microphone
// //     _localStream = await navigator.mediaDevices.getUserMedia({
// //       'audio': true,
// //       'video': true,
// //     });

// //     // Assign the local media stream to the local video renderer
// //     _localRenderer.srcObject = _localStream;

// //     // Add local tracks (video/audio) to the peer connection
// //     for (var track in _localStream.getTracks()) {
// //       _peerConnection.addTrack(track, _localStream);
// //     }

// //     // Create an offer for the remote peer and send it to Firestore
// //     _createOffer();
// //   }

// //   // Create a WebRTC offer and save it to Firestore
// //   Future<void> _createOffer() async {
// //     RTCSessionDescription description = await _peerConnection.createOffer();
// //     await _peerConnection.setLocalDescription(description);

// //     // Store the offer in Firestore for the remote peer to retrieve
// //     FirebaseFirestore.instance.collection('calls').doc(widget.roomId).set({
// //       'offer': {
// //         'sdp': description.sdp,
// //         'type': description.type,
// //       },
// //     });

// //     // Listen for an answer from the remote peer (patient)
// //     _listenForAnswer();
// //   }

// //   // Listen for an answer from the remote peer and set it as the remote description
// //   void _listenForAnswer() {
// //     FirebaseFirestore.instance
// //         .collection('calls')
// //         .doc(widget.roomId)
// //         .snapshots()
// //         .listen((snapshot) {
// //       if (snapshot.exists && snapshot.data()!['answer'] != null) {
// //         final answer = snapshot.data()!['answer'];
// //         final sessionDescription = RTCSessionDescription(
// //             answer['sdp'], answer['type']);
// //         _peerConnection.setRemoteDescription(sessionDescription);
// //       }
// //     });
// //   }

// //   // Clean up resources when the widget is disposed
// //   @override
// //   void dispose() {
// //     _localRenderer.dispose(); // Dispose of local video renderer
// //     _remoteRenderer.dispose(); // Dispose of remote video renderer
// //     _localStream.dispose(); // Dispose of the local media stream
// //     _peerConnection.close(); // Close the peer connection
// //     super.dispose();
// //   }

// //   // End the call and navigate back to the previous screen
// //   void _endCall() {
// //     _peerConnection.close(); // Close the WebRTC connection
// //     Navigator.pop(context); // Navigate back to the previous screen
// //   }

// //   // Build the video call screen UI
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Video Call'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.call_end),
// //             onPressed: _endCall, // Button to end the call
// //           ),
// //         ],
// //       ),
// //       body: Stack(
// //         children: [
// //           Column(
// //             children: [
// //               Expanded(
// //                 child: RTCVideoView(_remoteRenderer), // Remote video display
// //               ),
// //               Expanded(
// //                 child: RTCVideoView(_localRenderer, mirror: true), // Local video display
// //               ),
// //             ],
// //           ),
// //           if (!_uiInitialized) // Show a loading indicator until the connection is ready
// //             Center(
// //               child: CircularProgressIndicator(), // Display while waiting for connection
// //             ),
// //           Positioned(
// //             bottom: 20,
// //             left: 0,
// //             right: 0,
// //             child: _buildControlBar(), // Add a control bar with creative UI
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Build a control bar with buttons (e.g., mute, switch camera, etc.)
// //   Widget _buildControlBar() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           FloatingActionButton(
// //             heroTag: 'mute_audio',
// //             onPressed: () {
// //               // Add logic to mute/unmute audio
// //             },
// //             backgroundColor: Colors.redAccent,
// //             child: Icon(Icons.mic_off),
// //           ),
// //           FloatingActionButton(
// //             heroTag: 'switch_camera',
// //             onPressed: () {
// //               // Add logic to switch camera (front/rear)
// //             },
// //             backgroundColor: Colors.blueAccent,
// //             child: Icon(Icons.switch_camera),
// //           ),
// //           FloatingActionButton(
// //             heroTag: 'end_call',
// //             onPressed: _endCall, // End call button
// //             backgroundColor: Colors.red,
// //             child: Icon(Icons.call_end),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class CallPage extends StatefulWidget {
//   final String callID; // The UID of the patient

//   const CallPage({super.key, required this.callID});

//   @override
//   State<CallPage> createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   late User? currentUser; // Firebase user

//   @override
//   void initState() {
//     super.initState();
//     currentUser = FirebaseAuth.instance.currentUser; // Get the current user
//   }

//   @override
//   Widget build(BuildContext context) {
//     // If the user is not logged in or is null, show an error message
//     if (currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Error')),
//         body: Center(child: Text('User not logged in')),
//       );
//     }

//     return SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//         appID: 1687834211, // Your Zego app ID
//         appSign: '1fd38c815740e2108fbe13cd546afc8c8d8ea0a52056fe2d01e65457f00c2a96', // Your Zego app sign
//         callID: widget.callID, // Patient's UID from the waiting list
//         userID: currentUser!.uid, // Current logged-in user's UID
//         userName: currentUser!.displayName ?? 'Unknown', // Current user's name or fallback
//         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//       ),
//     );
//   }
// }

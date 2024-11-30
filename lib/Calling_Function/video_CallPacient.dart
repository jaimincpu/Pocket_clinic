// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// class PatientVideoCallScreen extends StatefulWidget {
//   final String channelId; // The channel the patient will join (doctor's uid)

//   PatientVideoCallScreen({required this.channelId});

//   @override
//   _PatientVideoCallScreenState createState() => _PatientVideoCallScreenState();
// }

// class _PatientVideoCallScreenState extends State<PatientVideoCallScreen> {
//   late RtcEngine _engine;
//   int _remoteUid = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     _engine = await RtcEngine.create('your_agora_app_id'); // Add Agora App ID here
//     await _engine.enableVideo();

//     _engine.setEventHandler(RtcEngineEventHandler(
//       joinChannelSuccess: (String channel, int uid, int elapsed) {
//         print('Patient joined channel: $channel, uid: $uid');
//       },
//       userJoined: (int uid, int elapsed) {
//         setState(() {
//           _remoteUid = uid;
//         });
//       },
//       userOffline: (int uid, UserOfflineReason reason) {
//         setState(() {
//           _remoteUid = 0;
//         });
//       },
//     ));

//     // Join the channel using the doctor's UID (same as the channel ID)
//     await _engine.joinChannel(null, widget.channelId, null, 0);
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Patient Video Call'),
//       ),
//       body: Center(
//         child: _remoteUid != 0 ? _renderRemoteVideo() : _renderLocalPreview(),
//       ),
//     );
//   }

//   Widget _renderLocalPreview() {
//     return AgoraVideoView(
//       controller: VideoViewController(
//         rtcEngine: _engine,
//         canvas: VideoCanvas(uid: 0),
//       ),
//     );
//   }

//   Widget _renderRemoteVideo() {
//     return AgoraVideoView(
//       controller: VideoViewController.remote(
//         rtcEngine: _engine,
//         canvas: VideoCanvas(uid: _remoteUid),
//       ),
//     );
//   }
// }

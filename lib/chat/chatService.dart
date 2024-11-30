// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';

// // class ChatService with ChangeNotifier {
// //   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

// //   Stream<QuerySnapshot> getMessages(String senderUserID, String receiverUserID) {
// //     String chatId = _getChatId(senderUserID, receiverUserID);
// //     return _firebaseFirestore
// //         .collection('messages')
// //         .doc(chatId)
// //         .collection('messages')
// //         .orderBy('timestamp', descending: true)
// //         .snapshots();
// //   }

// //   Future<void> sendMessage(String receiverUserID, String message) async {
// //     String chatId = _getChatId(_firebaseAuth.currentUser!.uid, receiverUserID);
// //     final Map<String, dynamic> chatMessage = {
// //       'senderId': _firebaseAuth.currentUser!.uid,
// //       'senderEmail': _firebaseAuth.currentUser!.email ?? '',
// //       'receiverId': receiverUserID,
// //       'receiverEmail': await _getReceiverEmail(receiverUserID), // Get receiver's email
// //       'message': message,
// //       'timestamp': Timestamp.now(),
// //       'chatId': chatId,
// //     };
// //     await _firebaseFirestore.collection('messages').doc(chatId).collection('messages').add(chatMessage);
// //   }

// //   String _getChatId(String userId1, String userId2) {
// //     return userId1.hashCode <= userId2.hashCode ? '$userId1-$userId2' : '$userId2-$userId1';
// //   }

// //   Future<String> _getReceiverEmail(String receiverUserID) async {
// //     final DocumentSnapshot userSnapshot = await _firebaseFirestore.collection('users').doc(receiverUserID).get();
// //     return userSnapshot.get('email') as String;
// //   }
// // }

// import 'dart:js_interop_unsafe';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/chat/DesiningChat/textFeild.dart';
// import 'package:flutter_application_1/chat/chat.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Stream<List<Map<String, dynamic>>> getUsersStream() {
//     return _firestore.collection("Users").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final user = doc.data();

//         return user;
//       }).toList();
//     });
//   }

//   Future<void> sendMessage(String receiverID, message) async {
//     final String currentUserID = _auth.currentUser!.uid;
//     final String currentUserEmail = _auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     Message newMessage = Message(
//         senderID: currentUserID,
//         senderEmail: currentUserEmail,
//         receiverID: receiverID,
//         message: message,
//         timestamp: timestamp);
//     List<String> ids = [currentUserID, receiverID];
//     ids.sort();
//     String chatRoomId = ids.join('_');

//     await _firestore
//         .collection("chat_rooms")
//         .doc(chatRoomId)
//         .collection("messages")
//         .add(newMessage.toMap());
//   }

//   Stream<QuerySnapshot> getMessages(String userID, otherUserId) {
//     List<String> ids = [userID, otherUserId];
//     ids.sort();
//     String chatRoomID = ids.join('_');
//     return _firestore
//         .collection("chat_room")
//         .doc(chatRoomID)
//         .collection("message")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//   }
// }

// class Message {
//   final String senderID;
//   final String senderEmail;
//   final String receiverID;
//   final String message;
//   final Timestamp timestamp;

//   Message({
//     required this.senderID,
//     required this.senderEmail,
//     required this.receiverID,
//     required this.message,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'senderID': senderID,
//       'senderEmail': receiverID,
//       'reciverId': receiverID,
//       'message': message,
//       'timestamp': timestamp,
//     };
//   }
// }

// class ChatPage extends StatelessWidget {
//   final String receiverEmail;
//   final String receiverID;

//   ChatPage({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   final TextEditingController _messageController = TextEditingController();

//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();

//   void sendMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       await _chatService.sendMessage(receiverID, _messageController.text);

//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(receiverEmail)),
//       body: Column(
//         children: [
//           Expanded(
//             child: _buildMessageList(),
//           ),

//           _buildUserInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     String senderId = _authService.getCurrentUser()!.uid;
//     return StreamBuilder(
//       stream: _chatService.getMessages(receiverID, senderId),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Text("Error");
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text("Loading..");
//         }

//         return ListView(
//           children:
//               snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).tolist(),
//         );
//       },
//     );
//   }

//   Widget _buidMessageItem(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//    bool isCurrentUser = data['senderID']== _authService.getCurrentUser()!.uid;
//  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
//     return Container(
//       alignment: alignment,
//       child: Text(data["message"]));
//   }

//   Widget _buildUserInput(){
//     return Row(
//       children: [
//         Expanded(child: MyTextField(controller: _messageController,hintText: "type a message", obscureText: false,),),

//         IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward),
//         ),
//       ],
//     )
//   }
// }

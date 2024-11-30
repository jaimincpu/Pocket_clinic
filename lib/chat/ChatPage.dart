// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application_1/chat/DesiningChat/Chatbubble.dart';

// class ChatPage extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverUID;

//   const ChatPage({
//     Key? key,
//     required this.receiverEmail,
//     required this.receiverUID,
//   }) : super(key: key);

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   String _chatId = '';

//   @override
//   void initState() {
//     super.initState();
//     _getChatId();
//   }

//   void _getChatId() async {
//     final currentUserID = _firebaseAuth.currentUser!.uid;
//     final receiverUID = widget.receiverUID;
//     List<String> ids = [currentUserID, receiverUID];
//     ids.sort(); // Ensure the IDs are sorted to create a unique chat ID
//     setState(() {
//       _chatId = ids.join('_');
//     });
//   }

//   void _sendMessage() async {
//     final String message = _messageController.text.trim();
//     if (message.isEmpty) {
//       return; // Don't send empty messages
//     }

//     try {
//       final currentUserID = _firebaseAuth.currentUser!.uid;
//       final currentUserEmail = _firebaseAuth.currentUser!.email!;
//       final receiverEmail = widget.receiverEmail;

//       final chatMessage = {
//         'senderID': currentUserID,
//         'senderEmail': currentUserEmail,
//         'receiverID': widget.receiverUID,
//         'receiverEmail': receiverEmail,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       await _firebaseFirestore
//           .collection('chat_rooms')
//           .doc(_chatId)
//           .collection('messages')
//           .add(chatMessage);

//       _messageController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: $e')),
//       );
//     }
//   }

//   Stream<QuerySnapshot> _getMessagesStream() {
//     return _firebaseFirestore
//         .collection('chat_rooms')
//         .doc(_chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.receiverEmail)),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _getMessagesStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error loading messages: ${snapshot.error}'));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No messages yet.'));
//                 }
//                 return ListView.builder(
//                   reverse: false,
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                     final senderEmail = messageData['senderEmail'];
//                     final message = messageData['message'];
//                     final isMe = senderEmail == _firebaseAuth.currentUser!.email;
//                     return ChatBubble(message: message, isMe: isMe);
//                   },
//                 );
//               },
//             ),
//           ),
//           TextField(
//             controller: _messageController,
//             decoration: InputDecoration(hintText: 'Type your message'),
//             onChanged: (value) {
//               // This line prevents updating the UI with every change in the text field
//               // setState(() {});
//             },
//           ),
//           TextButton(
//             onPressed: _sendMessage,
//             child: Text('Send'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DesiningChat/Chatbubble.dart';
import 'DesiningChat/textFeild.dart';


class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserId) {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms") // corrected the collection name here
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderID, // corrected the variable name here
      'receiverId': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  var username;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    this.username,
  });

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username, // Display the receiverUID instead of receiverEmail
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),     backgroundColor: Color.fromARGB(255, 2, 44, 35),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      // changed the type of the stream
      stream: _chatService.getMessages(receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buidMessageItem(doc))
              .toList(), // corrected the method call here
        );
      },
    );
  }

  Widget _buidMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: ChatBubble(
        message: data["message"],
        isMe: isCurrentUser,
      ),
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            controller: _messageController,
            hintText: "type a message",
            obscureText: false,
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

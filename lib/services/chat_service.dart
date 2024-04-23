import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatService {
  // get instance of firestore  & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool ok = false;
  // get user stream

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshots) {
      return snapshots.docs.map((docs) {
        final user = docs.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStatus() {
    return _firestore.collection("Users").snapshots().map((snapshots) {
      return snapshots.docs.map((docs) {
        final status = docs.data();
        return status;
      }).toList();
    });
  }

  // showList
  /*Future<bool> showList(String userId, recevireId) async {
    List<String> ids = [
      userId,
      recevireId,
    ];

    print("sender:$userId");
    print("recevier:$recevireId");
    ids.sort();
    String chatRoomId = ids.join('_');

    var docs = _firestore.collection("chat_rooms").doc(chatRoomId).get();
   // return docs.;
    print(ok);
    /*var result =
        await _firestore.collection("chat_rooms").snapshots().map((snapshots) {
      return snapshots.docs.map((docs) {
        final user = docs.data();
        print(user);
      }).toList();
    });*/
    //print(result);
  }*/

  Future<void> isblock() async {
    _firestore
        .collection("chat_rooms")
        .doc("f2D7AcCUgBfuQO3J8GyOsOYXiln2_jeImkDI9AzXpfjT4OGgNL7AMCyc2")
        .collection("messages")
        .doc()
        .update({'isBlock': false});
    //.where("isblock", isEqualTo: true);

    //.update({"isblock": false}).whenComplete(() => print("hiii"));
  }

  // Send Message
  Future<void> sendMessage(String recevierId, message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create chat room for two users
    List<String> ids = [currentUserId, recevierId];
    ids.sort();
    String chatRoomId = ids.join('_');

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("kk.mm").format(now);

    //  Create Unique message id

    var messageId = Uuid().v1();

    // Create new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: recevierId,
      message: message,
      messageId: messageId,
      type: "text",
      senderSide: true,
      receiverSide: true,
      chatRoomId: chatRoomId,
      timestamp: timestamp,
      time: formattedDate,
    );

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .set(
          newMessage.toMap(),
        );
  }

  // upload image
  Future<void> uploadFile(String recevierId, fileName, url, type) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    List<String> ids = [currentUserId, recevierId];
    ids.sort();
    String chatRoomId = ids.join('_');

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("kk.mm").format(now);

    _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(fileName)
        .set({
      "senderId": currentUserId,
      "senderEmail": currentUserEmail,
      "receiverId": recevierId,
      "message": url,
      "message_id": fileName,
      "type": type,
      "chat_room_id": chatRoomId,
      "timestamp": Timestamp.now(),
      "time": formattedDate,
    });
  }

  Future<void> uploadImagedelete(String recevierId, fileName) async {
    final String currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, recevierId];
    ids.sort();
    String chatRoomId = ids.join('_');
    _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .doc(fileName)
        .delete();
  }

  Future<void> uploadImageupdate(String recevierId, fileName, imageUrl) async {
    final String currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, recevierId];
    ids.sort();
    String chatRoomId = ids.join('_');
    _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .doc(fileName)
        .update({"message": imageUrl});
  }

  // Get Message
  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Get Last Message
  Future<void> getLastMessage(String userId, otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .get()
        .then((m) {
      if (m.docs.isNotEmpty) {
        var lastMessage = m.docs.firstOrNull!.data()['message'];
        return lastMessage;
        //print(lastMessage);
        //id
      }
    });
  }

  // Delete All Messages from Chat Room
  Future<void> deleteAllMessage(String userId, otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    print(chatRoomId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .delete()
        .whenComplete(() => print("success"));

    //var documentReference = _firestore.collection('chat_rooms').doc();
    //.collection("messages")
    //.doc();
    //.collection('messages')
    //.doc();
    //.update({"message": "hii"});
    //.where('chat_room_id', isEqualTo: chatRoomId);

    //.doc(chatRoomId);
    //.collection("messages")
    //.doc();

    //await documentReference
    //    .delete()
    //    .then((value) => print("Success Delete"))
    //    .catchError((e) => print("Failed to delete the chat room: $e"));
  }

  // Delete one Messages from Chat Room
  Future<void> deleteOneMessage(String userId, otherUserId, messageId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    var documentReference = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId);
    await documentReference
        .delete()
        .catchError((e) => print("Failed to delete the message: $e"));
  }

  // Delete image from  Firebase Storage and Firestore DB
  Future<void> deleteFile(String userId, otherUserId, messageId, type) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    var documentReference = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId);
    await documentReference.delete().catchError(
        (e) => print("Failed to delete the image from database: $e"));

    type == "img"
        ? _firebaseStorage
            .refFromURL('gs://learn-b2550.appspot.com')
            .child('image/$messageId')
            .delete()
        : _firebaseStorage
            .refFromURL('gs://learn-b2550.appspot.com')
            .child('pdf/$messageId')
            .delete();
  }
}

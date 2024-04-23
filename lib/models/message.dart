import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String messageId;
  final String type;
  final bool senderSide;
  final bool receiverSide;
  final String chatRoomId;
  final Timestamp timestamp;
  final String time;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.messageId,
    required this.type,
    required this.senderSide,
    required this.receiverSide,
    required this.chatRoomId,
    required this.timestamp,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'message_id': messageId,
      'type': type,
      'sender_side': senderSide,
      'receiver_side': receiverSide,
      'chat_room_id': chatRoomId,
      'timestamp': timestamp,
      'time': time,
    };
  }
}

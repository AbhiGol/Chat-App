import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/auth_service.dart';
import 'package:firebase/services/chat_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status"),
      ),
      body: _buildUserList(),
    );
  }

  Future<void> _searchDialog(String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: AlertDialog(
            //title: const Text('search here'),
            content: SingleChildScrollView(
              child: Container(
                child: Image.network(
                  url,
                  fit: BoxFit.fill,
                  //height: 400,
                  //width: 400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStatus(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.amber,
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.amberAccent,
                ),
              ),
            ],
          );
        }
        // Return List View
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["uid"] != _authService.getCurrentUser()!.uid) {
      //if (_chatService.showList(_authService.getCurrentUser()!.uid,userData["uid"]) !=
      //   userData["uid"]) {
      //_chatService.showList(
      //    _authService.getCurrentUser()!.uid, userData["uid"]);
      return UserTile(
        text: userData["user_name"],
        url: userData["url"],
        about: userData["about"],
        isStatus: userData["isstatus"],
        //currentUser:  userData[""]
        //lastMessage: userData["last_message"],
        //subtext: last,
        onTap: () {
          _searchDialog(userData["status"]);
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverId: userData["uid"],
                username: userData["user_name"],
                url: userData["url"],
                visible: userData["online"],
                lastactive: userData["last_active"],
                showActive: userData["show_active"],
                isonline: isOnline!,
              ),
            ),
          );*/
        },
      );
      // } else {
      //   return Container();
      // }
    } else {
      return Container(
          //child: Text("me"),
          );
    }
    // } else {
    //  return Container();
    // }
  }
}

class UserTile extends StatelessWidget {
  UserTile(
      {super.key,
      required this.text,
      //required this.lastMessage,
      required this.onTap,
      required this.about,
      required this.isStatus,
      required this.url});

  final String text;
  //final String lastMessage;
  final String url;
  final String about;
  final bool isStatus;
  final AuthService _authService = AuthService();
  final void Function()? onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: isStatus == true
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(
                      2.0,
                      3.0,
                    ),
                    blurRadius: 2.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ProfilePicture(
                    name: text,
                    img: url.isEmpty ? null : url,
                    radius: 25,
                    fontsize: 25,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 350,
                          child: Text(
                            text,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 25),
                          ),
                        ),
                        Container(
                          width: 350,
                          alignment: Alignment.bottomLeft,
                          //child: Text(about),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}

import 'dart:html';
import 'dart:html' as File show File;
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/pages/chat_page.dart';
import 'package:firebase/services/auth_service.dart';
import 'package:firebase/services/chat_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

import 'dart:async';

import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //  Services
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  //final TextEditingController _urlController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool showLastActive = false;

  bool? isOnline = window.navigator.onLine;
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  // init state
  @override
  void initState() {
    super.initState();

    window.onAbort.listen((_) {
      setState(() {
        isOnline = true;
      });
    });
    setStatus(true);
    print(isOnline);
    super.initState();
  }

  @override
  void dispose() {
    //s WidgetsBinding.instance.removeObserver(this);
    setStatus(false);
    super.dispose();
  }

  // For chechk user is online or  not
  void setStatus(bool status) async {
    var currUser = _authService.getCurrentUser()!;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMM yyy').format(now);

    if (currUser != null) {
      await _firestore.collection('Users').doc(currUser.uid).update(
        {"online": status, "last_active": formattedDate},
      );
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Online
      setStatus(true);
    } else {
      // Ofline
      setStatus(false);
    }
  }

  // For Update Last Active
  void updatLastActive(showActive) async {
    await _authService.updateLastActive(showActive);
  }

  // For Update method
  void update(username, about) async {
    await _authService
        .updateData(username, about)
        .then((value) => Navigator.pop(context));

    _usernameController.clear();

    _aboutController.clear();
  }

  // For Sign Out Method
  void signout() async {
    await _authService
        .signOut()
        .whenComplete(() => Navigator.pushReplacementNamed(context, '/login'));
    setStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildUserList(),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: StreamBuilder(
          stream: _chatService.getUsersStream(),
          builder: (context, snapshot) {
            return ListView(
              children: snapshot.data!
                  .map<Widget>((userData) => _drawer(userData, context))
                  .toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.grey[400],
        hoverColor: Colors.black12,
        child: const Icon(Icons.smart_display),
        onPressed: () {
          //_searchDialog();
          Navigator.pushNamed(context, '/status');
        },
      ),
    );
  }

  // Show Profile Picture
  Future<void> _showProfilePicture(String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: ProfilePicture(
            name: "",
            radius: 4,
            img: url.isEmpty
                ? "data:image/jpeg;base64,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"
                : url,
            fontsize: 11,
          ),
        );
      },
    );
  }

  // For Search  Functionality
  Future<void> _searchDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('search here'),
          content: SingleChildScrollView(
            child: Form(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(hintText: 'Search Users...'),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                //_search(_searchController.text);
                Navigator.pushNamed(context, '/status');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Profile Picture Select

  void profileSelect({required Function(File.File file) onSelected}) {
    FileUploadInputElement uploadInput = FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        onSelected(file);
        print("done");
      });
    });
  }

  // Profile Picture Upload in database
  void uploadToStorage() async {
    final imageId = Uuid().v1();
    final path = 'image/$imageId';
    profileSelect(onSelected: (file) {
      _firebaseStorage
          .refFromURL('gs://learn-b2550.appspot.com')
          .child(path)
          .putBlob(file)
          .whenComplete(() => downloadurl(path, imageId));
    });
  }

  // Download Profile Picture Url
  void downloadurl(path, imageId) async {
    var ref = FirebaseStorage.instance
        .refFromURL('gs://learn-b2550.appspot.com')
        .child(path);
    String url = (await ref.getDownloadURL()).toString();
    _authService.uploadProfilePicture(url);
  }

  // Status Upload in database
  void statusUploadToStorage() async {
    final statusid = Uuid().v1();
    final path = 'status/$statusid';
    profileSelect(onSelected: (file) {
      _firebaseStorage
          .refFromURL('gs://learn-b2550.appspot.com')
          .child(path)
          .putBlob(file)
          .whenComplete(() => downloadStatusUrl(path, statusid));
    });
  }

  // Download status Url
  void downloadStatusUrl(path, statusid) async {
    var ref = FirebaseStorage.instance
        .refFromURL('gs://learn-b2550.appspot.com')
        .child(path);
    String url = (await ref.getDownloadURL()).toString();
    _authService.uploadStatus(url, statusid).whenComplete(() => Navigator.pop(context));
  }

  // Widget for Drawer
  Widget _drawer(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] == _authService.getCurrentUser()!.email) {
      return //Container(
          //color: Theme.of(context).primaryColor,
          // child:
          Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: GestureDetector(
              child: ProfilePicture(
                name: userData["user_name"],
                radius: 30,
                fontsize: 23,
                img: userData["url".isEmpty ? "user_name" : "url"],
              ),
              onTap: () {
                uploadToStorage();
                print("Tap here");
              },
            ),
            title: Text(
              userData["user_name"],
              style: const TextStyle(fontSize: 23),
            ),
            subtitle: Text(
              userData["email"],
              style: const TextStyle(fontSize: 17),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 2,
              width: 250,
              child: Container(color: Colors.black),
            ),
          ),
          SizedBox(
              height: 700,
              child: Container(
                margin: const EdgeInsets.only(top: 30, left: 25, right: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "User Name : ",
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.zero,
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: userData["user_name"],
                            hintStyle: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w200),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              //return "Please enter your username";
                              _usernameController.text = userData["user_name"];
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 25),
                        child: const Text(
                          "Status: ",
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                statusUploadToStorage();
                              },
                              child: const Text(
                                "Upload",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            const SizedBox(width: 40),
                            ElevatedButton(
                              onPressed: () {
                                _authService
                                    .deleteStatus(userData["statusid"])
                                    .whenComplete(() => Navigator.pop(context));
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 25),
                        child: const Text(
                          "About : ",
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.zero,
                        child: TextFormField(
                          controller: _aboutController,
                          decoration: InputDecoration(
                            hintText: userData["about"],
                            hintStyle: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w200),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              //return "Please enter your username";
                              _aboutController.text = userData["about"];
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(top: 25),
                              child: const Text(
                                "Last Active : ",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w400),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(left: 70, top: 20),
                              child: Switch(
                                  activeColor: Colors.black87,
                                  value: userData["show_active"],
                                  onChanged: (value) {
                                    setState(() {
                                      updatLastActive(value);
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: ElevatedButton(
                          child: const Text("Edit Data"),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              update(_usernameController.text,
                                  _aboutController.text);

                              _usernameController.text = '';
                              _aboutController.text = '';
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              height: 2,
              width: 250,
              child: Container(color: Colors.black),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Text(
                      "Log out",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    )),
                Container(
                  margin: const EdgeInsets.only(left: 140),
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout,
                    ),
                    onPressed: () {
                      signout();
                      setStatus(false);
                    },
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  // Widget buildUserList
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
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

  // Last message
  void lastMessage(currentUser, recevierUser) {
    dynamic last = _chatService.getLastMessage(currentUser, recevierUser);

    print(last);
  }

  //Widget individual User List Item
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      //if (_chatService.showList(_authService.getCurrentUser()!.uid,userData["uid"]) !=
      //   userData["uid"]) {
      //_chatService.showList(
      //    _authService.getCurrentUser()!.uid, userData["uid"]);
      return UserTile(
          text: userData["user_name"],
          url: userData["url"],
          about: userData["about"],
          //lastMessage: userData["last_message"],
          // subtext: last,
          onTap: () {
            Navigator.push(
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
            );
          },
          onTap1: () {
            //show();
            _showProfilePicture(userData["url"]);
          });
      // } else {
      //   return Container();
      // }
    } else {
      return Container();
    }
    // } else {
    //  return Container();
    // }
  }
}

// UserTile classs
class UserTile extends StatelessWidget {
  const UserTile(
      {super.key,
      required this.text,
      //required this.lastMessage,
      required this.onTap,
      required this.onTap1,
      required this.about,
      required this.url});

  final String text;
  //final String lastMessage;
  final void Function()? onTap1;
  final String url;
  final String about;
  final void Function()? onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            GestureDetector(
              onTap: onTap1,
              child: ProfilePicture(
                name: text,
                img: url.isEmpty ? null : url,
                radius: 25,
                fontsize: 25,
              ),
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
                    child: Text(about),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

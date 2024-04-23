import 'dart:html' as File show File;
import 'dart:html';
import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/pages/pdf_viewer.dart';
import 'package:firebase/services/auth_service.dart';
import 'package:firebase/services/chat_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatelessWidget {
  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
    required this.username,
    required this.url,
    required this.visible,
    required this.lastactive,
    required this.showActive,
    required this.isonline,
  });

  final String receiverEmail;
  final String receiverId;
  final String username;
  final String url;
  final bool visible;
  final String lastactive;
  final bool showActive;
  final bool isonline;

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();

  void scroller() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 2), curve: Curves.easeInOut);
  }

  // For this Send  Messages
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverId, _messageController.text);
      // _chatService.getLastMessage(_authService.getCurrentUser()!.uid,
      //    receiverId, _messageController.text);
      _messageController.clear();
    }
  }

  // For Open file

  uploadImage({required Function(File.File file) onSelected}) {
    FileUploadInputElement uploadInput = FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        onSelected(file);
        //print("done");
      });
    });
  }

  // Upload Image
  void uploadToStorage() async {
    final imageId = Uuid().v1();
    final path = 'image/$imageId';
    uploadImage(onSelected: (file) {
      _firebaseStorage
          .refFromURL('gs://learn-b2550.appspot.com')
          .child(path)
          .putBlob(file)
          .whenComplete(() => downloadUrlForImage(path, imageId));
    });
  }

  // Download Image Url
  void downloadUrlForImage(path, imageId) async {
    var ref = FirebaseStorage.instance
        .refFromURL('gs://learn-b2550.appspot.com')
        .child(path);
    String url = (await ref.getDownloadURL()).toString();
    _chatService.uploadFile(receiverId, imageId, url, "img");
  }

  // Download Pdf Url
  void downloadUrlForPdf(path, pdfId) async {
    var ref = FirebaseStorage.instance
        .refFromURL('gs://learn-b2550.appspot.com')
        .child(path);
    String url = (await ref.getDownloadURL()).toString();
    _chatService.uploadFile(receiverId, pdfId, url, "pdf");
  }

  // For Open Pdf file
  uploadPdf({required Function(File.File file) onSelected}) {
    FileUploadInputElement uploadInput = FileUploadInputElement()
      ..accept = 'pdf/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        onSelected(file);
        //print("done");
      });
    });
  }

  //  Upload Pdf
  void uploadPdfToStorage() async {
    final pdfId = Uuid().v1();
    final path = 'pdf/$pdfId';
    uploadPdf(onSelected: (file) {
      _firebaseStorage
          .refFromURL('gs://learn-b2550.appspot.com')
          .child(path)
          .putBlob(file)
          .whenComplete(() => downloadUrlForPdf(path, pdfId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: ProfilePicture(
                name: username,
                radius: 23,
                fontsize: 24,
                img: url.isEmpty ? null : url,
              ),
              title: Text(
                username,
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
              ),
              subtitle: visible
                  ? Text(
                      isonline ? "online" : "offline",
                      //"online",
                      style: const TextStyle(fontSize: 14),
                    )
                  : Text(showActive
                      ? "Last Seen $lastactive"
                      : "Last Seen Not Available"),
            ),
          ],
        ),
        /* actions: [
          PopupMenuButton<int>(
            color: Colors.grey[100],
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: GestureDetector(
                  child: const Row(
                    children: [
                      // Icon(Icons.delete),
                      //SizedBox(width: 10),
                      //Text("Delete All"),
                    ],
                  ),
                  onTap: () {
                    _chatService.deleteAllMessage(
                        receiverId, _authService.getCurrentUser()!.uid);
                    // _chatService.isblock();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],*/
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // This is where the chats will go

            Expanded(
              child: _buildMessageList(context),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[400],
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter message',
                          hintStyle: TextStyle(fontSize: 18)),
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.black12,
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[250],
                              ),
                              height: 100,
                              width: 500,
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      uploadPdfToStorage();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 20),
                                            child: const Icon(
                                              Icons.picture_as_pdf_outlined,
                                              size: 30,
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 30),
                                            child: const Text(
                                              "Attech Pdf File",
                                              style: TextStyle(fontSize: 25),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      uploadToStorage();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 20),
                                            child: const Icon(
                                              Icons.image,
                                              size: 30,
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 30),
                                            child: const Text(
                                              "Attech image File",
                                              style: TextStyle(fontSize: 25),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      //uploadToStorage();
                      //final result = await FilePickerWeb.platform.pickFiles();
                      //ImagePicker().pickImage(source: ImageSource.gallery);
                      //if (result == null) return null;
                      // open single file
                      //final file = result.files.first;
                      //openFile(file);
                    },
                    icon: const Icon(
                      Icons.attach_file,
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.black12,
                    onPressed: () {
                      sendMessage();
                      scroller();
                      _scrollController.animateTo(
                          _scrollController.position.extentTotal,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ScrollController  forScroll

  // Widget Message List

  Widget _buildMessageList(context) {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          controller: _scrollController,
          shrinkWrap: true,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, context))
              .toList(),
        );
      },
    );
  }

  // Build Message Item

  Widget _buildMessageItem(DocumentSnapshot doc, context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onDoubleTap: () {},
      child: data["isblock"] == true
          ? Container()
          : data["type"] == "text"
              ? Container(
                  alignment: alignment,
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            isCurrentUser
                                ? Container()
                                : Container(
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(top: 40),
                                    child: PopupMenuButton(
                                      surfaceTintColor: Colors.grey[150],
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 1,
                                          child: GestureDetector(
                                            child: const Row(
                                              children: <Widget>[
                                                Icon(Icons.delete),
                                                SizedBox(width: 10),
                                                Text("Delete")
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            _chatService.deleteOneMessage(
                                                receiverId,
                                                _authService
                                                    .getCurrentUser()!
                                                    .uid,
                                                data["message_id"]);
                                          },
                                        ),
                                      ],
                                      icon: const Icon(
                                        Icons.more_vert,
                                      ),
                                    ),
                                  ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: isCurrentUser
                                  ? const EdgeInsets.only(
                                      top: 10, right: 0, left: 15)
                                  : const EdgeInsets.only(
                                      top: 10, left: 0, right: 0),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                borderRadius: isCurrentUser
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10))
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                              ),
                              child: Text(
                                data["message"],
                                style: isCurrentUser
                                    ? const TextStyle(fontSize: 23)
                                    : const TextStyle(
                                        fontSize: 23, color: Colors.white),
                              ),
                            ),
                            isCurrentUser
                                ? Container(
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(top: 40),
                                    child: PopupMenuButton(
                                      surfaceTintColor: Colors.grey[150],
                                      itemBuilder: (context) => [
                                        /*PopupMenuItem(
                                        value: 1,
                                        child: GestureDetector(
                                          child: const Row(
                                            children: <Widget>[
                                              Icon(Icons.delete),
                                              SizedBox(width: 40),
                                              Text("Delete")
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          _chatService.deleteOneMessage(
                                              receiverId,
                                              _authService
                                                  .getCurrentUser()!
                                                  .uid,
                                              data["message_id"]);
                                        },
                                      ),*/
                                        PopupMenuItem(
                                          value: 1,
                                          child: GestureDetector(
                                            child: const Row(
                                              children: <Widget>[
                                                Icon(Icons.delete),
                                                SizedBox(width: 10),
                                                Text("Delete")
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            _chatService.deleteOneMessage(
                                                receiverId,
                                                _authService
                                                    .getCurrentUser()!
                                                    .uid,
                                                data["message_id"]);
                                          },
                                        )
                                      ],
                                      icon: const Icon(
                                        Icons.more_vert,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Container(
                        margin: isCurrentUser
                            ? const EdgeInsets.only(right: 37)
                            : const EdgeInsets.only(left: 37),
                        child: Text(data["time"]),
                      ),
                    ],
                  ),
                )
              : data["type"] == "img"
                  ? InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(data["message"]);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: Container(
                        alignment: alignment,
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: <Widget>[
                                  isCurrentUser
                                      ? Container()
                                      : Container(
                                          alignment: Alignment.bottomRight,
                                          margin:
                                              const EdgeInsets.only(top: 225),
                                          child: PopupMenuButton(
                                            surfaceTintColor: Colors.grey[150],
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: GestureDetector(
                                                  child: const Row(
                                                    children: <Widget>[
                                                      Icon(Icons.delete),
                                                      SizedBox(width: 10),
                                                      Text("Delete")
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  _chatService.deleteOneMessage(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"]);
                                                  _chatService.deleteFile(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"],
                                                      data["type"]);
                                                },
                                              )
                                            ],
                                            icon: const Icon(
                                              Icons.more_vert,
                                            ),
                                          ),
                                        ),
                                  Container(
                                    //padding: const EdgeInsets.all(10),
                                    margin: isCurrentUser
                                        ? const EdgeInsets.only(
                                            top: 10, right: 0, left: 15)
                                        : const EdgeInsets.only(
                                            top: 10, left: 0, right: 15),
                                    alignment: isCurrentUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                        borderRadius: isCurrentUser
                                            ? const BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                                topLeft: Radius.circular(10))
                                            : const BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                      ),
                                      child: Image.network(
                                        data["message"].toString(),
                                        width: 150,
                                        height: 230,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  isCurrentUser
                                      ? Container(
                                          alignment: Alignment.bottomRight,
                                          margin:
                                              const EdgeInsets.only(top: 225),
                                          child: PopupMenuButton(
                                            surfaceTintColor: Colors.grey[150],
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: GestureDetector(
                                                  child: const Row(
                                                    children: <Widget>[
                                                      Icon(Icons.delete),
                                                      SizedBox(width: 10),
                                                      Text("Delete")
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  _chatService.deleteOneMessage(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"]);
                                                  _chatService.deleteFile(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"],
                                                      data["type"]);
                                                },
                                              )
                                            ],
                                            icon: const Icon(
                                              Icons.more_vert,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Container(
                              margin: isCurrentUser
                                  ? const EdgeInsets.only(right: 37)
                                  : const EdgeInsets.only(left: 37),
                              child: Text(data["time"]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        //print(data["message"]);
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PdfViewer(pdfUrl: data["message"])));*/
                        final Uri url = Uri.parse(data["message"]);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: Container(
                        alignment: alignment,
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: <Widget>[
                                  isCurrentUser
                                      ? Container()
                                      : Container(
                                          alignment: Alignment.bottomRight,
                                          margin:
                                              const EdgeInsets.only(top: 140),
                                          child: PopupMenuButton(
                                            surfaceTintColor: Colors.grey[150],
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: GestureDetector(
                                                  child: const Row(
                                                    children: <Widget>[
                                                      Icon(Icons.delete),
                                                      SizedBox(width: 10),
                                                      Text("Delete")
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  _chatService.deleteOneMessage(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"]);
                                                  _chatService.deleteFile(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"],
                                                      data["type"]);
                                                },
                                              )
                                            ],
                                            icon: const Icon(
                                              Icons.more_vert,
                                            ),
                                          ),
                                        ),
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    // padding: const EdgeInsets.all(10),
                                    margin: isCurrentUser
                                        ? const EdgeInsets.only(
                                            top: 6, right: 0, left: 15)
                                        : const EdgeInsets.only(
                                            top: 6, left: 0, right: 15),
                                    alignment: isCurrentUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                          borderRadius: isCurrentUser
                                              ? const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10))
                                              : const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                        ),
                                        child: Image.network(
                                          "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/PDF_file_icon.svg/1200px-PDF_file_icon.svg.png",
                                          fit: BoxFit.cover,
                                          height: 150,
                                          width: 150,
                                        )),
                                  ),
                                  isCurrentUser
                                      ? Container(
                                          alignment: Alignment.bottomRight,
                                          margin:
                                              const EdgeInsets.only(top: 140),
                                          child: PopupMenuButton(
                                            surfaceTintColor: Colors.grey[150],
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: GestureDetector(
                                                  child: const Row(
                                                    children: <Widget>[
                                                      Icon(Icons.delete),
                                                      SizedBox(width: 10),
                                                      Text("Delete")
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  _chatService.deleteOneMessage(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"]);
                                                  _chatService.deleteFile(
                                                      receiverId,
                                                      _authService
                                                          .getCurrentUser()!
                                                          .uid,
                                                      data["message_id"],
                                                      data["type"]);
                                                },
                                              )
                                            ],
                                            icon: const Icon(
                                              Icons.more_vert,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Container(
                              margin: isCurrentUser
                                  ? const EdgeInsets.only(right: 37)
                                  : const EdgeInsets.only(left: 37),
                              child: Text(data["time"]),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

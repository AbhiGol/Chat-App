import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  // Instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Get Current User
  getCurrentUser() {
    return _auth.currentUser;
  }

  // For Sign in
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Save in  Firestore the new user data
      /* _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        //'user_name': ,
        'email': email,
      });*/

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // For Sign Up
  Future<UserCredential> signUp(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save in  Firestore the new user data
      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'user_name': username,
        'email': email,
        'url': "",
        'online': "",
        'last_active': "",
        'show_active': true,
        "about": "Hey there! I am using App.",
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // For Sign Out
  signOut() => _auth.signOut();

  // For update data
  Future<void> updateData(String? name, String? about) async {
    final user = _auth.currentUser!;
    if (name != null) {
      return _firestore.collection('Users').doc(user.uid).update({
        'user_name': name,
        'about': about,
      });
    }
  }

  // For Update last active
  Future<void> updateLastActive(bool showActive) async {
    final user = _auth.currentUser!;

    return _firestore.collection('Users').doc(user.uid).update({
      'show_active': showActive,
    });
  }

  // Upload Profile Picture
  Future<void> uploadProfilePicture(String url) async {
    final user = _auth.currentUser;

    return _firestore.collection("Users").doc(user!.uid).update({
      'url': url,
    });
  }

  Future<void> uploadStatus(String url, statusid) async {
    final user = _auth.currentUser;

    return _firestore
        .collection("Users")
        .doc(user!.uid)
        .update({'status': url, 'isstatus': true, 'statusid': statusid});
  }

  Future<void> deleteStatus(String statusid) async {
    final user = _auth.currentUser;

    _firestore
        .collection("Users")
        .doc(user!.uid)
        .update({'status': "", 'isstatus': false, 'statusid': ""});
    _firebaseStorage
        .refFromURL('gs://learn-b2550.appspot.com')
        .child('status/$statusid')
        .delete();
  }
}

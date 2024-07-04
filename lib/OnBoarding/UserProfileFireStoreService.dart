import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileFireStoreService
 {
  Future<void> addUserData(
      User user, Map<String, dynamic> additionalData) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    await users.doc(user.uid).set(additionalData);
  }  
  
  Future<void> addUsername(
      User user, String username) async {
    CollectionReference usernames = FirebaseFirestore.instance.collection('usernames');
    await usernames.doc(username).set({'uid': user.uid});
  }

  Future<void> addNewUser(User user, String username) async {
    addUserData(user, {
      'connectedMusicServices': {},
    });
    addUsername(user, username);


  }
}

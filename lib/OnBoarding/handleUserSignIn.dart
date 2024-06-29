import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HandleUserSignIn {
  Future<void> addUserData(
      User user, Map<String, dynamic> additionalData) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    Map<String, dynamic> userData = {
      'username': user.displayName,
      ...additionalData, // This spreads the additionalData into the userData map
    };

    await users.doc(user.uid).set(userData);
  }
}

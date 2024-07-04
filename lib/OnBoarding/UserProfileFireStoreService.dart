import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';

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

  Future<void> addNewExternealSignInPlatformUser(User user) async {
    if (user.displayName != null) {
      addNewUser(user, user.displayName!);
    }
    else {
          addUserData(user, {
      'connectedMusicServices': {},
    });
    }

  }

  Future<void> addMusicService(
      String uid, MusicLibraryService musicService, Map<String, dynamic> data) async {
   CollectionReference users = FirebaseFirestore.instance.collection('Users');
  DocumentReference userDoc = users.doc(uid);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot snapshot = await transaction.get(userDoc);
    if (snapshot.exists) {
      Map<String, dynamic> connectedMusicServices = snapshot.get('connectedMusicServices') ?? {};
      // Add or update the music service data
      connectedMusicServices[musicService.name] = data;

      // Update the document with the new connectedMusicServices map
      transaction.update(userDoc, {'connectedMusicServices': connectedMusicServices});
    }
  });
  }

  Future<Map<String, dynamic>?> getConnectedMusicLibraries(String uid) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    return users.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.get('connectedMusicServices');
      } else {
        return null;
      }
    });
  }
}

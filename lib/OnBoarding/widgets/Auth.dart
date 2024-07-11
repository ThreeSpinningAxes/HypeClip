import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hypeclip/OnBoarding/UserProfileFireStoreService.dart";
import "package:hypeclip/Services/UserService.dart";
import "package:hypeclip/Utilities/ShowErrorDialog.dart";



class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign in with Email and Password
  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Check if User is Signed In
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign Out
  Future<void> signOut() async {
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }

  Future<void> deleteUser() async {
    
  }

    Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
          

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
          
      final User? user =
          userCredential.user ?? FirebaseAuth.instance.currentUser;
          
      Userservice.setUser(user!.uid, user.displayName!, user.email!, true);
      await Userservice.initMusicServicesForStorage();
      if (userCredential.additionalUserInfo!.isNewUser) {
        UserProfileFireStoreService().addNewExternealSignInPlatformUser(user);
      }

      if (!userCredential.additionalUserInfo!.isNewUser) {
        await Userservice.fetchAndStoreConnectedMusicLibrariesFromFireStore();
      }
      
      return userCredential;

      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      ShowSnackBar.showSnackbarError(context, e.toString(), 3);
      return null;
    }
  }
}
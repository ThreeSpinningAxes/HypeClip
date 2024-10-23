import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hypeclip/OnBoarding/UserProfileFireStoreService.dart";
import "package:hypeclip/Services/UserProfileService.dart";
import "package:hypeclip/Utilities/ShowSnackbar.dart";

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign in with Email and Password
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
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

  Future<void> deleteUser() async {}

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

      UserProfileService.setUser(user!.uid, user.displayName!, user.email!, true);
      await UserProfileService.initUserMusicData(fetchDataFromFirebase: !userCredential.additionalUserInfo!.isNewUser);

      if (userCredential.additionalUserInfo!.isNewUser) {
        await UserProfileFireStoreService().addNewExternealSignInPlatformUser(user);
      }

      return userCredential;

      // Use the user object for further operations or navigate to a new screen.
    } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case "account-exists-with-different-credential":
        errorMessage = "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.";
      case "invalid-credential":
        errorMessage = "The credential is malformed or has expired.";
      case "operation-not-allowed":
        errorMessage = "The type of account corresponding to the credential is not enabled. Please enable it in the Firebase Console, under the Auth tab.";
      case "user-disabled":
        errorMessage = "The user corresponding to the given credential has been disabled.";
      case "user-not-found":
        errorMessage = "There is no user corresponding to the given email.";
      case "wrong-password":
        errorMessage = "Wrong password provided for the given email address.";
      case "invalid-verification-code":
        errorMessage = "The verification code of the credential is not valid.";
      case "invalid-verification-id":
        errorMessage = "The verification ID of the credential is not valid.";
      default:
        errorMessage = "An undefined Error happened.";
    }
    
    ShowSnackBar.showSnackbarError(context, errorMessage, 3);
  } catch (e) {
    ShowSnackBar.showSnackbarError(context, "An error occurred. Please try again.", 3);
  }
    return null;
  }
}

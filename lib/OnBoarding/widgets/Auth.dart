import "package:firebase_auth/firebase_auth.dart";



class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

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
    await _firebaseAuth.signOut();
  }
}
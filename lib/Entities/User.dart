

import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hypeclip/Enums/MusicLibraryServices.dart";



class User {

  String? username;

  String? ID;

  String? email;

  bool isLoggedIn = false;

  Map<MusicLibraryService, FlutterSecureStorage> connectedMusicLibraries = {};

  User(this.username, this.ID, this.email);



// Getters
String? get getUsername => username;
String? get getID => ID;
String? get getEmail => email;
bool get getLoggedIn => isLoggedIn;

// Setters
set setUsername(String value) => username = value;
set setID(String value) => ID = value;
set setEmail(String value) => email = value;
set setLoggedIn(bool value) => isLoggedIn = value;
}

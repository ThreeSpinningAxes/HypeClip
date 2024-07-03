

import "package:hypeclip/Enums/MusicLibraryServices.dart";



class User {

  String? username;

  String? ID;

  String? email;

  bool isLoggedIn = false;


  
  Set<MusicLibraryService> connectedMusicServices = {};

  User(this.username, this.ID, this.email);



// Getters
String? get getUsername => username;
String? get getID => ID;
String? get getEmail => email;
bool get getLoggedIn => isLoggedIn;
Set<MusicLibraryService> get getConnectedMusicServices => connectedMusicServices;

// Setters
set setUsername(String value) => username = value;
set setID(String value) => ID = value;
set setEmail(String value) => email = value;
set setLoggedIn(bool value) => isLoggedIn = value;
set setConnectedMusicServices(Set<MusicLibraryService> value) => connectedMusicServices = value;
}

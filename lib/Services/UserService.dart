import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hypeclip/Entities/User.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';


class Userservice {

  static User user = User('','','');


  void setUser(String id, String username, String email, bool isLoggedIn) {
    //print('user now:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    user.setID = id;
    user.setUsername = username;
    user.setEmail = email;
    user.setLoggedIn = isLoggedIn;
    //print('user now after logging in:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
  }

  static Set<MusicLibraryService> getConnectedMusicLibraries() {
    return user.connectedMusicLibraries.keys.toSet();
  }

  static Future<void> logout() async {
    print('user now:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    user.setID = '';
    user.setUsername = '';
    user.setEmail = '';
    user.setLoggedIn = false;
    await Future.wait(user.connectedMusicLibraries.values.map((value) => value.deleteAll()));
    Userservice.user.connectedMusicLibraries.clear();
    Auth().signOut();
    //print('user now after logging out:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
  }

    static Future<void> addMusicService(MusicLibraryService service, Map<String, dynamic> data) async {
     //remove service if already connected
    FlutterSecureStorage storage = FlutterSecureStorage();
    user.connectedMusicLibraries[service] = storage;
    for (String key in data.keys) {
      await storage.write(key: key, value: data[key.toString()].toString());
    } 
  }

  static Future<void> deleteMusicService(MusicLibraryService service) async {
    if (user.connectedMusicLibraries[service] != null) { //if user has service connected
      await user.connectedMusicLibraries[service]!.deleteAll(); //delete all data for that service
      user.connectedMusicLibraries.remove(service); //remove service itself
    }
  }

  static Future<Map<String, dynamic>?> getMusicServiceData(MusicLibraryService service) async {
    if (user.connectedMusicLibraries[service] != null) {
      Map<String, dynamic> data = await user.connectedMusicLibraries[service]!.readAll();
      return data;
    }
    return null;
  }

  static Future<void> setMusicServiceData(MusicLibraryService service, Map<String, dynamic> data) async {
    if (user.connectedMusicLibraries[service] != null) {
      for (String key in data.keys) {
        await user.connectedMusicLibraries[service]!.write(key: key, value: data[key]);
      }
    }
  }

  static bool hasMusicService(MusicLibraryService service)  {
    return user.connectedMusicLibraries[service] != null;
  }


}
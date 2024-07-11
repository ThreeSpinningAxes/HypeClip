import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hypeclip/Entities/User.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/UserProfileFireStoreService.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';


class Userservice {

  static User user = User('','','');

  static FlutterSecureStorage storage = FlutterSecureStorage();

  static String _connectedMusicServicesKey = 'connectedMusicServices';

  static StreamController<Set<MusicLibraryService>> _musicServicesStreamController = StreamController.broadcast();

   static Stream<Set<MusicLibraryService>> get musicServicesStream => _musicServicesStreamController.stream;


  static void setUser(String id, String username, String email, bool isLoggedIn) {
    //print('user now:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    user.setID = id;
    user.setUsername = username;
    user.setEmail = email;
    user.setLoggedIn = isLoggedIn;
    //print('user now after logging in:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    Userservice.initMusicServicesForStorage();
  }

  static void login(String id, String username, String email) {
    user.setID = id;
    user.setUsername = username;
    user.setEmail = email;
    user.setLoggedIn = true;
    Userservice.initMusicServicesForStorage();
  }



  static Set<MusicLibraryService> getConnectedMusicLibraries() {
    print(user.connectedMusicServices);
    print("id${user.ID}");
    return user.connectedMusicServices;
  }

  static String? getUID() {
    return user.ID;
  }

  static Future<void> logout() async {
    print('user now:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    user.setID = '';
    user.setUsername = '';
    user.setEmail = '';
    user.setLoggedIn = false;
    await storage.deleteAll();
    user.connectedMusicServices.clear();
    Auth().signOut();
    //print('user now after logging out:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
  }

  //Implememt this function in different areas involving logging in for the first time, logging out, user signs into different accout etc.
  static Future<void> initMusicServicesForStorage() async {
    if (!await storage.containsKey(key: _connectedMusicServicesKey)) {
     storage.write(key: _connectedMusicServicesKey, value: jsonEncode({}));
    }

  }

  static Future<void> fetchAndStoreConnectedMusicLibrariesFromFireStore() async {
    UserProfileFireStoreService().getConnectedMusicLibraries(user.ID!).then((connectedMusicLibraries) {
      if (connectedMusicLibraries != null) {
        for (String key in connectedMusicLibraries.keys) {
          MusicLibraryService service = MusicLibraryService.values.firstWhere((element) => element.name == key);
          addMusicService(service, connectedMusicLibraries[key]);
        }
      }
    });
  }



    static Future<void> addMusicService(MusicLibraryService musicService, Map<String, dynamic> data) async {
     //remove service if already connected
    // FlutterSecureStorage storage = FlutterSecureStorage();
    // user.connectedMusicLibraries[service] = storage;
    // for (String key in data.keys) {
    //   await storage.write(key: key, value: data[key.toString()].toString());
    // } 

    // store to user object
    String service = musicService.name;
    user.connectedMusicServices.add(musicService);


    //store to secure storage

    String? connectedMusicServicesJsonEncoded = await storage.read(key: _connectedMusicServicesKey);
    print(connectedMusicServicesJsonEncoded);
    Map<String, dynamic> connectedMusicServices = jsonDecode(connectedMusicServicesJsonEncoded!);
    connectedMusicServices[service] = data;
    await storage.write(key: _connectedMusicServicesKey, value: jsonEncode(connectedMusicServices));
  }

  static Future<void> deleteMusicService(MusicLibraryService musicService) async {

    String service = musicService.name;
    user.connectedMusicServices.remove(musicService);
    String? connectedMusicServicesJsonEncoded = await storage.read(key: _connectedMusicServicesKey);
    Map<String, dynamic> connectedMusicServices = jsonDecode(connectedMusicServicesJsonEncoded!);
    if (connectedMusicServices[service] != null) {
      connectedMusicServices.remove(service);
      await storage.write(key: _connectedMusicServicesKey, value: jsonEncode(connectedMusicServices));
    }
  }

  static Future<Map<String, dynamic>?> getMusicServiceData(MusicLibraryService service) async {
    
    String? data = await storage.read(key: _connectedMusicServicesKey);
    Map<String, dynamic> storedData = jsonDecode(data!);
    if (storedData.containsKey(service.name)) {
      return storedData[service.name];
    } else {
      return null;
    }
  }

  static Future<void> setMusicServiceData(MusicLibraryService service, Map<String, dynamic> data) async {
     Map<String, dynamic>? storedData = await getMusicServiceData(service);
     if (storedData != null) {
       storedData.addAll(data);
       await storage.write(key: service.name, value: jsonEncode(storedData));
     } 
  }

  static Future<void> setMusicServiceDataProperty(MusicLibraryService service, String key, dynamic value) async {
    Map<String, dynamic>? storedData = await getMusicServiceData(service);
    if (storedData != null) {
      storedData[key] = value;
      await storage.write(key: service.name, value: jsonEncode(storedData));
    }
  }

  static bool hasMusicService(MusicLibraryService service) {
    return user.connectedMusicServices.contains(service);
    // String? data = await storage.read(key: _connectedMusicServicesKey);
    // Map<String, dynamic> storedData = jsonDecode(data!);
    // return storedData.containsKey(service.name);

  }

  



}
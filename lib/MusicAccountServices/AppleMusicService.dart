import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Services/UserService.dart';

class AppleMusicService {
  final String DEVELOPER_TOKEN = 'YOUR_DEVELOPER_TOKEN_HERE';
  final String USER_TOKEN_VAR_NAME = 'user_token';
  final String BASE_API_URL = 'https://api.music.apple.com/v1/';

  static final AppleMusicService _instance = AppleMusicService._internal();
  AppleMusicService._internal();
  factory AppleMusicService() {
    return _instance;
  }
  static AppleMusicService get instance => _instance;

  Future<Map<String, dynamic>?> authorize() async {
    // Apple Music authorization requires user interaction with the Music app for initial token generation.
    // This method should be implemented according to your app's flow for obtaining the Music User Token.
    // For demonstration, we'll assume the token is obtained and stored.
    String? userToken = await getUserTokenFromStorage();
    if (userToken != null) {
      Map<String, dynamic> accessData = {USER_TOKEN_VAR_NAME: userToken};
      Userservice.addMusicService(MusicLibraryService.appleMusic, accessData);
      return accessData;
    } else {
      return null;
    }
  }

  Future<String?> getUserTokenFromStorage() async {
    Map<String, dynamic>? data =
        await Userservice.getMusicServiceData(MusicLibraryService.appleMusic);
    if (data != null) {
      return data[USER_TOKEN_VAR_NAME];
    }
    return null;
  }

  Future<void> setUserTokenToStorage(String userToken) async {
    Map<String, dynamic> data = {USER_TOKEN_VAR_NAME: userToken};
    await Userservice.addMusicService(MusicLibraryService.appleMusic, data);
  }

  Future<List<dynamic>?> getUserLibrarySongs(
    int limit,
    int offset,
  ) async {
    String? userToken = await getUserTokenFromStorage();
    if (userToken == null) {
      print('User Token is null');
      return null;
    }
    var queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    String url = Uri.parse('$BASE_API_URL/me/library/songs')
        .replace(queryParameters: queryParams)
        .toString();
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $DEVELOPER_TOKEN',
        'Music-User-Token': userToken,
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> songs = data['data'];
      return songs;
    } else {
      // Handle error: invalid user token, network error, etc.
      print('Failed to get user library songs: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentPlaybackState() async {
    // Apple Music does not provide a direct API to fetch the current playback state via web API.
    // This functionality is typically handled within the app using the MusicKit JS or the MediaPlayer framework on iOS.
    // For demonstration, this method will return a placeholder response.
    return {
      'state': 'Placeholder state',
      'message': 'Apple Music playback state is not directly available via web API.'
    };
  }
}
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/DeviceInfoManager.dart';
import 'package:hypeclip/Utilities/RandomGen.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'dart:developer' as developer;

/*
  This class is responsible for handling all the spotify related operations.
*/
class SpotifyService {
  final String CLIENT_ID = '0d5675db61a041668089a0d7f954b206';

  final String CLIENT_SECRET = '4e105f2a792a45939882ba21857dc355';

  final String REDIRECT_URI = 'hypeclip://callback';

  final String BASE_AUTH_API_URL = 'accounts.spotify.com';

  final String AUTH_TOKEN_URL = '/authorize'; //authorize;

  final String ACCESS_TOKEN_URL = '/api/token';

  final String ACCESS_TOKEN_VAR_NAME = 'access_token';

  final String REFRESH_TOKEN_VAR_NAME = 'refresh_token';

  final String ACCESS_TOKEN_EXP_VAR_NAME = 'expires_in';

  final String BASE_API_URL = 'https://api.spotify.com/v1/';

  final String SCOPES =
      'user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing streaming playlist-read-private user-read-playback-position user-library-read user-read-email user-read-recently-played';

  final String TRACKS_URL = 'me/tracks';

  final String PLAYBACK_STATE_URL = 'me/player';

  final String AVAILABLE_DEVICES = 'me/player/devices';

  final String PLAY_TRACK = 'me/player/play';

  final String PAUSE_PLAYBACK = 'me/player/pause';

  final String USER_PLAYLISTS_URL = 'me/playlists';

  final String RECENTLY_PLAYED = 'me/player/recently-played';

  String deviceID = "NO_DEVICE";

  static final SpotifyService _instance = SpotifyService._internal();

  SpotifyService._internal();

  factory SpotifyService() {
    return _instance;
  }

  static SpotifyService get instance => _instance;

  Future<bool> connectToSpotifyRemote() async {
    return await SpotifySdk.connectToSpotifyRemote(
        clientId: CLIENT_ID, redirectUrl: REDIRECT_URI, scope: SCOPES);
  }

  Future<Map<String, dynamic>?> authorize() async {
    String? authCode = await getAuthorizationToken();
    if (authCode != null) {
      Map<String, dynamic>? accessData = await _getAccessData(authCode);
      if (accessData != null) {
        Userservice.addMusicService(MusicLibraryService.spotify, accessData);
        return accessData;
      } else {
        return null;
      }
    }
    return null;
    // try {
    //   String accessToken = await SpotifySdk.getAccessToken(
    //       clientId: CLIENT_ID, redirectUrl: REDIRECT_URI, scope: SCOPES);
    //   await setAccessTokenToStorage(accessToken);
    //   Map<String, dynamic> data = {'access_token': accessToken};
    //   Userservice.addMusicService(MusicLibraryService.spotify, data);
    //   return data;
    // } catch (e) {
    //   developer.log(e.toString());
    //   return null;
    // }
  }

  Future<String?> getAccessTokenFromStorage() async {
    Map<String, dynamic>? data =
        await Userservice.getMusicServiceData(MusicLibraryService.spotify);
    if (data != null) {
      return data[ACCESS_TOKEN_VAR_NAME];
    }
    return null;
  }

  Future<String?> getRefreshTokenFromStorage() async {
    Map<String, dynamic>? data =
        await Userservice.getMusicServiceData(MusicLibraryService.spotify);
    if (data != null) {
      return data[REFRESH_TOKEN_VAR_NAME];
    }
    return null;
  }

  Future<String?> getExpirationTimeFromStorage() async {
    Map<String, dynamic>? data =
        await Userservice.getMusicServiceData(MusicLibraryService.spotify);
    if (data != null) {
      return data[ACCESS_TOKEN_EXP_VAR_NAME];
    }
    return null;
  }

  Future<void> setAccessTokenToStorage(String accessToken) async {
    Map<String, dynamic> data = {ACCESS_TOKEN_VAR_NAME: accessToken};
    await Userservice.addMusicService(MusicLibraryService.spotify, data);
  }

  Future<String?> getAuthorizationToken() async {
    String randomString = RandomGen().generateRandomString(16);
    Map<String, String> body = {
      'client_id': CLIENT_ID,
      'response_type': 'code',
      'redirect_uri': REDIRECT_URI,
      'scope': SCOPES,
      'show_dialog': 'true',
      'state': randomString
      //if response has same state as this, then it is a valid response
    };

    final authURL = Uri.https(BASE_AUTH_API_URL, '/authorize', body);
    try {
      final result = await FlutterWebAuth2.authenticate(
          url: authURL.toString(),
          callbackUrlScheme: "hypeclip",
          options: FlutterWebAuth2Options(intentFlags: ephemeralIntentFlags));

      Map<String, dynamic> response = Uri.parse(result).queryParameters;
      print("auth data: ${jsonEncode(response)}");
      if (response['error'] != null) {
        print('error getting auth code: ${response['error']}');
        return null;
      }

      String? authCode = Uri.parse(result).queryParameters['code'];
      String? state = Uri.parse(result).queryParameters['state'];

      //check if state is same as the one sent. If not a cross site request forgery attack occured and we abandon the request
      if (state != randomString || state == null) {
        return null;
      } else {
        return authCode;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Get all the data after completing authorization. This includes the access token, and the refresh token.
  Future<Map<String, dynamic>?> _getAccessData(String authCode) async {
    final url = Uri.https(BASE_AUTH_API_URL, ACCESS_TOKEN_URL);

    final response = await http.post(url, body: {
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET,
      'grant_type': 'authorization_code',
      'code': authCode,
      'redirect_uri': REDIRECT_URI
    });
    if (response.statusCode == 200) {
      print('success getting access data: ${response.body}');
      final params = jsonDecode(response.body) as Map<String, dynamic>;
      if (params.containsKey('error')) {
        print('error getting access token: ${params['error']}');

        // ignore: unnecessary_null_comparison
      }
      return params;
    } else {
      print('Failed to get access data: ${response.body}');
      return null;
    }
  }

  Future<void> refreshAccessToken() async {
    String? refreshToken = await getRefreshTokenFromStorage();
    if (refreshToken == null) {
      print('no refresh token exists');
      return;
    }
    final Uri url = Uri.https('accounts.spotify.com', '/api/token');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$CLIENT_ID:$CLIENT_SECRET'))}',
    }, body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      await setNewAccessRefreshTokens(data[ACCESS_TOKEN_VAR_NAME], refreshToken,
          data[ACCESS_TOKEN_EXP_VAR_NAME]);
    } else {
      // Handle error: invalid refresh token, network error, etc.
      print('Failed to refresh token: ${response.body}');
    }
  }

  Future<void> setNewAccessRefreshTokens(
      String accessToken, String? refreshToken, int expiresIn) async {
    Map<String, dynamic> data = {
      ACCESS_TOKEN_VAR_NAME: accessToken,
      REFRESH_TOKEN_VAR_NAME: refreshToken,
      ACCESS_TOKEN_EXP_VAR_NAME: expiresIn.toString()
    };
    await Userservice.setMusicServiceData(MusicLibraryService.spotify, data);
  }

  /*
    Get the user's tracks from spotify. This includes the songs that the user has liked. 
    The limit parameter specifies the number of tracks to fetch, and the offset parameter specifies the index to start fetching from.
  */
  Future<List<Song>?> getUserTracks(
    int limit,
    int offset,
  ) async {
    String? accessToken = await getAccessTokenFromStorage();
    if (accessToken == null) {
      print('Access Token is null');
      return null;
    }
    var queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    String url = Uri.parse('$BASE_API_URL$TRACKS_URL')
        .replace(queryParameters: queryParams)
        .toString();

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> tracks = data['items'];
      List<Song> songs = [];
      for (dynamic item in tracks) {
        String trackURI = item['track']['uri'];
        String songName = item['track']['name'];
        List artists = item['track']['artists'];
        String albumName = item['track']['album']['name'];
        String albumImage = item['track']['album']['images'][0]['url'];
        int duration = item['track']['duration_ms'];
        Song song = Song(
            trackURI: trackURI,
            songName: songName,
            artistName: artists.map((artist) => artist['name']).join(', '),
            albumName: albumName,
            albumImage: albumImage,
            duration: Duration(milliseconds: duration));
        songs.add(song);
      }
      return songs;
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return await getUserTracks(limit, offset);
    } else {
      return null;
    }
    //code error codes 403 and 429
  }

  Future<List<Playlist>?> getUserPlaylists(int limit, int offset) async {
    String? accessToken = await getAccessTokenFromStorage();

    if (accessToken == null) {
      developer.log("No access token");
      return null;
    }

    String url = '$BASE_API_URL$USER_PLAYLISTS_URL?limit=$limit&offset=$offset';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Playlist> playlists = (data['items'] as List)
          .map((item) => Playlist(
                id: item['id'],
                name: item['name'],
                ownerName: item['owner']['display_name'] ?? 'Unknown',
                imageUrl:
                    item['images'].isNotEmpty ? item['images'][0]['url'] : null,
                totalTracks: item['tracks']['total'],
              ))
          .toList();
      return playlists;
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return await getUserPlaylists(limit, offset);
    } else {
      developer.log('Failed to get playlists: ${response.statusCode}');
      return null;
    }
  }

  Future<List<Song>?> getTracksFromPlaylist(
      Playlist playlist, limit, offset) async {
    String? accessToken = await getAccessTokenFromStorage();

    if (accessToken == null) {
      developer.log("No access token");
      return null;
    }

    String url = '${BASE_API_URL}playlists/${playlist.id}/tracks';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Song> tracks = (data['items'] as List)
          .map((item) => Song(
                trackURI: item['track']['uri'],
                songName: item['track']['name'],
                artistName: item['track']['artists']
                    .map((artist) => artist['name'])
                    .join(', '),
                albumName: item['track']['album']['name'],
                albumImage: item['track']['album']['images'].isNotEmpty
                    ? item['track']['album']['images'][0]['url']
                    : null,
                duration: item['track']['duration_ms'] != null
                    ? Duration(milliseconds: item['track']['duration_ms'])
                    : null,
              ))
          .toList();
      return tracks;
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return await getTracksFromPlaylist(playlist, limit, offset);
    } else {
      developer.log('Failed to get tracks: ${response.statusCode}');
      return null;
    }
  }

  Future<List<Song>?> getRecentlyPlayedTracks({int limit = 25, int? time}) async {
    String? accessToken = await getAccessTokenFromStorage();

    time = time ?? DateTime.now().millisecondsSinceEpoch;
    String url = '$BASE_API_URL$RECENTLY_PLAYED?limit=$limit';
    

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Song> tracks = (data['items'] as List)
          .map((item) => Song(
                trackURI: item['track']['uri'],
                songName: item['track']['name'],
                artistName: item['track']['artists']
                    .map((artist) => artist['name'])
                    .join(', '),
                albumName: item['track']['album']['name'],
                albumImage: item['track']['album']['images'].isNotEmpty
                    ? item['track']['album']['images'][0]['url']
                    : null,
                duration: item['track']['duration_ms'] != null
                    ? Duration(milliseconds: item['track']['duration_ms'])
                    : null,
              ))
          .toList();
      return tracks;
    } else if (response.statusCode == 401) {
      // Assuming refreshAccessToken is a method that refreshes the token
      await refreshAccessToken();
      // Retry fetching the recently played tracks after refreshing the token
      return await getRecentlyPlayedTracks();
    } else {
      // Handle other status codes appropriately
      print('Failed to fetch recently played tracks: ${response.statusCode}');
      return null;
    }
  }

  Future<void> getSongsFromLibrary(String uri) async {
    try {} on PlatformException catch (e) {
      developer.log("Failed to get library state: '${e.message}'.");
      return;
    }
  }

  Future<Map<String, dynamic>?> getCurrentPlaybackState() async {
    String? accessToken = await getAccessTokenFromStorage();

    String url = '$BASE_API_URL$PLAYBACK_STATE_URL';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> playbackState = json.decode(response.body);
      return playbackState;
    } else if (response.statusCode == 401) {
      // Assuming refreshAccessToken is a method that refreshes the token
      await refreshAccessToken();
      // Retry fetching the playback state after refreshing the token
      return await getCurrentPlaybackState();
    } else {
      // Handle other status codes appropriately
      print('Failed to get playback state: ${response.statusCode}');
      return null;
    }
  }

  Future<String> setDeviceID() async {
    List<dynamic>? availableDevices = await getAvailableDevices();
    if (availableDevices == null) {
      return deviceID;
    }
    for (dynamic device in availableDevices) {
      if (device['type'] == 'Smartphone' &&
          device['name'] == DeviceInfoManager().model) {
        deviceID = device['id'];
        return deviceID;
      }
    }
    return deviceID;
  }

  // Checks if Spotify app is open on mobile device. If it is not, make this device the current active device.
  Future<bool> isSpotifyAppOpen() async {
    List<dynamic>? availableDevices = await getAvailableDevices();
    if (availableDevices != null) {
      for (dynamic device in availableDevices) {
        if (device['type'] == 'Smartphone' &&
            device['name'] == DeviceInfoManager().model) {
          deviceID = device['id'];
          return await transferPlaybackToCurrentDevice().then((resp) {
            if (resp.statusCode == 200 || resp.statusCode == 204) {
              return true;
            } else {
              return false;
            }
          });
        }
      }
      return false;
    } else {
      print(
          "Spotify must be active on current device. Make sure the Spotify app is open");
      return false;
    }
  }

  Future<Response> isSpotifyAppOpenResponse() async {
    List<dynamic>? availableDevices = await getAvailableDevices();
    if (availableDevices != null) {
      for (dynamic device in availableDevices) {
        if (device['type'] == 'Smartphone' &&
            device['name'] == DeviceInfoManager().model) {
          deviceID = device['id'];
          return await transferPlaybackToCurrentDevice();
        }
      }
      return Response("Your phone is not active with Spotify", 500);
    } else {
      print(
          "Spotify must be active on current device. Make sure the Spotify app is open");
      return Response('Spotify must be active on current device', 500);
  }
  }

  Future<Response> transferPlaybackToCurrentDevice() async {
    String? accessToken = await getAccessTokenFromStorage();

    String url = '$BASE_API_URL$PLAYBACK_STATE_URL';

    var response = await http.put(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'device_ids': [deviceID]
        }));
    return response;
  }

  Future<List<dynamic>?> getAvailableDevices() async {
    String? accessToken = await getAccessTokenFromStorage();

    String url = '$BASE_API_URL$AVAILABLE_DEVICES';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> devices = data['devices'];
      return devices;
    } else if (response.statusCode == 401) {
      // Assuming refreshAccessToken is a method that refreshes the token
      await refreshAccessToken();
      // Retry fetching the available devices after refreshing the token
      return await getAvailableDevices();
    } else if (response.statusCode == 403) {
      print('Access forbidden: The user is not allowed to access this data.');
      return null;
    } else if (response.statusCode == 429) {
      print('Too many requests: Rate limiting has been applied.');
      // You might want to handle retry-after logic here
      return null;
    } else {
      // Handle other status codes appropriately
      print('Failed to get available devices: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> checkIfAppIsActive() async {
    try {
      return await SpotifySdk.isSpotifyAppActive;
    } on PlatformException catch (e) {
      developer
          .log("Failed to check if Spotify app is active: '${e.message}'.");
      return false;
    } on MissingPluginException catch (e) {
      developer.log("Not implemented on platform:  '${e.message}'.");
      return false;
    }
  }

  Future<Response> playTrack(String trackURI, {required int position}) async {
    if (deviceID == 'NO_DEVICE') {
      await setDeviceID();
    }
    String? accessToken = await getAccessTokenFromStorage();

    String url = '$BASE_API_URL$PLAY_TRACK?device_id=$deviceID';

    print(DeviceInfoManager().deviceId.toString());
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uris': [trackURI],
        'position_ms': position,
      }),
    );

    if (response.statusCode == 401) {
      print('refresh token');
      await refreshAccessToken();
      return await playTrack(trackURI, position: position);
    } else if (response.statusCode == 404) {
      print('device is not active');
    }
    return response;
  }

  Future<bool> pausePlayback() async {
    String? accessToken = await getAccessTokenFromStorage();

    String url = '$BASE_API_URL$PAUSE_PLAYBACK';

    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      // The request has succeeded and the playback has been paused
      return true;
    } else if (response.statusCode == 401) {
      // Assuming refreshAccessToken is a method that refreshes the token
      await refreshAccessToken();
      // Retry pausing the playback after refreshing the token
      return await pausePlayback();
    } else if (response.statusCode == 403) {
      print('Access forbidden: The user is not allowed to access this data.');
      return false;
    } else if (response.statusCode == 429) {
      print('Too many requests: Rate limiting has been applied.');
      // You might want to handle retry-after logic here
      return false;
    } else {
      // Handle other status codes appropriately
      print('Failed to pause playback: ${response.statusCode}');
      return false;
    }
  }


}


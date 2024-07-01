import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:hypeclip/Entities/User.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/RandomGen.dart';


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

  ///api/token';

  final String BASE_API_URL = 'https://api.spotify.com/v1/';

  final String SCOPES =
      'user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing streaming playlist-read-private user-read-playback-position user-library-read';


  Future<void> authorize() async {
    String? authCode = await getAuthorizationToken();
    if (authCode != null) {
      Map<String, dynamic>? accessData= await getAccessData(authCode);
      if (accessData != null) {
        Userservice().addMusicService(MusicLibraryService.spotify, accessData);
      }
    }
  }

  Future<String?> getAccessTokenFromStroage() async{
    Map<String, dynamic>? data = await Userservice().getMusicServiceData(MusicLibraryService.spotify);
    if(data != null){
      return data[ACCESS_TOKEN_VAR_NAME];
    }
    return null;
  }

  Future<String?> getRefreshTokenFromStorage() async{
    Map<String, dynamic>? data = await Userservice().getMusicServiceData(MusicLibraryService.spotify);
    if(data != null){
      return data[REFRESH_TOKEN_VAR_NAME];
    }
    return null;
  }

  Future<String?> getExpirationTimeFromStorage() async{
    Map<String, dynamic>? data = await Userservice().getMusicServiceData(MusicLibraryService.spotify);
    if(data != null){
      return data[ACCESS_TOKEN_EXP_VAR_NAME];
    }
    return null;
  }
  
  Future<void> setAccessTokenToStorage(String accessToken) async{
    Map<String, dynamic> data = {
      ACCESS_TOKEN_VAR_NAME: accessToken
    };
    await Userservice().addMusicService(MusicLibraryService.spotify, data);
  }

  Future<String?> getAuthorizationToken() async {
    String randomString = RandomGen().generateRandomString(16);
    Map<String, String> body = {
      'client_id': CLIENT_ID,
      'response_type': 'code',
      'redirect_uri': REDIRECT_URI,
      'scope': SCOPES,
      'show_dialog': 'false',
      'state': randomString
      //if response has same state as this, then it is a valid response
    };

    final authURL = Uri.https(BASE_AUTH_API_URL, '/authorize', body);
    try {
      final result = await FlutterWebAuth2.authenticate(
          url: authURL.toString(), callbackUrlScheme: "hypeclip");

      Map<String, dynamic> response = Uri.parse(result).queryParameters;
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
  Future<Map<String, dynamic>?> getAccessData(String authCode) async {
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
    }
    else {
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
      setNewAccessRefreshTokens(data[ACCESS_TOKEN_VAR_NAME], 
      data[REFRESH_TOKEN_VAR_NAME], 
      data[ACCESS_TOKEN_EXP_VAR_NAME]);
      
    } else {
      // Handle error: invalid refresh token, network error, etc.
      print('Failed to refresh token: ${response.body}');
    }
  }
  Future<void> setNewAccessRefreshTokens(String accessToken, String refreshToken, String expiresIn) async {
    Map<String, dynamic> data = {
      ACCESS_TOKEN_VAR_NAME: accessToken,
      REFRESH_TOKEN_VAR_NAME: refreshToken,
      ACCESS_TOKEN_EXP_VAR_NAME: expiresIn
    };
    await Userservice().setMusicServiceData(MusicLibraryService.spotify, data);
  }
  


}

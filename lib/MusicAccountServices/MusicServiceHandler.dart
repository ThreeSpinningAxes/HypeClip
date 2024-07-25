import 'package:hypeclip/MusicAccountServices/AppleMusicService.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';

class MusicServiceHandler {
  final SpotifyService spotifyService;
  final AppleMusicService appleMusicService;

  MusicServiceHandler(this.spotifyService, this.appleMusicService);

  Future<Map<String, dynamic>?> authenticate(String platform) async {
    if (platform == "Spotify") {
      return await spotifyService.authorize();
    } else if (platform == "AppleMusic") {
      return await appleMusicService.authorize();
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> refreshAccessToken(String platform) async {
    if (platform == "Spotify") {
      return await spotifyService.refreshAccessToken();
    } else if (platform == "AppleMusic") {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported platform");
    }
  }

  
}
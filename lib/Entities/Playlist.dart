

import 'package:hypeclip/Entities/BackupConnectedServiceContent.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/UserConnectedMusicServiceDB.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Playlist {
  
  static const String likedTracksID = "likedTracks";

  static const String recentlyPlayedID = "recentlyPlayed";
  
  @Id()
  int? dbID = 0; 
  
  String id; //actual streaming service id
  String? uri;

  @Index(type: IndexType.value)
  String name;
  String? ownerName;
  String? imageUrl;
  int? totalTracks;
  
  final songsDB = ToMany<Song>();

  final backup = ToOne<BackupConnectedServiceContent>();

  final userMusicStreamingServiceAccount = ToOne<UserConnectedMusicService>();

  @Transient()
  MusicLibraryService? musicLibraryService;

  String get musicLibraryServiceDB => musicLibraryService?.name ?? 'unknown';
  set musicLibraryServiceDB(String value) {
   musicLibraryService = MusicLibraryService.values.firstWhere((val) {
      return val.name == value;
    }, orElse: () => MusicLibraryService.unknown);
  }

  Playlist({
    this.dbID,
    required this.id,
    this.uri,
    required this.name,
    this.ownerName,
    this.imageUrl,
    this.totalTracks,
    this.musicLibraryService,
  });
}
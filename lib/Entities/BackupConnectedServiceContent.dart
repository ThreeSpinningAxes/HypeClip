
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/UserProfileDB.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';
@Entity()

class BackupConnectedServiceContent  {

  @Id()
  int id = 0;

  @Backlink('backup')
  final ToMany<Playlist> cachedPlaylists = ToMany<Playlist>();

  @Backlink('backup')
  final ToMany<Song> cachedSongs = ToMany<Song>();

  @Backlink('backup')
  final ToMany<TrackClip> cachedTrackClips = ToMany<TrackClip>();

  final linkedUser = ToOne<UserProfileDB>();


  @Transient()
  MusicLibraryService? service = MusicLibraryService.unknown;

  String get musicServiceDB => service!.name;

  set musicServiceDB(String ser) => service = MusicLibraryService.values.firstWhere((val) {
    return val.name == ser;
  }, orElse: () => MusicLibraryService.unknown);




}
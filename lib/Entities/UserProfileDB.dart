import 'package:hypeclip/Entities/BackupConnectedServiceContent.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/UserConnectedMusicServiceDB.dart';
import 'package:objectbox/objectbox.dart';


@Entity()
class UserProfileDB {

  @Id()
  int id = 0;

  @Backlink('connectedUserDB')
  final connectedMusicStreamingServices = ToMany<UserConnectedMusicService>();

  
  @Backlink()
  final streamingServiceBackups = ToMany<BackupConnectedServiceContent>();

  final allTrackClipsDB = ToMany<TrackClip>();

  final allTrackClipPlaylistsDB = ToMany<TrackClipPlaylist>();


}